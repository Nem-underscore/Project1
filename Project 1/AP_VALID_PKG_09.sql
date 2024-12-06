
create or replace package AP_VALID_PKG_09 as
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Package for Inserting Data from Staging table to Interface Table
-- Package Specification and Body AP_VALID_PKG_09
-- History----Version---Author
-- 11/9/24   1.0      Jacob
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- This procedure will validate and Insert data into Accounts Payable table
   
   Procedure main (p_errbuf  OUT NOCOPY Varchar2,
                   p_retcode OUT NOCOPY Number);
               
end AP_VALID_PKG_09;
