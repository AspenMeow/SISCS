 
      
        SELECT
            p_person.emplid,
           
            perm_address.effdt                       AS perm_effdt,
            rtrim((perm_address.address1
                   || ', '
                   || perm_address.address2), ' ,') AS perm_addr,
            perm_address.city                        AS perm_city,
            perm_address.state                       AS perm_state,
            perm_address.postal                      AS perm_postal,
            perm_address.country                     AS perm_country,
            curr_address.effdt                       AS curr_effdt,
            rtrim((curr_address.address1
                   || ', '
                   || curr_address.address2), ' ,') AS curr_addr,
            curr_address.city                        AS curr_city,
            curr_address.state                       AS curr_state,
         curr_address.postal                      AS curr_postal,
            curr_address.country                     AS curr_country,
            hous_address.effdt                       AS hous_effdt,
            rtrim((hous_address.address1
                   || ', '
                   || hous_address.address2), ' ,') AS hous_addr,
            hous_address.city                        AS hous_city,
            hous_address.state                       AS hous_state,
            hous_address.postal                      AS hous_postal,
            hous_address.country                     AS hous_country,
            altm_address.effdt                       AS altm_effdt,
            rtrim((altm_address.address1
                   || ', '
                   || altm_address.address2), ' ,') AS altm_addr,
            altm_address.city                        AS altm_city,
            altm_address.state                       AS altm_state,
            altm_address.postal                      AS altm_postal,
            altm_address.country                     AS altm_country,
            dipm_address.effdt                       AS dipm_effdt,
            rtrim((dipm_address.address1
                   || ', '
                   || dipm_address.address2), ' ,') AS dipm_addr,
            dipm_address.city                        AS dipm_city,
            dipm_address.state                       AS dipm_state,
            dipm_address.postal                      AS dipm_postal,
            dipm_address.country                     AS dipm_country,
            intl_address.effdt                       AS intl_effdt,
            rtrim((intl_address.address1
                   || ', '
                   || intl_address.address2), ' ,') AS intl_addr,
            intl_address.city                        AS intl_city,
            intl_address.state                       AS intl_state,
            intl_address.postal                      AS intl_postal,
            intl_address.country                     AS intl_country,
            nvl(p_personal_phone.phone_type, ' ') AS pref_phone_type,
            p_personal_phone.phone                   AS pref_phone,
            nvl(p_email_addresses.e_addr_type, ' ') AS pref_email_type,
            p_email_addresses.email_addr             AS pref_email_addr,
            p_email_addresses_camp.email_addr        AS camp_email_addr,
            p_email_addresses_camp.pref_email_flag   AS camp_pref_flag,
             (case when hous_address.address1 is not null then rtrim((hous_address.address1
                   || ', '
                   || hous_address.address2), ' ,') 
                   when altm_address.address1 is not null then 
                    rtrim((altm_address.address1
                   || ', '
                   || altm_address.address2), ' ,')
                   when curr_address.address1 is not null then
                   rtrim((curr_address.address1
                   || ', '
                   || curr_address.address2), ' ,')
                   when perm_address.address1 is not null then 
                   rtrim((perm_address.address1
                   || ', '
                   || perm_address.address2), ' ,')
                   end
                   ) as BESTCURR_ADDR,
                COALESCE (hous_address.city, altm_address.city,curr_address.city,perm_address.city) as BESTCURR_CITY,
                COALESCE (hous_address.country, altm_address.country,curr_address.country,perm_address.country) as BESTCURR_COUNTRY,
                 COALESCE (hous_address.effdt, altm_address.effdt,curr_address.effdt,perm_address.effdt) as BESTCURR_effdt,
                   COALESCE (hous_address.postal, altm_address.postal,curr_address.postal,perm_address.postal) as BESTCURR_postal,
                        COALESCE (hous_address.state, altm_address.state,curr_address.state,perm_address.state) as BESTCURR_state,
             (case when hous_address.address1 is not null then rtrim((hous_address.address1
                   || ', '
                   || hous_address.address2), ' ,') 
                   when altm_address.address1 is not null then 
                    rtrim((altm_address.address1
                   || ', '
                   || altm_address.address2), ' ,')
                    when perm_address.address1 is not null then 
                   rtrim((perm_address.address1
                   || ', '
                   || perm_address.address2), ' ,')
                   when curr_address.address1 is not null then
                   rtrim((curr_address.address1
                   || ', '
                   || curr_address.address2), ' ,')    
                   end
                   ) as BESTPERM_ADDR,
                COALESCE (hous_address.city, altm_address.city,perm_address.city,curr_address.city) as BESTPERM_CITY,
                COALESCE (hous_address.country, altm_address.country,perm_address.country,curr_address.country) as BESTPERM_COUNTRY,
                 COALESCE (hous_address.effdt, altm_address.effdt,perm_address.effdt,curr_address.effdt) as BESTPERM_effdt,
                   COALESCE (hous_address.postal, altm_address.postal,perm_address.postal,curr_address.postal) as BESTPERM_postal,
                        COALESCE (hous_address.state, altm_address.state,perm_address.state,curr_address.state) as BESTPERM_state
        FROM
            ( (
                SELECT
                    *
                FROM
                    siscs.p_person_av
                WHERE
                    edw_actv_ind = 'Y' and edw_curr_ind='Y'
            ) p_person
            LEFT OUTER JOIN (
                SELECT
                    p_addresses.emplid,
                    p_addresses.effdt,
                    p_addresses.address1,
                    p_addresses.address2,
                    p_addresses.city,
                    p_addresses.state,
                    p_addresses.postal,
                    p_addresses.country
                FROM
                    siscs.p_addresses_av p_addresses
                WHERE
                    p_addresses.edw_actv_ind = 'Y' and edw_curr_ind='Y'
                    AND p_addresses.address_type = 'PERM'
                    AND p_addresses.eff_status = 'A'
                    AND (p_addresses.effdt = (
                        SELECT
                            MAX(a2.effdt)
                        FROM
                            siscs.p_addresses_av a2
                        WHERE
                            a2.edw_actv_ind = 'Y'  and a2.edw_curr_ind='Y'
                            AND a2.emplid = p_addresses.emplid
                            AND a2.address_type = p_addresses.address_type
                            AND p_addresses.effdt <= sysdate
                    ) OR p_addresses.effdt IS NULL)
            ) perm_address ON p_person.emplid = perm_address.emplid
            LEFT OUTER JOIN (
                SELECT
                    b.emplid,
                    b.effdt,
                    b.address1,
                    b.address2,
                    b.city,
                    b.state,
                    b.postal,
                    b.country
                FROM
                    siscs.p_addresses_av b
                WHERE
                    b.edw_actv_ind = 'Y' and edw_curr_ind='Y'
                    AND b.address_type = 'CURR'
                    AND b.eff_status = 'A'
                    AND (b.effdt = (
                        SELECT
                            MAX(b2.effdt)
                        FROM
                            siscs.p_addresses_av b2
                        WHERE
                            b2.edw_actv_ind = 'Y' and b2.edw_curr_ind='Y'
                            AND b2.emplid = b.emplid
                            AND b2.address_type = b.address_type
                            AND b.effdt <= sysdate
                    )OR b.effdt IS NULL)
            ) curr_address ON p_person.emplid = curr_address.emplid
            LEFT OUTER JOIN (
                SELECT
                    c.emplid,
                    c.effdt,
                    c.address1,
                    c.address2,
                    c.city,
                    c.state,
                    c.postal,
                    c.country
                FROM
                    siscs.p_addresses_av c
                WHERE
                    c.edw_actv_ind = 'Y' and edw_curr_ind='Y'
                    AND c.address_type = 'HOUS'
                    AND c.eff_status = 'A'
                    AND (c.effdt = (
                        SELECT
                            MAX(c2.effdt)
                        FROM
                            siscs.p_addresses_av c2
                        WHERE
                            c2.edw_actv_ind = 'Y' and c2.edw_curr_ind='Y'
                            AND c2.emplid = c.emplid
                            AND c2.address_type = c.address_type
                            AND c.effdt <= sysdate
                    )OR c.effdt IS NULL)
            ) hous_address ON p_person.emplid = hous_address.emplid
            LEFT OUTER JOIN (
                SELECT
                    d.emplid,
                    d.effdt,
                    d.address1,
                    d.address2,
                    d.city,
                    d.state,
                    d.postal,
                    d.country
                FROM
                    siscs.p_addresses_av d 
                WHERE
                    d.edw_actv_ind = 'Y' and d.edw_curr_ind='Y'
                    AND d.address_type = 'ALTM'
                    AND d.eff_status = 'A'
                    AND (d.effdt = (
                        SELECT
                            MAX(d2.effdt)
                        FROM
                            siscs.p_addresses_av d2
                        WHERE
                            d2.edw_actv_ind = 'Y' and d2.edw_curr_ind='Y'
                            AND d2.emplid = d.emplid
                            AND d2.address_type = d.address_type
                            AND d.effdt <= sysdate
                    )  OR d.effdt IS NULL)
            ) altm_address ON p_person.emplid = altm_address.emplid
            LEFT OUTER JOIN (
                SELECT
                    e.emplid,
                    e.effdt,
                    e.address1,
                    e.address2,
                    e.city,
                    e.state,
                    e.postal,
                    e.country
                FROM
                    siscs.p_addresses_av e
                WHERE
                    e.edw_actv_ind = 'Y' and e.edw_curr_ind='Y'
                    AND e.address_type = 'DIPM'
                    AND e.eff_status = 'A'
                    AND (e.effdt = (
                        SELECT
                            MAX(e2.effdt)
                        FROM
                            siscs.p_addresses_av e2
                        WHERE
                            e2.edw_actv_ind = 'Y' and e2.edw_curr_ind='Y'
                            AND e2.emplid = e.emplid
                            AND e2.address_type = e.address_type
                            AND e.effdt <= sysdate
                    )or e.effdt is null )
            ) dipm_address ON p_person.emplid = dipm_address.emplid
            LEFT OUTER JOIN (
                SELECT
                    f.emplid,
                    f.effdt,
                    f.address1,
                    f.address2,
                    f.city,
                    f.state,
                    f.postal,
                    f.country
                FROM
                    siscs.p_addresses_av f
                WHERE
                    f.edw_actv_ind = 'Y' and f.edw_curr_ind='Y'
                    AND f.address_type = 'INTL'
                    AND f.eff_status = 'A'
                    AND (f.effdt = (
                        SELECT
                            MAX(f2.effdt)
                        FROM
                            siscs.p_addresses_av f2
                        WHERE
                            f2.edw_actv_ind = 'Y' and f2.edw_curr_ind='Y'
                            AND f2.emplid = f.emplid
                            AND f2.address_type = f.address_type
                            AND f.effdt <= sysdate
                    )or f.effdt is null )
            ) intl_address ON p_person.emplid = intl_address.emplid
            LEFT OUTER JOIN (
                SELECT
                    *
                FROM
                    siscs.p_personal_phone_av p_personal_phone
                WHERE
                    edw_actv_ind = 'Y' and edw_curr_ind='Y'
            ) p_personal_phone ON p_person.emplid = p_personal_phone.emplid
                                  AND p_personal_phone.pref_phone_flag = 'Y'
            LEFT OUTER JOIN (
                SELECT
                    *
                FROM
                    siscs.p_email_addresses_av
                WHERE
                    edw_actv_ind = 'Y' and edw_curr_ind='Y'
            ) p_email_addresses ON p_person.emplid = p_email_addresses.emplid
                                   AND p_email_addresses.pref_email_flag = 'Y'
            LEFT OUTER JOIN (
                SELECT
                    *
                FROM
                    siscs.p_email_addresses_av
                WHERE
                    edw_actv_ind = 'Y' and edw_curr_ind='Y'
            ) p_email_addresses_camp ON p_person.emplid = p_email_addresses_camp.emplid
                                        AND p_email_addresses_camp.e_addr_type = 'CAMP' )
        WHERE
            EXISTS (
                SELECT
                    'X'
                FROM
                    siscs.p_addresses_av z
                WHERE
                    z.edw_actv_ind = 'Y' and z.edw_curr_ind='Y'
                    AND p_person.emplid = z.emplid
                    AND z.eff_status = 'A'
                    AND (z.effdt = (
                        SELECT
                            MAX(z.effdt)
                        FROM
                            siscs.p_addresses_av z2
                        WHERE
                            z2.edw_actv_ind = 'Y' and  z2.edw_curr_ind='Y'
                            AND z2.emplid = z.emplid
                            AND z2.address_type = z.address_type
                            AND z.effdt <= sysdate
                    )or z.effdt is null )
            )
     --       and  p_person.emplid in ('156333912','126863026','156297326','158749061','159690642','108417322','149697444','139244349','105044362','148452186','150387028')
      
