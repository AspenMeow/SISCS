# SISCS View

## StudentTermLegacyLevel.sql is for student term reporting view

## Revision History
1. 9/3/20 First Draft with both sets of flags variables. Student Level was coded based on the plan suffix (needs revision)
2. 9/15/20 Change of the ordering for the enrollment status. Withdraw needs to be considerred prior to course actions.
3. 9/21/20 Add COMP_EXAM_COMPLETED and COMP_EXAM_CMPL_DATE (need to vet the key on acad prog?).
4. 9/28/20 Add EDW_ACTV_IND
5. 10/01/20 change logics for leaving blank for flags variables related to primary career. Those n/a rows (either because not enrolled or non-primary career) are given blanks. Change a couple of variable names too (e.g Fall Entering cohort)
6. 10/02/20 change logic for legacy student level, now use degree breadown for non and CGRT; Add admit basis table for admit type.Add variables First_Prim_Ugrd_Flag, First_Prim_at_GRAD_Masters, First_Prim_at_GRAD_Doctoral,Entry_Status_Code