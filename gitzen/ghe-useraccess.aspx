<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WebForm1.aspx.cs" Inherits="WFSSDevOps.WebForm1" validateRequest="false" %>

<!DOCTYPE html>
 
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">

   <meta charset="utf-8"/>
   <title>GHE - User Access</title>
<style>
   h3 {
      font-family:Arial, sans-serif, Helvetica;
      font-size:medium;
   }
   p {
      font-family:Arial, sans-serif, Helvetica;
      font-size:small;
   }
   th {
      border:1.5px solid MidnightBlue;
      border-collapse:collapse;
      cursor:pointer;
   }
   th, td {
      font-family:Arial, sans-serif, Helvetica;
      font-size:small;
      padding:3px;
   }
   tr:nth-child(even) {
      background-color:#e4f0f5;
   }
   tr:nth-child(odd) {
      background-color:Ivory;
   }
</style>
<link rel="stylesheet" href="//code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
<script src="https://code.jquery.com/jquery-1.12.4.js"></script>
<script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>

<script>  
  $( function() {
  $( "#date" ).datepicker();
  } );
  
  function disable() {
    document.getElementById("executeBtn").value="Submitting...";
    document.getElementById("executeBtn").disabled=true;
    document.body.style.cursor = 'wait';
  }
  function doHourglass() {
    document.body.style.cursor = 'wait';
  }
  function populatePage() {
    var epicnum = "<%= Request.QueryString["epicnum"] %>";
    if (epicnum.length > 0) {
      epicnum = "GHE Epic: <a href=\"https://github.ibm.com/fc-cloud-ops/dev-ops-tasks/issues/" + epicnum + "\"" + " target=\"_blank\">" + epicnum + "</a>";
    }
    document.getElementById("tdepicnum").innerHTML = epicnum;
    
    document.getElementById("executeBtn").disabled = true;

    document.getElementById("assignee").onchange = function() {reValidate()};
    document.getElementById("milestone").onchange = function() {reValidate()};
    document.getElementById("pipeline").onchange = function() {reValidate()};
    document.getElementById("label1").onchange = function() {reValidate()};
    document.getElementById("label2").onchange = function() {reValidate()};
    
    document.getElementById("label1").value = "scrum-Process/Compliance";
    document.getElementById("label2").value = "ops-user management";
  }  
  function validate() {
    var assignee = document.getElementById("assignee").value;
    var date = document.getElementById("date").value;
    var milestone = document.getElementById("milestone").value;
    var pipeline = document.getElementById("pipeline").value;
    var label1 = document.getElementById("label1").value;
    var label2 = document.getElementById("label2").value;

    var postData = "{\"assignee\":\"" + assignee +
    "\",\"date\":\"" + date +
    "\",\"milestone\":\"" + milestone +
    "\",\"pipeline\":\"" + pipeline +
    "\",\"label1\":\"" + label1 +
    "\",\"label2\":\"" + label2 +
    "\"}";
    document.getElementById("payloadHdn").value = postData;
    document.getElementById("executeBtn").disabled = false;
    document.getElementById("validateBtn").disabled = true;
    document.getElementById("tdepicnum").innerHTML = "";
  }

  function reValidate() {
    document.getElementById("executeBtn").disabled = true;
    document.getElementById("validateBtn").disabled = false;  
  }

</script>
</head>
<body onload="populatePage();">

   <div><h3 align="center">GitHub Enterprise - User Access Tasks</h1></div>
   <table width="75%" align="center" frame="box">
      <form name="changeReq">
      <tr><td width="262px"><a href="/tasks/ghe-endofmonth.aspx">Reset</a></td><td id="tdepicnum"></td></tr>
      <tr><td width="262px">Github Task Owner</td><td><select id="assignee">
<!-- #include file="/tasks/ghe-assignees.html" -->
                                             </select></td></tr>
       <tr><td width="162px">When</td><td>Date:<input size="50" type="text" value="" id="date"/></td></tr>
       <tr><td width="262px">Github MileStone</td><td><select id="milestone">
<!-- #include file="/tasks/ghe-milestones.html" -->
                                             </select></td></tr>
      <tr><td width="262px">Github Pipeline</td><td><select id="pipeline">
<!-- #include file="/tasks/ghe-pipelines.html" -->
                                             </select></td></tr>
      <tr><td width="262px">Github Label1(For Epic and all Tasks)</td><td><select id="label1">
<!-- #include file="/tasks/ghe-labels.html" -->
                                             </select></td></tr>
      <tr><td width="262px">Github Label2(For Epic and all Tasks)</td><td><select id="label2">
<!-- #include file="/tasks/ghe-labels.html" -->
                                             </select></td></tr>   

      
      <tr><td><button id="validateBtn" type="button" onclick="validate();">Validate</button></form></td>
      <td>
         <form id="form1" method="post" runat="server">
	    <input type="hidden" name="powershellHdn" id="powershellHdn" runat="server" value="C:\inetpub\wwwroot\tasks\ghe-useraccess.ps1"/> 
	    <input type="hidden" name="redirectHdn" id="redirectHdn" runat="server" value="/tasks/ghe-useraccess.aspx"/> 
	    <input type="hidden" name="payloadHdn" id="payloadHdn" runat="server" value="{a:1,b:2}"/> 
	    <asp:Button id="executeBtn" runat="server" text="Submit" onclick="Execute"  onclientclick="disable();" usesubmitbehavior="false" />
         </form>
      </td>
      </tr>
   </table>

   <br><br>
   <table width="75%" align="center" frame="box">
      <tr><td width="262px"><td></td></tr>
      <tr><td width="262px"><td><b>TASKS TO BE CREATED</b></td></tr>
      <tr><td width="262px"><td>EPIC: User Access Quarterly Revalidation :<i>Date</i></td></tr>
      <tr><td width="262px"><td>Softlayer User Access Quarterly Revalidation :<i>Date</i></td></tr>
      <tr><td width="262px"><td>W3-communities User Access Quarterly Revalidation :<i>Date</i></td></tr>
      <tr><td width="262px"><td>Veeam User Access Quarterly Revalidation :<i>Date</i></td></tr>
      <tr><td width="262px"><td>VMWare User Access Quarterly Revalidation :<i>Date</i></td></tr>
      <tr><td width="262px"><td>Pingdom User Access Quarterly Revalidation :<i>Date</i></td></tr>
      <tr><td width="262px"><td>Zabbix User Access Quarterly Revalidation :<i>Date</i></td></tr>
      <tr><td width="262px"><td>Network User Access Quarterly Revalidation :<i>Date</i></td></tr>
      <tr><td width="262px"><td>Salesforce User Access Quarterly Revalidation :<i>Date</i></td></tr>
      <tr><td width="262px"><td>ServiceNow User Access Quarterly Revalidation :<i>Date</i></td></tr>
      <tr><td width="262px"><td>Github User Access Quarterly Revalidation :<i>Date</i></td></tr>
      <tr><td width="262px"><td>Pagerduty User Access Quarterly Revalidation :<i>Date</i></td></tr>
      <tr><td width="262px"><td>SOS User Access Quarterly Revalidation :<i>Date</i></td></tr>
      <tr><td width="262px"><td>Customer Environment User Access Quarterly Revalidation :<i>Date</i></td></tr>
   </table>

</body>
</html>