USE [ClinicPro]
GO
/****** Object:  StoredProcedure [dbo].[SpR_InsuranceAuditReport]    Script Date: 1/1/2020 12:16:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SpR_InsuranceAuditReport] 
			 @StDate datetime,
			@EndDate datetime,
			@CategoryID nvarchar,
			@DoctorID nvarchar
	
AS
BEGIN
	SET NOCOUNT ON;

    -- Insert statements for procedure here
Select Invoice.PatientID as FileNumber , Invoice.InvoiceID as InvoiceNumber , Invoice.InvoiceDate as InvoiceDate , Doctors.Name as DoctorName , feecategory.Category

, coalesce(substring(
        (
            Select ','+ST1.Code  AS [text()]
            From dbo.InvoiceDetail ST1
            Where ST1.InvoiceID = Invoice.InvoiceID
      
            For XML PATH ('')
        ), 2, 1000),'') as [CPT],

		  coalesce(substring(
        (
            Select ','+ST1.ICD9  AS [text()]
            From dbo.PatientClaimFormDetail ST1
            Where ST1.WaitingID = Invoice.VisitID
           
            For XML PATH ('')
        ), 2, 1000),'') as [ICD10]


From Invoice  inner join Patients on patients.PatientID = Invoice.PatientID
									  inner join doctors on doctors.DoctorID = Invoice.DoctorID
									  inner join FeeCategory on FeeCategory.CategoryID = Invoice.Type
									  inner join InvoiceDetail on InvoiceDetail.InvoiceID = Invoice.InvoiceID

									
			where	Invoice.InvoiceDate between @StDate and @EndDate
			AND  (feecategory.category = @CategoryID OR @CategoryID = 0 )
			AND (Doctors.DoctorID = @DoctorID OR @DoctorID = 0)
			  
END
