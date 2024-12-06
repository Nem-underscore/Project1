DROP TABLE AP_INVOICE_IFACE_STG_09;
CREATE TABLE ap_invoice_iface_stg_09 (
                                  invoice_type                   VARCHAR2 ( 50 )
                                , invoice_num                    VARCHAR2 ( 20 )
                                , curr_code                      VARCHAR2 ( 10 )
                                , vendor_number                  VARCHAR2 ( 30 )
                                , vendor_site                    VARCHAR2 ( 40 )
                                , payment_term                   VARCHAR  ( 15 )
                                , line_number                    NUMBER
                                , description                    VARCHAR2 ( 250 )
                                , header_amount                  NUMBER
                                , line_amount                    NUMBER
                                , org_id                         NUMBER
                                , source                         VARCHAR2 ( 100 ) DEFAULT 'SUNDAR'
                                , distribution_set_name          VARCHAR2 ( 100 ) DEFAULT 'PUB'
                                , dist_set_id                    NUMBER
                                , vendor_id                      NUMBER
                                , vendor_site_id                 NUMBER
                                , payment_term_id                NUMBER
                                , source_id                      NUMBER
                                , created_by                     NUMBER
                                , creation_date                  DATE
                                , last_updated_by                NUMBER
                                , last_updated_date              DATE
                                , last_updated_login             NUMBER
                                , request_id                     NUMBER
                                , record_status                  VARCHAR2  ( 10 )
                                , error_message                  VARCHAR2  ( 2000 )
                                );