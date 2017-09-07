database = firebase.database()

formatStudentNumber = (studentNumber) ->
  studentNumber = studentNumber.replace(/\D/gi, '')
  studentNumber = studentNumber.substring(0, studentNumber.length - 2) if studentNumber.length > 8
  studentNumber = '0' + studentNumber if studentNumber.length == 7
  if studentNumber.length == 8
    return studentNumber
  else
    alert 'Student Number is not valid'
  return

writeUser = (studentNumber, paid, freeUses) ->
  database.ref(studentNumber).once('value').then((snapshot) ->
    if snapshot.val() != null
      updates = {}
      updates[studentNumber + '/Paid'] = paid
      database.ref().update(updates)
      $('#addUserSuccess').slideDown()
      setTimeout(->
        $('#addUserSuccess').slideUp()
      , 3000)
    else
      database.ref(studentNumber).set(
        Paid: paid
        FreeUses: freeUses
      )
      $('#addUserSuccess').slideDown()
      setTimeout(->
        $('#addUserSuccess').slideUp()
      , 3000)
    return
  )
  return

checkPaid = (studentNumber) ->
  database.ref(studentNumber).once('value').then((snapshot) ->
    if snapshot.val() != null
      database.ref(studentNumber + '/Paid').once('value').then((snapshot) ->
        if snapshot.val() == 'yes'
          $('#checkUserSuccess').slideDown()
          setTimeout(->
            $('#checkUserSuccess').slideUp()
          , 3000)
        else if snapshot.val() == 'no'
          database.ref(studentNumber + '/FreeUses').once('value').then((snapshot) ->
            if snapshot.val() == 0
              firstUse = snapshot.val()
              firstUse = 1
              firstUpdate = {}
              firstUpdate[studentNumber + '/FreeUses'] = firstUse
              database.ref().update(firstUpdate)
              $('#checkUserFirst').slideDown()
              setTimeout(->
                $('#checkUserFirst').slideUp()
              , 3000)
            else if snapshot.val() == 1
              secondUse = snapshot.val()
              secondUse = 2
              secondUpdate = {}
              secondUpdate[studentNumber + '/FreeUses'] = secondUse
              database.ref().update(secondUpdate)
              $('#checkUserLast').slideDown()
              setTimeout(->
                $('#checkUserLast').slideUp()
              , 3000)
            else
              $('#checkUserNo').slideDown()
              setTimeout(->
                $('#checkUserNo').slideUp()
              , 3000)
            return
          )
        return
      )
    else
      writeUser(studentNumber, 'no', 1)
      setTimeout(->
        $('#checkUserFirst').slideUp()
      , 3000)
    return
  )
  return

(($) ->
  $(document).ready ->

    $('#checkUser').submit ->
      studentNumber = $('#checkStudentNumber').val()
      studentNumber = formatStudentNumber(studentNumber)
      checkPaid(studentNumber)
      $('#checkStudentNumber').val('')
      return false

    $('#addUser').submit ->
      studentNumber = $('#addStudentNumber').val()
      studentNumber = formatStudentNumber(studentNumber)
      password = $('#password').val()
      if password == 'Lagswitch1'
        writeUser(studentNumber, 'yes', 0)
        $('#addStudentNumber').val('')
      else
        $('#wrongPassword').slideDown()
        setTimeout(->
          $('#wrongPassword').slideUp()
        , 3000)
      $('#password').val('')
      return false

    return
  return
) jQuery
