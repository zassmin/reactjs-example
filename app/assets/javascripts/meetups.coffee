DOM = React.DOM

FormInputWithLabelAndReset = React.createClass
  displayName: "FormInputWithLabelAndReset"
  render: ->
    DOM.div
      className: "form-group"
      DOM.label
        htmlFor: @props.id
        className: "col-lg-2 control-label"
        @props.labelText
      DOM.div
        className: "col-lg-8"
        DOM.div
          className: "input-group"
          DOM.input
            className: "form-control"
            placeholder: @props.placeholder
            id: @props.id
            value: @props.value
            onChange: (event) =>
              @props.onChange(event.target.value)

formInputWithLabelAndReset = React.createFactory(FormInputWithLabelAndReset)

monthName = (monthNumberStartingFromZero) ->
  [
    "January", "February", "March", "April", "May", "June", "July",
    "August", "September", "October", "November", "December"
  ][monthNumberStartingFromZero]

dayName = (date) ->
  dayNameStartingWithSundayZero = date.getDay()
  [
    "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
  ][dayNameStartingWithSundayZero]

DateWithLabel = React.createClass
  getDefaultProps: ->
    date: new Date()
  onYearChange: (event) ->
    newDate = new Date(
      event.target.value, 
      @props.date.getMonth(), 
      @props.date.getDate()
    )
    @props.onChange(newDate)
  onMonthChange: (event) ->
    newDate = new Date(
      @props.date.getFullYear(),
      event.target.value,
      @props.date.getDate()
    )
    @props.onChange(newDate)
  onDateChange: (event) -> 
    newDate = new Date(
      @props.date.getFullYear(),
      @props.date.getMonth(),
      event.target.value
    )
    @props.onChange(newDate)
  render: -> 
    DOM.div
      className: "form-group"
      DOM.label
        className: "col-lg-2 control-label"
        "Date"
      DOM.div
        className: "col-lg-2"
        DOM.select
          className: "form-control"
          onChange: @onYearChange
          value: @props.date.getFullYear()
          DOM.option(value: year, key: year, year) for year in [2015..2020]
      DOM.div
        className: "col-lg-3"
        DOM.select
          className: "form-control"
          onChange: @onMonthChange
          value: @props.date.getMonth()
          DOM.option(value: month, key: month, "#{month+1}-#{monthName(month)}") for month in [0..11]
      DOM.div
        className: "col-lg-2"
        DOM.select
          className: "form-control"
          onChange: @onDateChange
          value: @props.date.getDate()
          for day in [1..31]
            date = new Date(
              @props.date.getFullYear(),
              @props.date.getMonth(),
              day
            )
            DOM.option(value: day, key: day, "#{day}-#{dayName(date)}")

dateWithLabel = React.createFactory(DateWithLabel)

FormInputWithLabel = React.createClass
  getDefaultProps: -> 
    elementType: "input"
    inputType: "text"
  displayName: "FormInputWithLabel"
  render: -> 
    DOM.div
      className: "form-group"
      DOM.label
        htmlFor: @props.id
        className: "col-lg-2 control-label"
        @props.labelText
      DOM.div
        className: "col-lg-10"
        DOM[@props.elementType]
          className: "form-control"
          placeholder: @props.placeholder
          id: @props.id
          value: @props.value
          onChange: @props.onChange
          type: @tagType()
  tagType: -> 
    {
      "input": @props.inputType, 
      "textarea": null
    }[@props.elementType]
# is props a react thing? - where does it come from?

formInputWithLabel = React.createFactory(FormInputWithLabel)

window.CreateNewMeetupForm = React.createClass
  getInitialState: -> 
    {
      meetup: {
        title: '', # what the best way to prevent '' from becoming an object in the server
        description: '',
        date: new Date(), # why?, is new Date(), date.today? is this hash was renders at page load? yes!!!
        seoText: null
      }
    }
  titleChanged: (event) ->
    @state.meetup.title = event.target.value
    @forceUpdate() # is this a react function? => yes, this re-renders the value, it also mutates (directly changes the state)
  descriptionChanged: (event) -> 
    @state.meetup.description = event.target.value
    @forceUpdate() 
  dateChanged: (newDate) ->
    @state.meetup.date = newDate # this is stateless right now
    @forceUpdate()
  seoChanged: (seoText) ->
    @state.meetup.seoText = seoText
    @forceUpdate()
  computeDefaultSeoText: () -> 
    words = @state.meetup.title.toLowerCase().split(/\s+/)
    words.push(monthName(@state.meetup.date.getMonth()))
    words.push(@state.meetup.date.getFullYear().toString())
    words.filter((string) -> string.trim().length > 0).join("-").toLowerCase()
  formSubmitted: (event) -> 
    event.preventDefault()
    meetup = @state.meetup

    $.ajax
      url: "/meetups.json"
      type: "POST"
      dataType: "JSON"
      contextType: "application/json"
      processData: true
      data: {meetup: {
        title: meetup.title
        description: meetup.description
        date: "#{meetup.date.getFullYear()}-#{meetup.date.getMonth()+1}-#{meetup.date.getDate()}"}}
  render: ->
    DOM.form
      onSubmit: @formSubmitted
      className: "form-horizontal"
      DOM.fieldset null,
        DOM.legend null, "New Meetup"
        formInputWithLabel
          id: "title"
          value: @state.meetup.title
          onChange: @titleChanged
          placeholder: "Meetup Title"
          labelText: "Title"
        formInputWithLabel
          id: "description"
          value: @state.meetup.description
          onChange: @descriptionChanged
          placeholder: "Meetup Description"
          labelText: "Description"
          elementType: "textarea"
        dateWithLabel
          onChange: @dateChanged
          date: @state.meetup.date
        formInputWithLabelAndReset
          id: "seo"
          value: if @state.meetup.seoText? then @state.meetup.seoText else @computeDefaultSeoText()
          onChange: @seoChanged
          placeholder: "SEO text"
          labelText: "seo"

        DOM.div
          className: "form-group"
          DOM.div
            className: "col-lg-10 col-lg-offset-2"
            DOM.button
              type: "submit"
              className: "btn btn-primary"
              "Save"

