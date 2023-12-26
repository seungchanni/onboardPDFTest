public with sharing class savePDFController {
 
        public String MstrId{GET;SET;}
        public String PDFNo{GET;SET;}
        public String EFNo{GET;SET;}
        public BOOLEAN SHOW{GET;SET;}
        public BOOLEAN showpdf{GET;SET;}
        public ApexPages.PageReference page2{GET;SET;}
        public String baseURL{GET;SET;}
        public String emailSubject{GET;SET;}
        public String emailBody{GET;SET;}
     
        public PageReference Cancel(){
            PageReference Pdf = NEW PageReference('/'+MstrID);
            pdf.setredirect(TRUE);
            RETURN Pdf;
        }
     
        public savePDFController(ApexPages.StandardController controller){
            baseURL = URL.getOrgDomainUrl().toExternalForm();
            MstrId = ApexPages.currentPage().getParameters().get('id');
        }

        public PageReference Save(){
            PageReference savepage = Page.CustomPDFOnboard;
            PageReference Pdf = NEW PageReference('/'+MstrID);
            savepage.getParameters().put('id',MstrID);
            system.debug('id:- '+MstrID);
            BLOB pdfBlob;
     
            IF (!Test.isRunningTest()) {
                pdfBlob = savepage.getContentAsPDF(); //generate the pdf BLOB
            }
            QuoteDocument quotedoc = new QuoteDocument();
            quotedoc.document = pdfBlob;
            quotedoc.QuoteId = MstrId;
            insert quotedoc;
            RETURN Pdf;
        }

        public PageReference SaveAndSendEmail(){
        // Quote Id로부터 이메일 주소 가져오기
        Quote quote = [SELECT Id, Email FROM Quote WHERE Id = :MstrId LIMIT 1];
        String toAddress = quote.Email;

        // 이메일 메시지 설정
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { toAddress });
        email.setSubject(emailSubject != null ? emailSubject : '견적서 이메일 발송');
        email.setPlainTextBody(emailBody != null ? emailBody : '견적서를 확인해 주세요.');


        // PDF 첨부 파일 추가
        PageReference pdfPage = Page.CustomPDFOnboard;
        pdfPage.getParameters().put('id', MstrId);
        Blob pdfBlob = pdfPage.getContentAsPDF();
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        attach.setFileName('QuotePDF.pdf');
        attach.setBody(pdfBlob);
        email.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });

        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });

        if (results[0].isSuccess()) {
            System.debug('이메일을 성공적으로 보냈습니다.');
            save();
        } 
        else {
            System.debug('이메일 보내기 실패: ' + results[0].getErrors()[0].getMessage());
        }
        PageReference Pdf = NEW PageReference('/'+MstrID);

        RETURN pdf;
        }
     
}