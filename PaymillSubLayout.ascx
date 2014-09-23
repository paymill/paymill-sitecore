﻿<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="PaymillSubLayout.ascx.cs"
    Inherits="Paymill.Sitecore.Sublayouts.PaymentSublayout" %>

<div>Sample Paymill Web Control</div>
<div class="payment_errors">&nbsp;</div>
<fieldset>
    <legend></legend>
    <label for="card-number" class="card-number-label field-left"></label>
    <asp:TextBox ID="tbCardNumber" class="card-number field-left" runat="server"
        placeholder="**** **** **** ****" MaxLength="19" />
    <label for="card-expiry" class="card-expiry-label field-right"></label>
    <asp:TextBox ID="tbcardExpiry" class="card-expiry field-right" runat="server"
        placeholder="MM/YY" MaxLength="7" />
</fieldset>
<fieldset>
    <legend></legend>
    <label for="card-holdername" class="card-holdername-label field-left"></label>
    <asp:TextBox ID="tbCcardHoldername" class="card-holdername field-left" placeholder="Card Holder" runat="server" />
    <label for="card-cvc" class="field-right">
        <span class="card-cvc-label"></span>
    </label>
    <asp:TextBox ID="tbCardCvc" class="card-cvc field-right" runat="server"
        placeholder="CVC" MaxLength="4" />
</fieldset>
<fieldset>
    <legend></legend>
    <label for="amount" class="amount-label field-left"></label>
    <asp:TextBox ID="tbAmount" class="amount field-left" Text="10"
        name="amount" runat="server" />
    <label for="currency" class="currency-label field-right"></label>
    <asp:TextBox ID="tbCurrency" class="currency field-right" value="EUR" name="currency" runat="server" />
</fieldset>
<fieldset id="buttonWrapper">
    <legend></legend>
    <button id="paymill-submit-button" class="submit-button btn btn-primary" type="button">Submit</button>
    <asp:Button ID="btnSubmit" runat="server" Text="Submit" Style="display: none" OnClick="btnSubmit_Click" />
</fieldset>
<asp:HiddenField ID="hToken" runat="server" />

<script type="text/javascript">
    var PAYMILL_PUBLIC_KEY = 'YOUR PUBLIC KEY';
    var VALIDATE_CVC = true;

    $.noConflict();
    jQuery(document).ready(function ($) {
        var doc = document;
        var body = $(doc.body);
        $('.card-number').keyup(function () {
            var brand = paymill.cardType($('.card-number').val());
            brand = brand.toLowerCase();
            $(".card-number")[0].className = $(".card-number")[0].className.replace(/paymill-card-number-.*/g, '');
            if (brand !== 'unknown') {
                $('#card-number').addClass("paymill-card-number-" + brand);
            }

            if (brand !== 'maestro') {
                VALIDATE_CVC = true;
            } else {
                VALIDATE_CVC = false;
            }
        });

        $('.card-expiry').keyup(function () {
            if (/^\d\d$/.test($('.card-expiry').val())) {
                text = $('.card-expiry').val();
                $('.card-expiry').val(text += "/");
            }
        });


        function PaymillResponseHandler(error, result) {
            if (error) {
                $(".payment_errors").text(error.apierror);
                $(".payment_errors").css("display", "inline-block");
            } else {
                $(".payment_errors").css("display", "none");
                $(".payment_errors").text("");
                var form = $("#payment-form");
                // Token
                var token = result.token;
                var tokenFieldId = '<%= hToken.ClientID %>';
                 $('#' + tokenFieldId).val(token);
                 var _id = $('#' + '<%= btnSubmit.ClientID %>').attr("name");
                    __doPostBack(_id.replace("_", "$"), '');
                }
                $(".submit-button").removeAttr("disabled");
            }

         $('#paymill-submit-button').click(function () {
             $('.submit-button').attr("disabled", "disabled");

             paymenttype = $('.switch_button_active').length ? $('.switch_button_active').val() : 'cc';
             var expiry = $('.card-expiry').val();
             expiry = expiry.split("/");
             if (expiry[1] && (expiry[1].length <= 2)) {
                 expiry[1] = '20' + expiry[1];
             }
             if (false === paymill.validateExpiry(expiry[0], expiry[1])) {
                 $(".payment_errors").text("invalid-card-expiry-date");
                 $(".payment_errors").css("display", "inline-block");
                 $(".submit-button").removeAttr("disabled");
                 return false;
             }
             var params = {
                 amount_int: $('.amount').val() * 100,  // E.g. "15" for 0.15 Eur
                 currency: $('.currency').val(),    // ISO 4217 e.g. "EUR"
                 number: $('.card-number').val(),
                 exp_month: expiry[0],
                 exp_year: expiry[1],
                 cvc: $('.card-cvc').val(),
                 cardholder: $('.card-holdername').val()
             };

             paymill.createToken(params, PaymillResponseHandler);
             event.preventDefault();
         });
     });

</script>
