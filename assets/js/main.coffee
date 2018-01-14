studentDatabase = firebase.database().ref()

formatStudentNumber = (studentNumber) ->
  studentNumber = studentNumber.replace(/\D/gi, '')
  studentNumber = studentNumber.substring(0, studentNumber.length - 2) if studentNumber.length > 8
  studentNumber = '0' + studentNumber if studentNumber.length == 7
  if studentNumber.length == 8
    return studentNumber
  else
    alert 'Student Number is not valid'
  return

writeUser = (studentNumber, paid, freeUses, dialog) ->
  student = studentDatabase.child(studentNumber)
  student.once('value').then((snapshot) ->
    if snapshot.val() != null
      updates = {}
      updates[studentNumber + '/Paid'] = paid
      studentDatabase.update(updates)

      if dialog == true
        $('#addUserSuccess').slideDown()
        setTimeout(->
          $('#addUserSuccess').slideUp()
        , 3000)
    else
      student.set(
        Paid: paid
        FreeUses: freeUses
      )

      if dialog == true
        $('#addUserSuccess').slideDown()
        setTimeout(->
          $('#addUserSuccess').slideUp()
        , 3000)
    return
  )
  return

checkPaid = (studentNumber) ->
  student = studentDatabase.child(studentNumber)
  studentPaid = student.child('Paid')
  studentFreeUses = student.child('FreeUses')
  student.once('value').then((snapshot) ->
    if snapshot.val() != null
      studentPaid.once('value').then((snapshot) ->
        if snapshot.val() == 'yes'
          $('#checkUserSuccess').slideDown()
          setTimeout(->
            $('#checkUserSuccess').slideUp()
          , 3000)
        else if snapshot.val() == 'no'
          studentFreeUses.once('value').then((snapshot) ->
            if snapshot.val() == 0
              firstUse = {}
              firstUse[studentNumber + '/FreeUses'] = 1
              studentDatabase.update(firstUse)
              $('#checkUserFirst').slideDown()
              setTimeout(->
                $('#checkUserFirst').slideUp()
              , 3000)
            else if snapshot.val() == 1
              secondUse = {}
              secondUse[studentNumber + '/FreeUses'] = 2
              studentDatabase.update(secondUse)
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
      writeUser(studentNumber, 'no', 1, false)
      $('#checkUserFirst').slideDown()
      setTimeout(->
        $('#checkUserFirst').slideUp()
      , 3000)
    return
  )
  return

dateTime = (studentNumber) ->
  student = studentDatabase.child(studentNumber)
  studentPaid = student.child('Paid')
  studentFreeUses = student.child('FreeUses')
  student.once('value').then((snapshot) ->
    console.log studentNumber
    console.log snapshot.val()
    if snapshot.val() != null
      studentPaid.once('value').then((snapshot) ->
        if snapshot.val() == 'yes'
          date = new Date()
          dateTime = {}
          dateTime[studentNumber + '/Attendence/' + date.toDateString()] = date.toLocaleTimeString()
          studentDatabase.update(dateTime)
        else if snapshot.val() == 'no'
          studentFreeUses.once('value').then((snapshot) ->
            if snapshot.val() < 2
              date = new Date()
              dateTime = {}
              dateTime[studentNumber + '/Attendence/' + date.toDateString()] = date.toLocaleTimeString()
              studentDatabase.update(dateTime)
            return
          )
        return
      )
    return
  )
  return

(($) ->
  $(document).ready ->

    $('#checkUser').submit ->
      studentNumber = $('#checkStudentNumber').val()
      studentNumber = formatStudentNumber(studentNumber)
      checkPaid(studentNumber)
      setTimeout(-> 
        dateTime(studentNumber)
      , 500)
      $('#checkStudentNumber').val('')
      return false

    $('#addUser').submit ->
      studentNumber = $('#addStudentNumber').val()
      studentNumber = formatStudentNumber(studentNumber)
      password = $('#password').val()
      if password == 'Lagswitch1'
        writeUser(studentNumber, 'yes', 0, true)
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
