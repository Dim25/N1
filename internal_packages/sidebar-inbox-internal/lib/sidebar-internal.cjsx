_ = require 'underscore-plus'
React = require "react"
moment = require 'moment-timezone'
InternalAdminStore = require "./internal-admin-store"

AccountStates =
  "developer_program": "Developer Program"
  "trial-expired": "Trial Expired"
  "paid": "Paid"
  "cancelled": "Cancelled"

AccountKeys =
  "deleted_at": "Deleted At"
  "healthy": "Healthy"
  "initial_sync": "Initial Sync"
  "is_enabled": "Enabled"
  "namespace_id": "Namespace Id"
  "provider": "Provider"
  "remote_count": "Remote Count"
  "state": "State"
  "status": "Status"
  "sync_disabled_reason": "Sync Disabled Reason"
  "sync_end_time": "Sync End Time"
  "sync_error": "Sync Error"
  "sync_host": "Sync Host"
  "sync_restart_time": "Sync Restart Time"
  "sync_start_time": "Sync Start Time"
  "sync_type": "Sync Type"

module.exports =
SidebarInternal = React.createClass

  getInitialState: ->
    data: {}

  componentDidMount: ->
    @unsubscribe = InternalAdminStore.listen @_onChange

  componentWillUnmount: ->
    @unsubscribe()

  render: ->
    <div className="salesforce-sidebar">
      <div className="salesforce-sidebar-sections">
        <div className="sidebar-section">
          <h2 className="sidebar-h2">Mailsync Account</h2>
          {@_renderAccount()}
        </div>
        <div className="sidebar-section">
          <h2 className="sidebar-h2">Authenticated Applications</h2>
          {@_renderApplications()}
        </div>
      </div>
    </div>

  _renderAccount: ->
    if @state.data.loading
      return <div>Loading...</div>

    acct = @state.data.account
    if acct
      <div className="sidebar-item">
        <h3 className="sidebar-h3"><a href={@_accountUrl(acct)}>{acct.email} ({acct.id})</a></h3>
        <div className="sidebar-extra-info">{@_accountDetails(acct)}</div>
      </div>
    else
      <div>No Matching Account</div>
 
  _renderApplications: ->
    if @state.data.loading
      return <div>Loading...</div>

    if @state.data.apps
      @state.data.apps.map (app) =>
        <div className="sidebar-item">
          <h3 className="sidebar-h3"><a href={@_appUrl(app)}>{app.name}</a></h3>
          <div className="sidebar-extra-info">{@_appDetails(app)}</div>
        </div>
    else
      <div>No Matching Applications</div>

  _accountUrl: (account) ->
    "https://admin.inboxapp.com/accounts/#{account.id}"

  _accountDetails: (account) ->
    cjsx = []
    for key, value of account
      displayName = AccountKeys[key]
      continue unless displayName
      continue unless value
      value = "True" if value is true
      value = "False" if value is false
      value = moment.unix(value).format("DD / MM / YYYY h:mm a z") if key.indexOf("_time") > 0 
      cjsx.push <div style={textAlign:'right'}><span style={float:'left'}>{displayName}:</span>{value}</div>
    cjsx

  _appUrl: (app) ->
    "https://admin.inboxapp.com/apps/#{app.id}"

  _appDetails: (app) ->
    "No Extra Details"

  _onChange: ->
    @setState(@_getStateFromStores())

  _getStateFromStores: ->
    data: InternalAdminStore.dataForFocusedContact()

SidebarInternal.maxWidth = 300
SidebarInternal.minWidth = 200