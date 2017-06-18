local composer = require("composer")
local widget = require("widget")
local math = require("math")

local _W = display.contentWidth
local _H = display.contentHeight

display.setStatusBar( display.HiddenStatusBar )

local scene = composer.newScene()
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
function scene:create (event)

  local group = self.view

  print("create phase")

  -- таблица, хранящая данные с полей ввода для первой выборки
  data = {}

  -- таблица для данных второй выборки
  data2 = {}

  -- индикаторы среднего значения
  meanLabel = display.newText("[1] :", _W * 0.2, _H * 0.05, nil, 16)
  meanLabel.align = "center"
  meanLabel.anchorX = 0

  secondmeanLabel = display.newText("[2] :", _W * 0.2, _H * 0.1, nil, 16)
  secondmeanLabel.align = "center"
  secondmeanLabel.anchorX = 0

  -- индикаторы СКО
  meanDeviationLabel = display.newText( "[1] : ", _W * 0.2, _H * 0.2, nil,16 )
  meanDeviationLabel.align = "center"
  meanDeviationLabel.anchorX = 0

  secondmeanDeviationLabel = display.newText( "[2] :", _W * 0.2, _H * 0.25, nil,16 )
  secondmeanDeviationLabel.align = "center"
  secondmeanDeviationLabel.anchorX = 0

  muLabel = display.newText("mu : ", _W * 0.2, _H * 0.35,nil,16)
  muLabel.align = "center"
  muLabel.anchorX = 0

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
  -- записывает данные с полей ввода в соотв. ячейку таблицы data
  function inputFieldListener(event)
    if ( event.phase == "began" ) then
        -- User begins editing "defaultField"

    elseif ( event.phase == "ended" or event.phase == "submitted" ) then
        -- Output resulting text from "defaultField"
        print( event.target.text )
        data[event.target.num] = event.target.text
        print("data["..event.target.num.."] = "..data[event.target.num])
        event.target:setTextColor(0,1,0)


    elseif ( event.phase == "editing" ) then
        --print( event.newCharacters )
        --print( event.oldText )
        --print( event.startPosition )
        --print( event.text )
        event.target:setTextColor(1,0,0)

    end
  end

  -- аналогично для второй выборки
  function secondinputFieldListener(event)
        if ( event.phase == "began" ) then
        -- User begins editing "defaultField"

    elseif ( event.phase == "ended" or event.phase == "submitted" ) then
        -- Output resulting text from "defaultField"
        data2[event.target.num] = event.target.text
        print("data2["..event.target.num.."] = "..data2[event.target.num])
        event.target:setTextColor(0.1,1,0.1)


    elseif ( event.phase == "editing" ) then
      -- для отладки
      -- print( event.newCharacters )
      -- print( event.oldText )
      -- print( event.startPosition )
      -- print( event.text )
      event.target:setTextColor(1,0,0)
    end
  end

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
  -- scrollView, хранит все поля ввода и кнопки +-  
  -- ScrollView listener
  local function scrollListener( event )
   
      local phase = event.phase
      if ( phase == "began" ) then print( "Scroll view was touched" )
      elseif ( phase == "moved" ) then print( "Scroll view was moved" )
      elseif ( phase == "ended" ) then print( "Scroll view was released" )
      end
   
      -- In the event a scroll limit is reached...
      if ( event.limitReached ) then
          if ( event.direction == "up" ) then print( "Reached bottom limit" )
          elseif ( event.direction == "down" ) then print( "Reached top limit" )
          elseif ( event.direction == "left" ) then print( "Reached right limit" )
          elseif ( event.direction == "right" ) then print( "Reached left limit" )
          end
      end
   
      return true
  end
   
  -- Create the widget
  local scrollView = widget.newScrollView(
      {
          top = _H * 0.45,
          left = _W * 0.01,
          width = _W * 0.98 ,
          height = _H * 0.6,
          scrollWidth = 0,
          scrollHeight = _H,
          hideBackground = false,
          backgroundColor = { 0.1, 0.1, 0.1 },
          horizontalScrollDisabled = true,
          topPadding, bottomPadding = 50, _H,
          listener = scrollListener

      }
  )
  scrollView:setScrollHeight( _H )


  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
  ----------ЗДЕСЬ ОПИСЫВАЮТСЯ ЭЛЕМЕНТЫ, ОТНОСЯЩИЕСЯ К ВЫБОРКЕ №1------------------
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  --таблица, хранящая все поля ввода первой выборки
  inputField = {}

  inputField[1] = native.newTextField( _W * 0.25, _H * 0.1, _W * 0.3, _H * 0.05)
  inputField[1].num = 1
  inputField[1].inputType = "number"
  inputField[1].placeholder = "(№"..inputField[1].num..")"
  inputField[1].align = "center"
  inputField[1].hasBackground = false
  inputField[1]:addEventListener( "userInput", inputFieldListener )
  inputField[1]:resizeFontToFitHeight()

  scrollView:insert(inputField[1])


  -- добавляет на экран поле ввода. соответственно добавляет запись в data
  -- возвращает добавленное поле
  function addInputField(event)
    local length = #inputField

    inputField[length + 1] = native.newTextField( _W * 0.25, inputField[length].y + _H * 0.09 , _W * 0.3, _H * 0.05)
    inputField[#inputField].num = #inputField
    inputField[#inputField].inputType = "number"
    inputField[#inputField].placeholder = "(№"..inputField[#inputField].num..")"
    inputField[#inputField].align = "center"
    inputField[#inputField].hasBackground = false
    inputField[#inputField]:addEventListener( "userInput", inputFieldListener )
    inputField[#inputField]:resizeFontToFitHeight()

    scrollView:insert(inputField[#inputField])

    return inputField[#inputField]
  end

  -- удаляет с экрана поле ввода, удаляет запись в data
  function deleteField()
    scrollView:remove(inputField[#inputField])
    data[#data] = nil
    inputField[#inputField]:removeSelf()
    inputField[#inputField] = nil
  end

  -- обрабатывае нажатие кнопки добавления
  function onaddField(event)
    if event.phase == "began" then
      addInputField()
      print("input field number "..#inputField.." added")
    end

  end

  -- обрабатывает нажатие кнопки удаления
  function ondeleteField(event)
    if event.phase == "began" then
      if #inputField > 1 then
        deleteField()
        print("input field number "..#inputField.." deleted")
      end
    end
  end

  -- кнопка добавления поля ввода
  addFieldButton = widget.newButton({
    width = _W * 0.1,
    height = _H * 0.075,
    defaultFile = "res/plus.png",
    overFile = "res/plus_tapped.png",
    --label = "add",
    x = _W * 0.2,
    y = _H * 0.375,
    onEvent = onaddField
  })

  -- кнопка удаления поля ввода
  deleteFieldButton = widget.newButton({
    width = _W * 0.1,
    height = _H * 0.075,
    defaultFile = "res/delete.png",
    overFile = "res/delete_tapped.png",
    --label = "del",
    x = _W * 0.325,
    y = _H * 0.375,
    onEvent = ondeleteField
  })

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
----------ЗДЕСЬ ОПИСЫВАЮТСЯ ЭЛЕМЕНТЫ, ОТНОСЯЩИЕСЯ К ВЫБОРКЕ №2------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--таблица, хранящая все поля ввода второй выборки
secondinputField = {}

secondinputField[1] = native.newTextField( _W * 0.75, _H * 0.1, _W * 0.3, _H * 0.05)
secondinputField[1].num = 1
secondinputField[1].inputType = "number"
secondinputField[1].placeholder = "(№"..secondinputField[1].num..")"
secondinputField[1].align = "center"
secondinputField[1].hasBackground = false
secondinputField[1]:addEventListener( "userInput", secondinputFieldListener )
secondinputField[1]:resizeFontToFitHeight()

scrollView:insert(secondinputField[1])


-- добавляет на экран поле ввода. соответственно добавляет запись в data
-- возвращает добавленное поле
function addSecondInputField(event)
  local length = #secondinputField

  secondinputField[length + 1] = native.newTextField( _W * 0.75, secondinputField[length].y + _H * 0.09, _W * 0.3, _H * 0.05)
  secondinputField[#secondinputField].num = #secondinputField
  secondinputField[#secondinputField].inputType = "number"
  secondinputField[#secondinputField].placeholder = "(№"..secondinputField[#secondinputField].num..")"
  secondinputField[#secondinputField].align = "center"
  secondinputField[#secondinputField].hasBackground = false
  secondinputField[#secondinputField]:addEventListener( "userInput", secondinputFieldListener )
  secondinputField[#secondinputField]:resizeFontToFitHeight()

  scrollView:insert(secondinputField[#secondinputField])

  return secondinputField[#secondinputField]
end

-- удаляет с экрана поле ввода, удаляет запись в data
function deleteSecondField()
  scrollView:remove(secondinputField[#secondinputField])
  data2[#data2] = nil
  secondinputField[#secondinputField]:removeSelf()
  secondinputField[#secondinputField] = nil
end

-- обрабатывае нажатие кнопки добавления
function onaddSecondField(event)
  if event.phase == "began" then
    addSecondInputField()
    print("input field number "..#secondinputField.." added")
  end

end

-- обрабатывает нажатие кнопки удаления
function ondeleteSecondField(event)
  if event.phase == "began" then
    if #secondinputField > 1 then
      deleteSecondField()
      print("input field number "..#secondinputField.." deleted")
    end
  end
end

  -- кнопка добавления поля ввода
  addSecondFieldButton = widget.newButton({
    width = _W * 0.1,
    height = _H * 0.075,
    defaultFile = "res/plus.png",
    overFile = "res/plus_tapped.png",
    --label = "add",
    x = _W * 0.7,
    y = _H * 0.375,
    onEvent = onaddSecondField
  })

  -- кнопка удаления поля ввода
  deleteSecondFieldButton = widget.newButton({
    width = _W * 0.1,
    height = _H * 0.075,
    defaultFile = "res/delete.png",
    overFile = "res/delete_tapped.png",
    --label = "del",
    x = _W * 0.825,
    y = _H * 0.375,
    onEvent = ondeleteSecondField
  })

  ------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------
  ----------------------------------------матчасть------------------------------------------------
  ------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------
  -- среднее по первому массиву
  function getMeanValue()
    local mean = 0

    for i=1,#data do
      mean = mean + data[i]
    end

    mean = mean/#data

    return mean
  end

  -- среднее по второму массиву
  function getSecondMeanValue()
    local mean = 0

    for i=1,#data2 do
      mean = mean + data2[i]
    end

    mean = mean/#data2

    return mean
  end

  -- СКО первого массива
  function getMeanDeviationValue()
    local meanDev = 0
    local mean = getMeanValue()

    for i=1,#data do
      meanDev = meanDev + (data[i] - mean)^2
    end

    meanDev = meanDev/(#data-1)
    meanDev = meanDev^0.5

    print("data meanDev = "..tostring(meanDev))

    return meanDev
  end

  -- СКО второго массива
  function getSecondMeanDeviationValue()
    local meanDev = 0
    local mean = getSecondMeanValue()
    print("hut meanDev = "..tostring(meanDev))


    for i=1,#data2 do
      meanDev = meanDev + (data2[i] - mean)^2
    end

    meanDev = meanDev/(#data2-1)
    meanDev = meanDev^0.5

    print("data2 meanDev = "..tostring(meanDev))

    return meanDev
  end

  -- Разница по модулю средних значений выборок
  function getMeanDelta()
    local delta = 0
    local mean = getMeanValue()
    local secondmean = getSecondMeanValue()

    delta = math.abs(mean - secondmean) 
    print("delta = "..delta)

    return delta
  end

  function getMuValue()
    local mu = 0
    local delta = getMeanDelta()
    local meanDev = getMeanDeviationValue()
    local secondmeanDev = getSecondMeanDeviationValue()


    mu = delta / ( ( (#data - 1)*(meanDev^2) + (#data2 - 1)*(secondmeanDev^2) ) ^ 0.5 )
    mu = mu * ( (  (#data * #data2 * (#data + #data2 - 2)) / (#data + #data2)  )^0.5 )

    return mu
  end
  ----------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------
  -- обрабатывает нажатие кнопки среднего значения
  function onmeanButton(event)
    if event.phase == "ended" then
      local mean = getMeanValue()
      local secondmean = getSecondMeanValue()
      
      meanLabel.text = "[1] : "..string.format("%6.2f",mean)
      secondmeanLabel.text = "[2] : "..string.format("%6.2f",secondmean)
    end    
  end

  -- обрабатывает нажатие кнопки СКО
  function onmeanDeviationButton(event)
    if event.phase == "ended" then
      local meanDev = getMeanDeviationValue()
      local secondmeanDev = getSecondMeanDeviationValue()

      meanDeviationLabel.text = "[1] : "..string.format("%6.2f",meanDev)
      secondmeanDeviationLabel.text = "[2] : "..string.format("%6.2f",secondmeanDev)
    end
  end

  function onmuButton(event)
    if event.phase == "ended" then
      local mu = getMuValue()

      muLabel.text = "mu : "..string.format("%6.2f", mu)
    end
  end

  ----------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------
  -- выгружает среднее значение
  local meanButton = widget.newButton({
    shape = "circle",
    radius = _W * 0.075,
    x = _W * 0.1,
    y = _H * 0.08,
    label = "M",
    fontSize = 26,
    labelColor = { default={ 1,1,1 }, over={ 0, 0, 0, 0.5 } },
    fillColor = { default={ 1, 0.2, 0.5, 0.7 }, over={ 1, 0.2, 0.5, 1 } },
    onEvent = onmeanButton
    })

  -- выгружает СКО
  local meanDeviationButton = widget.newButton({
    shape = "circle",
    radius = _W * 0.075,
    x = _W * 0.1,
    y = _H * 0.225,
    label = "MD",
    fontSize = 26,
    labelColor = { default={ 1,1,1 }, over={ 0, 0, 0, 0.5 } },
    fillColor = { default={ 1, 0.2, 0.5, 0.7 }, over={ 1, 0.2, 0.5, 1 } },
    onEvent = onmeanDeviationButton
    })

  local muButton = widget.newButton({
    shape = "circle",
    radius = _W * 0.075,
    x = _W * 0.1,
    y = _H * 0.35,
    label = "MU",
    fontSize = 26,
    labelColor = { default={ 1,1,1 }, over={ 0, 0, 0, 0.5 } },
    fillColor = { default={ 1, 0.2, 0.5, 0.7 }, over={ 1, 0.2, 0.5, 1 } },
    onEvent = onmuButton  
    })
  ----------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------
  --следит за координатами кнопок добавления и удаления, держит их на одном уровне. Костыль.
  function setPositionForButons()

    if (addFieldButton.y == inputField[#inputField].y + _H * 0.09) and (deleteFieldButton.y == inputField[#inputField].y + _H * 0.09) then
      -- do nothing
    else
      addFieldButton.y = inputField[#inputField].y + _H * 0.09
      deleteFieldButton.y = inputField[#inputField].y + _H * 0.09
      --print("Positions has been set")
    end

  end

  --следит за координатами кнопок добавления и удаления, держит их на одном уровне. Костыль.
  function setPositionForSecondButons()

    if (addSecondFieldButton.y == secondinputField[#secondinputField].y + _H * 0.09) and (deleteSecondFieldButton.y == secondinputField[#secondinputField].y + _H * 0.09) then
      -- do nothing
    else
      addSecondFieldButton.y = secondinputField[#secondinputField].y + _H * 0.09
      deleteSecondFieldButton.y = secondinputField[#secondinputField].y + _H * 0.09
      --print("Positions has been set")
    end

  end
  ------------------------------------------------------------------------------------------------
  ------------------------------------------------------------------------------------------------

  Runtime:addEventListener("enterFrame",setPositionForButons)
  Runtime:addEventListener("enterFrame",setPositionForSecondButons)

  scrollView:insert(addFieldButton)
  scrollView:insert(deleteFieldButton)
  scrollView:insert(addSecondFieldButton)
  scrollView:insert(deleteSecondFieldButton)
  group:insert(scrollView)
  group:insert(meanLabel)
  group:insert(meanDeviationLabel)

end
-----------------------------------------------------------------------
-----------------------------------------------------------------------
function scene:show (event)
  if event.phase == "will" then
    print("scene:show. 'will' phase")
  end
end
-----------------------------------------------------------------------
-----------------------------------------------------------------------
function scene:hide (event)
  print("hide phase")
end
-----------------------------------------------------------------------
-----------------------------------------------------------------------
function scene:destroy (event)

end
-----------------------------------------------------------------------
-----------------------------------------------------------------------
scene:addEventListener("create",scene)
scene:addEventListener("show",scene)
scene:addEventListener("hide",scene)
scene:addEventListener("destroy",scene)
-----------------------------------------------------------------------
return scene
-----------------------------------------------------------------------
