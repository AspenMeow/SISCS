# SISCS View

## StudentTermLegacyLevel.sql is for student term reporting view
## StudentClass.sql is for student term reporting view


<span style="color:red"> **Revision need to make change on enrollment status to make it independent of acad career.** </span>

## Revision History
1. 9/3/20 First Draft with both sets of flags variables. Student Level was coded based on the plan suffix (needs revision)
2. 9/15/20 Change of the ordering for the enrollment status. Withdraw needs to be considerred prior to course actions.
3. 9/21/20 Add COMP_EXAM_COMPLETED and COMP_EXAM_CMPL_DATE (need to vet the key on acad prog?).
4. 9/28/20 Add EDW_ACTV_IND
5. 10/01/20 change logics for leaving blank for flags variables related to primary career. Those n/a rows (either because not enrolled or non-primary career) are given blanks. Change a couple of variable names too (e.g Fall Entering cohort)
6. 10/02/20 change logic for legacy student level, now use degree breadown for non and CGRT; Add admit basis table for admit type.Add variables First_Prim_Ugrd_Flag, First_Prim_at_GRAD_Masters, First_Prim_at_GRAD_Doctoral,Entry_Status_Code
7. 10/02/20 change first term in plan into the strm value, add three types of residency (jaime requested)
8. 10/06/20 fix residency logic and fix the milestone subquery
9. 10/07/20 change name from enrollment status to enrollment_status; degree_career to career_degree; take out a.PRIMARY_CAR_FLAG is null from main where statement;change max effect = subquery in line 378; change milestone include blank for non-applicable