/* First we create the package body */
create or replace package body AP_VALID_PKG_09 as

/* Then we define global variables */
   gn_request_id       NUMBER ; 
   gn_user_id          NUMBER ;
   gn_org_id           NUMBER ;
   gn_organization_id  NUMBER ; 
   gc_val_status       VARCHAR2 (10) := 'VALIDATED';
   gc_err_status       VARCHAR2 (10) := 'ERROR';
   gc_new_status       VARCHAR2 (10) := 'NEW';


/* Then we create the main procedure */
Procedure main (p_errbuf  OUT NOCOPY Varchar2,
                p_retcode OUT NOCOPY Number) is

/* Then we define global variables */
   gn_request_id       NUMBER ; 
   gn_user_id          NUMBER ;
   gn_org_id           NUMBER ;
   gn_organization_id  NUMBER ; 
   gc_val_status       VARCHAR2 (10) := 'VALIDATED';
   gc_err_status       VARCHAR2 (10) := 'ERROR';
   gc_new_status       VARCHAR2 (10) := 'NEW';

/* Then we create the first cursor. This will be what we use to point to the right columns when creating the headers. */
Cursor cur_ap_invoice_header IS
    SELECT distinct
        XAPIS.invoice_type,
        XAPIS.invoice_num,
        XAPIS.curr_code,
        XAPIS.vendor_number,
        XAPIS.vendor_site,
        XAPIS.payment_term,
        XAPIS.source,
        XAPIS.header_amount
    FROM ap_invoice_iface_stg_09 XAPIS
    ;

/* Next we create the cursor used to point the invoice lines to where they need to get data */
Cursor cur_ap_invoice_lines (
    p_invoice_num    IN VARCHAR2,
    p_vendor_number  IN VARCHAR2,
    p_invoice_type   IN VARCHAR2
) IS
    SELECT XAPIS.*
    FROM ap_invoice_iface_stg_09 XAPIS
    WHERE XAPIS.invoice_num = p_invoice_num
      AND XAPIS.vendor_number = p_vendor_number
      AND XAPIS.invoice_type = p_invoice_type;

/* Next we create the local variables */
ln_ap_header_id      NUMBER;
ln_ap_line_id        NUMBER;
counter              NUMBER := 0;

/* We now start the code executable section */
begin
    /* Initialize the Multi-Org (MO) environment for the application  */
    mo_global.init('PO');

    /* Set the security policy context for the current session using the user ID from the profile option */
    mo_global.set_policy_context('S', FND_PROFILE.VALUE('USER_ID'));

    /* Write the user ID to the output file, useful for logging or debugging */
    fnd_file.put_line(fnd_file.output, FND_PROFILE.VALUE('USER_ID'));

    /* Assign the current concurrent request ID to the variable gn_request_id */
    gn_request_id := FND_GLOBAL.CONC_REQUEST_ID;

    /* Assign the user ID from the profile option to gn_user_id, defaulting to -1 if the user ID is null */
    gn_user_id := nvl(FND_PROFILE.VALUE('USER_ID'), -1);

    /* Assign the organization ID from the profile option to gn_org_id, defaulting to 204 if the organization ID is null */
    gn_org_id := nvl(FND_PROFILE.VALUE('ORG_ID'), 204);

    /* Assign the sales order organization ID from the profile option to gn_organization_id */
    gn_organization_id := TO_NUMBER(OE_PROFILE.VALUE('SO_ORGANIZATION_ID'));



    /* Here we set up the loop for the invoice headers table */
    for i in cur_ap_invoice_header loop
        counter := 0;

        /* We use a sequence to create the headers interface id */
        select AP_INVOICES_INTERFACE_S.nextval
        into ln_ap_header_id
        from dual;

        /* The following insert statement will insert lines into the invoice interface table, creating the headers */
        INSERT INTO ap_invoices_interface (
            invoice_id,
            INVOICE_TYPE_LOOKUP_CODE,
            INVOICE_NUM,
            PAYMENT_CURRENCY_CODE,
            VENDOR_NUM,
            VENDOR_SITE_CODE,
            SETTLEMENT_PRIORITY,
            INVOICE_AMOUNT,
            org_id,
            created_by,
            creation_date,
            last_update_login,
            last_updated_by,
            last_update_date
        ) VALUES (
            ln_ap_header_id,
            i.invoice_type,
            i.invoice_num,
            i.curr_code,
            i.vendor_number,
            i.vendor_site,
            i.payment_term,
            i.header_amount,  -- Ensure this matches the column name INVOICE_AMOUNT
            gn_org_id,
            gn_user_id,
            SYSDATE,
            gn_user_id,
            gn_user_id,
            SYSDATE
        );

        /* Next is the for loop which inserts the lines into the ap_invoice_lines_interface table */
        FOR j IN cur_ap_invoice_lines (
            p_invoice_num => i.invoice_num,
            p_vendor_number => i.vendor_number,
            p_invoice_type => i.invoice_type
        ) LOOP
            SELECT ap_invoice_lines_interface_s.nextval
            INTO ln_ap_line_id
            FROM DUAL;

            counter := counter + 1;

            INSERT INTO ap_invoice_lines_interface (
                INVOICE_ID,
                INVOICE_LINE_ID,
                LINE_NUMBER,
                description,
                AMOUNT,
		
                org_id,
                created_by,
                creation_date,
                last_update_login,
                last_updated_by,
                last_update_date
            ) VALUES (
                ln_ap_header_id,
                ln_ap_line_id,
		counter,
		j.description,
                j.line_amount,
                gn_org_id,
                gn_user_id,
                SYSDATE,
                gn_user_id,
                gn_user_id,
                SYSDATE
            );
        END LOOP;
    END LOOP;

    /* Commit the transaction */
    commit;
end main;

end AP_VALID_PKG_09;
