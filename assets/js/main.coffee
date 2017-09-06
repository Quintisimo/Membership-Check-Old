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
  database.ref(studentNumber).on('value', (snapshot) ->
    if snapshot.val() != null
      updates = {}
      updates[studentNumber + '/Paid'] = paid
      database.ref().update(updates)
    else
      database.ref(studentNumber).set(
        Paid: paid
        FreeUses: freeUses
      )
    return
  )
  return

checkPaid = (studentNumber) ->
  database.ref(studentNumber).once('value').then((snapshot) ->
    if snapshot.val() != null
      database.ref(studentNumber + '/Paid').once('value').then((snapshot) ->
        if snapshot.val() == 'yes'
          alert 'Legend'
        else if snapshot.val() == 'no'
          database.ref(studentNumber + '/FreeUses').once('value').then((snapshot) ->
            if snapshot.val() == 0
              firstUse = snapshot.val()
              firstUse = 1
              firstUpdate = {}
              firstUpdate[studentNumber + '/FreeUses'] = firstUse
              database.ref().update(firstUpdate)
              alert 'This is your first free use'
            else if snapshot.val() == 1
              secondUse = snapshot.val()
              secondUse = 2
              secondUpdate = {}
              secondUpdate[studentNumber + '/FreeUses'] = secondUse
              database.ref().update(secondUpdate)
              alert 'This is your last free use'
            else
              alert 'No remaining free uses'
            return
          )
        return
      )
    else
      writeUser(studentNumber, 'no', 1)
      alert 'This is your first free use'
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
        alert 'Wrong Password'
      $('#password').val('')
      return false

    return
  return
) jQuery
