/**
 * The contents of this file are subject to the OpenMRS Public License
 * Version 1.0 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://license.openmrs.org
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * Copyright (C) OpenMRS, LLC.  All Rights Reserved.
 */

/**
 * This is the JavaScript file which controls the client interaction on
 * registrationForm.jsp page. It heavily uses jQuery and hence jQuery.js
 * should be supplied to the page for this JavaScript to work.
 */

var reg_patientFound = false;
var finishedSearching = false;
var enterPressed = false;
var page;

// Executes when page completes loading.
// 1.) Set focus on search textfield
// 2.) Apply datepicker component on textfield with id i18n. Requires jQueryUI
$(document).ready(function() {
    $("#searchField").focus();
    $("#i18n").datepicker($.extend({},
        $.datepicker.regional[''], {
            showStatus: true,
            showOn: "both",
            buttonImage: "/openmrs/moduleResources/amrsregistration/images/calendar.gif",
            buttonImageOnly: true
        }));
});

//Executes when keypress occurs on search textfield.
function searchPhrase(e){
    e = e || window.event;
    ch = e.which || e.keyCode;
    if( ch != null) {
        //____/*normal numbers*/        /*numpad numbers*/          /*characters*/           /* -/_ in moz||ie||opera */  /*backspace*/  /*del*/
        if( (ch >= 48 && ch <= 57) || (ch >= 96 && ch <= 105) || (ch >= 65 && ch <= 90) || (ch==109 || ch==189 || ch==45) || (ch==8) || (ch==46)){
            finishedSearching = false;
            enterPressed = false;
            setTimeout("loadSearchResults(1)",500);
        }
        else if(ch==13){
            enterPressed = true;
            if(finishedSearching){
                gotoSummary();
            }
        }
        else if(ch==27){
            $("#searchField").attr('value','');
        }
    }
}

//Loades the RegistrationSearchServlet and Displays Search Results at div:SearchResults
function loadSearchResults(page){
    this.page = page;
    var searchWord = $("#searchField").attr("value");
    $("#loadingIcon").show();
    $.ajax({
        type:"POST",
        url:"/openmrs/moduleServlet/amrsregistration/RegistrationSearchServlet",
        data:"phrase="+searchWord+"&pageNum="+page,
        success: function(output){
            $("#searchResults").html(output);
        }
    });
}

//Shows the patient results in InfoBar
function searchSummary(){
    var totalRows = $('.searchTBody tr').size();
    if(totalRows>11){
        $("#patientsInView").html(((page-1)*10+1)+'-'+page*10);
    }
    else if(page>1){
        $("#patientsInView").html(((page-1)*10+1)+'-'+(((page-1)*10)+totalRows-2));
    }
    else if(page==1 && reg_patientFound==false){
        $("#patientsInView").html(0);
    }
    else{
        $("#patientsInView").html(totalRows);
    }
}

//Opens patient dashboard after Enter Kkey Pressed
function gotoSummary(){
    if(reg_patientFound){
        var patientIdentifier = trim($(".dashboardLink").html());
        window.location.href = "/openmrs/module/amrsregistration/registrationSummary.list?patientIdentifier="+patientIdentifier;
    }
    else{
        alert('No Patient Found. Search again.');
    }
}

//Called by the RegistrationSearchServlet when Results Table Finish Loading
function finishedSearch(){
    searchSummary();
    finishedSearching = true;
    $("#loadingIcon").hide();
    $("#searchField").focus();
    if(enterPressed){
        gotoSummary();
    }
}

//Called by RegistrationSearchServlet when Patient Results >0
function patientFound(){
    reg_patientFound = true;
}

//Called by RegistrationSearchServlet when Patient Results <0
function patientNotFound(){
    reg_patientFound = false;
}

//Moves the Search Field Text to Patient Name Field for Creating New Patient
function addNew(){
    var searchWord = $("#searchField").attr("value");
    $("#searchField").attr("value","");
    $("#searchResults").html(" ");
    $('#patientName').attr("value",searchWord);
    $('#patientName').focus();
}

//Check If User has Entered Values to Create New Patient
function validateRegistration(){
    if($("#patientName").attr('value')==""){
        $("#nameError").css('display','block');
        return false;
    }
    if($("#i18n").attr('value')=="" && $("#age").attr('value')==""){
        $("#birthdateError").css('display','block');
        return false;
    }
    var currentDate = new Date();
    if(currentDate < $("#i18n").datepicker('getDate')){
        $("#birthdateError").css('display','block');
        return false;
    }
    if($("#gender-M").attr('checked')==false && $("#gender-F").attr('checked')==false){
        $("#genderError").css('display','block');
        return false;
    }
    return true;
}

//Clear errors from Textfields
function clearError(param){
    if(param=='name'){
        $("#nameError").css('display','none');
    }
    else if(param=='birthdate'){
        $("#birthdateError").css('display','none');
        var currentDate = new Date();
        ms = currentDate.valueOf() - $("#i18n").datepicker('getDate').valueOf();
        var minutes = ms / 1000 / 60;
        var hours = minutes / 60;
        var days = hours / 24;
        var years = days/365;
        if(Math.floor(years) == 0)
            $("#age").attr('value','< 1');
        else
            $("#age").attr('value',Math.floor(years));
    }
    else if(param=='gender'){
        $("#genderError").css('display','none');
    }
}

//Trims a string of any whitespaces before or after
function trim(str)
{
    while(str.charAt(0) == (" ")){
        str = str.substring(1);
    }
    while(str.charAt(str.length-1) == " " ) {
        str = str.substring(0,str.length-1);
    }
    return str;
}