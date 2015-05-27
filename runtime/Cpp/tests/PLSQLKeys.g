/**
 * Oracle(c) PL/SQL 11g Parser  
 *
 * Copyright (c) 2009-2011 Alexandre Porcelli <alexandre.porcelli@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "LICENSE");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
parser grammar PLSQLKeys;

@includes
{
	#include "PTestTraits.hpp"
	#include "PLSQLLexer.hpp"        
}
@namespace { Antlr3Test }

        
// @members{
//     // int  (pANTLR3_COMMON_TOKEN s1, const char* s2)        
//     // {
//     //     return !strcasecmp(s1->getText(s1)->chars, s2);
//     // }
// }

create_key
    :    SQL92_RESERVED_CREATE
    ;
    
replace_key
//  :    {input.LT(1).getText(). ("REPLACE" }?=> REGULAR_ID
    :    { LT(1)->getText() == "REPLACE" }?  => REGULAR_ID
    ;

package_key
    :    { LT(1)->getText() == "PACKAGE" }?=> REGULAR_ID
    ;

body_key
    :    { LT(1)->getText() == "BODY" }? REGULAR_ID
    ;

begin_key
    :    SQL92_RESERVED_BEGIN
    ;

exit_key
    :    { LT(1)->getText() == "EXIT" }? REGULAR_ID
    ;

declare_key
    :    SQL92_RESERVED_DECLARE
    ;

exception_key
    :    SQL92_RESERVED_EXCEPTION
    ;

serveroutput_key
    :    { LT(1)->getText() == "SERVEROUTPUT" }? REGULAR_ID
    ;

off_key
    :    { LT(1)->getText() == "OFF" }? REGULAR_ID
    ;

constant_key
    :    { LT(1)->getText() == "CONSTANT" }? REGULAR_ID
    ;

subtype_key
    :    { LT(1)->getText() == "SUBTYPE" }? REGULAR_ID
    ;

cursor_key//{ LT(1)->getText() == "CURSOR" }? REGULAR_ID
    :    SQL92_RESERVED_CURSOR
    ;

nextval_key
    :    { LT(1)->getText() == "NEXTVAL" }?=> REGULAR_ID
    ;

goto_key
    :    SQL92_RESERVED_GOTO
    ;

execute_key
    :    { LT(1)->getText() == "EXECUTE" }? REGULAR_ID
    ;

immediate_key
    :    { LT(1)->getText() == "IMMEDIATE" }?=> REGULAR_ID
    ;

return_key
    :    { LT(1)->getText() == "RETURN" }? REGULAR_ID
    ;

procedure_key
    :    SQL92_RESERVED_PROCEDURE
    ;

function_key
    :    { LT(1)->getText() == "FUNCTION" }?=> REGULAR_ID
    ;

pragma_key
    :    { LT(1)->getText() == "PRAGMA" }? REGULAR_ID
    ;

exception_init_key
    :    { LT(1)->getText() == "EXCEPTION_INIT" }? REGULAR_ID
    ;

type_key
    :    { LT(1)->getText() == "TYPE" }?=> REGULAR_ID
    ;

record_key
    :    { LT(1)->getText() == "RECORD" }?=> REGULAR_ID
    ;

indexed_key
    :    { LT(1)->getText() == "INDEXED" }? REGULAR_ID
    ;

index_key
    :    PLSQL_RESERVED_INDEX
    ;

percent_notfound_key
    :    { LT(2)->getText() == "NOTFOUND" }?=> PERCENT REGULAR_ID
    ;

percent_found_key
    :    { LT(2)->getText() == "FOUND" }?=> PERCENT REGULAR_ID
    ;

percent_isopen_key
    :    { LT(2)->getText() == "ISOPEN" }?=> PERCENT REGULAR_ID
    ;

percent_rowcount_key
    :    { LT(2)->getText() == "ROWCOUNT" }?=> PERCENT REGULAR_ID
    ;

percent_rowtype_key
    :    { LT(2)->getText() == "ROWTYPE" }?=> PERCENT REGULAR_ID 
    ;

percent_type_key
    :    { LT(2)->getText() == "TYPE" }?=> PERCENT REGULAR_ID
    ;

out_key
    :    { LT(1)->getText() == "OUT" }?=> REGULAR_ID
    ;

inout_key
    :    { LT(1)->getText() == "INOUT" }? REGULAR_ID
    ;

extend_key
    :    { LT(1)->getText() == "EXTEND" }?=> REGULAR_ID
    ;

raise_key
    :    { LT(1)->getText() == "RAISE" }? REGULAR_ID
    ;

while_key
    :    { LT(1)->getText() == "WHILE" }? REGULAR_ID
    ;

loop_key
    :    { LT(1)->getText() == "LOOP" }? REGULAR_ID
    ;

commit_key
    :    { LT(1)->getText() == "COMMIT" }?=> REGULAR_ID
    ;

work_key
    :    { LT(1)->getText() == "WORK" }? REGULAR_ID
    ;

if_key
    :    PLSQL_RESERVED_IF
    ;

elsif_key
    :    PLSQL_NON_RESERVED_ELSIF
    ;

authid_key
    :    { LT(1)->getText() == "AUTHID" }?=> REGULAR_ID
    ;

definer_key
    :    { LT(1)->getText() == "DEFINER" }? REGULAR_ID
    ;

external_key
    :    { LT(1)->getText() == "EXTERNAL" }? REGULAR_ID
    ;

language_key
    :    { LT(1)->getText() == "LANGUAGE" }? REGULAR_ID
    ;

java_key
    :    { LT(1)->getText() == "JAVA" }? REGULAR_ID
    ;

name_key
    :    { LT(1)->getText() == "NAME" }?=> REGULAR_ID
    ;

deterministic_key
    :    { LT(1)->getText() == "DETERMINISTIC" }?=> REGULAR_ID
    ;

parallel_enable_key
    :    { LT(1)->getText() == "PARALLEL_ENABLE" }?=> REGULAR_ID
    ;

result_cache_key
    :    { LT(1)->getText() == "RESULT_CACHE" }?=> REGULAR_ID
    ;

pipelined_key
    :    { LT(1)->getText() == "PIPELINED" }?=> REGULAR_ID
    ;

aggregate_key
    :    { LT(1)->getText() == "AGGREGATE" }? REGULAR_ID
    ;

alter_key
    :    SQL92_RESERVED_ALTER
    ;

compile_key
    :    { LT(1)->getText() == "COMPILE" }? REGULAR_ID
    ; 

debug_key
    :    { LT(1)->getText() == "DEBUG" }? REGULAR_ID
    ;

reuse_key
    :    { LT(1)->getText() == "REUSE" }? REGULAR_ID
    ;

settings_key
    :    { LT(1)->getText() == "SETTINGS" }? REGULAR_ID
    ;

specification_key
    :    { LT(1)->getText() == "SPECIFICATION" }? REGULAR_ID
    ;

drop_key
    :    SQL92_RESERVED_DROP
    ;

trigger_key
    :    { LT(1)->getText() == "TRIGGER" }?=> REGULAR_ID
    ;

force_key
    :    { LT(1)->getText() == "FORCE" }?=> REGULAR_ID
    ;

validate_key
    :    { LT(1)->getText() == "VALIDATE" }? REGULAR_ID
    ;

ref_key
    :    { LT(1)->getText() == "REF" }?=> REGULAR_ID
    ;

array_key
    :    { LT(1)->getText() == "ARRAY" }?=> REGULAR_ID
    ;

varray_key
    :    { LT(1)->getText() == "VARRAY" }?=> REGULAR_ID
    ;

pls_integer_key
    :    { LT(1)->getText() == "PLS_INTEGER" }?=> REGULAR_ID
    ;

serially_reusable_key
    :    { LT(1)->getText() == "SERIALLY_REUSABLE" }?=> REGULAR_ID
    ;

autonomous_transaction_key
    :    { LT(1)->getText() == "AUTONOMOUS_TRANSACTION" }?=> REGULAR_ID
    ;

inline_key
    :    { LT(1)->getText() == "INLINE" }?=> REGULAR_ID
    ;

restrict_references_key
    :    { LT(1)->getText() == "RESTRICT_REFERENCES" }?=> REGULAR_ID
    ;

exceptions_key
    :    { LT(1)->getText() == "EXCEPTIONS" }?=> REGULAR_ID 
    ;

save_key
    :    { LT(1)->getText() == "SAVE" }?=> REGULAR_ID
    ;

forall_key
    :    { LT(1)->getText() == "FORALL" }?=> REGULAR_ID
    ;

continue_key
    :    { LT(1)->getText() == "CONTINUE" }?=> REGULAR_ID
    ;

indices_key
    :    { LT(1)->getText() == "INDICES" }?=> REGULAR_ID
    ;

values_key
    :    SQL92_RESERVED_VALUES
    ;

case_key
    :    SQL92_RESERVED_CASE
    ;

bulk_key
    :    { LT(1)->getText() == "BULK" }?=> REGULAR_ID
    ;

collect_key
    :    { LT(1)->getText() == "COLLECT" }?=> REGULAR_ID
    ;

committed_key
    :    { LT(1)->getText() == "COMMITTED" }? REGULAR_ID
    ;

use_key
    :    { LT(1)->getText() == "USE" }?=> REGULAR_ID
    ;

level_key
    :    { LT(1)->getText() == "LEVEL" }? REGULAR_ID
    ;

isolation_key
    :    { LT(1)->getText() == "ISOLATION" }?=> REGULAR_ID
    ;

serializable_key
    :    { LT(1)->getText() == "SERIALIZABLE" }? REGULAR_ID
    ;

segment_key
    :    { LT(1)->getText() == "SEGMENT" }? REGULAR_ID
    ;

write_key
    :    { LT(1)->getText() == "WRITE" }?=> REGULAR_ID
    ;

wait_key
    :    { LT(1)->getText() == "WAIT" }?=> REGULAR_ID
    ;

corrupt_xid_all_key
    :    { LT(1)->getText() == "CORRUPT_XID_ALL" }?=> REGULAR_ID
    ;

corrupt_xid_key
    :    { LT(1)->getText() == "CORRUPT_XID" }?=> REGULAR_ID
    ;

batch_key
    :    { LT(1)->getText() == "BATCH" }?=> REGULAR_ID
    ;

session_key
    :    { LT(1)->getText() == "SESSION" }?=> REGULAR_ID
    ;

role_key
    :    { LT(1)->getText() == "ROLE" }?=> REGULAR_ID
    ;

constraint_key
    :    { LT(1)->getText() == "CONSTRAINT" }?=> REGULAR_ID
    ;

constraints_key
    :    { LT(1)->getText() == "CONSTRAINTS" }?=> REGULAR_ID
    ;

call_key
    :    { LT(1)->getText() == "CALL" }?=> REGULAR_ID
    ;

explain_key
    :    { LT(1)->getText() == "EXPLAIN" }?=> REGULAR_ID
    ;

merge_key
    :    { LT(1)->getText() == "MERGE" }?=> REGULAR_ID
    ;

plan_key
    :    { LT(1)->getText() == "PLAN" }?=> REGULAR_ID
    ;

system_key
    :    { LT(1)->getText() == "SYSTEM" }?=> REGULAR_ID
    ;

subpartition_key
    :    { LT(1)->getText() == "SUBPARTITION" }?=> REGULAR_ID
    ;

partition_key
    :    { LT(1)->getText() == "PARTITION" }?=> REGULAR_ID
    ;

matched_key
    :    { LT(1)->getText() == "MATCHED" }?=> REGULAR_ID
    ;

reject_key
    :    { LT(1)->getText() == "REJECT" }?=> REGULAR_ID
    ;

log_key
    :    { LT(1)->getText() == "LOG" }?=> REGULAR_ID
    ;

unlimited_key
    :    { LT(1)->getText() == "UNLIMITED" }?=> REGULAR_ID
    ;

limit_key
    :    { LT(1)->getText() == "LIMIT" }?=> REGULAR_ID
    ;

errors_key
    :    { LT(1)->getText() == "ERRORS" }?=> REGULAR_ID
    ;

timestamp_tz_unconstrained_key
    :    { LT(1)->getText() == "TIMESTAMP_TZ_UNCONSTRAINED" }?=> REGULAR_ID
    ;

urowid_key
    :    { LT(1)->getText() == "UROWID" }?=> REGULAR_ID
    ;

binary_float_min_subnormal_key
    :    { LT(1)->getText() == "BINARY_FLOAT_MIN_SUBNORMAL" }?=> REGULAR_ID
    ;

binary_double_min_normal_key
    :    { LT(1)->getText() == "BINARY_DOUBLE_MIN_NORMAL" }?=> REGULAR_ID
    ;

binary_float_max_normal_key
    :    { LT(1)->getText() == "BINARY_FLOAT_MAX_NORMAL" }?=> REGULAR_ID
    ;

positiven_key
    :    { LT(1)->getText() == "POSITIVEN" }?=> REGULAR_ID
    ;

timezone_abbr_key
    :    { LT(1)->getText() == "TIMEZONE_ABBR" }?=> REGULAR_ID
    ;

binary_double_min_subnormal_key
    :    { LT(1)->getText() == "BINARY_DOUBLE_MIN_SUBNORMAL" }?=> REGULAR_ID
    ;

binary_float_max_subnormal_key
    :    { LT(1)->getText() == "BINARY_FLOAT_MAX_SUBNORMAL" }?=> REGULAR_ID
    ;

binary_double_key
    :    { LT(1)->getText() == "BINARY_DOUBLE" }?=> REGULAR_ID
    ;

bfile_key
    :    { LT(1)->getText() == "BFILE" }?=> REGULAR_ID
    ;

binary_double_infinity_key
    :    { LT(1)->getText() == "BINARY_DOUBLE_INFINITY" }?=> REGULAR_ID
    ;

timezone_region_key
    :    { LT(1)->getText() == "TIMEZONE_REGION" }?=> REGULAR_ID
    ;

timestamp_ltz_unconstrained_key
    :    { LT(1)->getText() == "TIMESTAMP_LTZ_UNCONSTRAINED" }?=> REGULAR_ID
    ;

naturaln_key
    :    { LT(1)->getText() == "NATURALN" }?=> REGULAR_ID
    ;

simple_integer_key
    :    { LT(1)->getText() == "SIMPLE_INTEGER" }?=> REGULAR_ID
    ;

binary_double_max_subnormal_key
    :    { LT(1)->getText() == "BINARY_DOUBLE_MAX_SUBNORMAL" }?=> REGULAR_ID
    ;

byte_key
    :    { LT(1)->getText() == "BYTE" }?=> REGULAR_ID
    ;

binary_float_infinity_key
    :    { LT(1)->getText() == "BINARY_FLOAT_INFINITY" }?=> REGULAR_ID
    ;

binary_float_key
    :    { LT(1)->getText() == "BINARY_FLOAT" }?=> REGULAR_ID
    ;

range_key
    :    { LT(1)->getText() == "RANGE" }?=> REGULAR_ID
    ;

nclob_key
    :    { LT(1)->getText() == "NCLOB" }?=> REGULAR_ID
    ;

clob_key
    :    { LT(1)->getText() == "CLOB" }?=> REGULAR_ID
    ;

dsinterval_unconstrained_key
    :    { LT(1)->getText() == "DSINTERVAL_UNCONSTRAINED" }?=> REGULAR_ID
    ;

yminterval_unconstrained_key
    :    { LT(1)->getText() == "YMINTERVAL_UNCONSTRAINED" }?=> REGULAR_ID
    ;

rowid_key
    :    { LT(1)->getText() == "ROWID" }?=> REGULAR_ID
    ;

binary_double_nan_key
    :    { LT(1)->getText() == "BINARY_DOUBLE_NAN" }?=> REGULAR_ID
    ;

timestamp_unconstrained_key
    :    { LT(1)->getText() == "TIMESTAMP_UNCONSTRAINED" }?=> REGULAR_ID
    ;

binary_float_min_normal_key
    :    { LT(1)->getText() == "BINARY_FLOAT_MIN_NORMAL" }?=> REGULAR_ID
    ;

signtype_key
    :    { LT(1)->getText() == "SIGNTYPE" }?=> REGULAR_ID
    ;

blob_key
    :    { LT(1)->getText() == "BLOB" }?=> REGULAR_ID
    ;

nvarchar2_key
    :    { LT(1)->getText() == "NVARCHAR2" }?=> REGULAR_ID
    ;

binary_double_max_normal_key
    :    { LT(1)->getText() == "BINARY_DOUBLE_MAX_NORMAL" }?=> REGULAR_ID
    ;

binary_float_nan_key
    :    { LT(1)->getText() == "BINARY_FLOAT_NAN" }?=> REGULAR_ID
    ;

string_key
    :    { LT(1)->getText() == "STRING" }?=> REGULAR_ID
    ;

c_key
    :    { LT(1)->getText() == "C" }?=> REGULAR_ID
    ;

library_key
    :    { LT(1)->getText() == "LIBRARY" }?=> REGULAR_ID
    ;

context_key
    :    { LT(1)->getText() == "CONTEXT" }?=> REGULAR_ID
    ;

parameters_key
    :    { LT(1)->getText() == "PARAMETERS" }?=> REGULAR_ID
    ;

agent_key
    :    { LT(1)->getText() == "AGENT" }?=> REGULAR_ID
    ;

cluster_key
    :    { LT(1)->getText() == "CLUSTER" }?=> REGULAR_ID
    ;

hash_key
    :    { LT(1)->getText() == "HASH" }?=> REGULAR_ID
    ;

relies_on_key
    :    { LT(1)->getText() == "RELIES_ON" }?=> REGULAR_ID
    ;

returning_key
    :    { LT(1)->getText() == "RETURNING" }?=> REGULAR_ID
    ;    

statement_id_key
    :    { LT(1)->getText() == "STATEMENT_ID" }?=> REGULAR_ID
    ;

deferred_key
    :    { LT(1)->getText() == "DEFERRED" }?=> REGULAR_ID
    ;

advise_key
    :    { LT(1)->getText() == "ADVISE" }?=> REGULAR_ID
    ;

resumable_key
    :    { LT(1)->getText() == "RESUMABLE" }?=> REGULAR_ID
    ;

timeout_key
    :    { LT(1)->getText() == "TIMEOUT" }?=> REGULAR_ID
    ;

parallel_key
    :    { LT(1)->getText() == "PARALLEL" }?=> REGULAR_ID
    ;

ddl_key
    :    { LT(1)->getText() == "DDL" }?=> REGULAR_ID
    ;

query_key
    :    { LT(1)->getText() == "QUERY" }?=> REGULAR_ID
    ;

dml_key
    :    { LT(1)->getText() == "DML" }?=> REGULAR_ID
    ;

guard_key
    :    { LT(1)->getText() == "GUARD" }?=> REGULAR_ID
    ;

nothing_key
    :    { LT(1)->getText() == "NOTHING" }?=> REGULAR_ID
    ;

enable_key
    :    { LT(1)->getText() == "ENABLE" }?=> REGULAR_ID
    ;

database_key
    :    { LT(1)->getText() == "DATABASE" }?=> REGULAR_ID
    ;

disable_key
    :    { LT(1)->getText() == "DISABLE" }?=> REGULAR_ID
    ;

link_key
    :    { LT(1)->getText() == "LINK" }?=> REGULAR_ID
    ;

identified_key
    :    PLSQL_RESERVED_IDENTIFIED
    ;

none_key
    :    { LT(1)->getText() == "NONE" }?=> REGULAR_ID
    ;

before_key
    :    { LT(1)->getText() == "BEFORE" }?=> REGULAR_ID 
    ;

referencing_key
    :    { LT(1)->getText() == "REFERENCING" }?=> REGULAR_ID
    ;

logon_key
    :    { LT(1)->getText() == "LOGON" }?=> REGULAR_ID
    ;

after_key
    :    { LT(1)->getText() == "AFTER" }? REGULAR_ID
    ;

schema_key
    :    { LT(1)->getText() == "SCHEMA" }?=> REGULAR_ID
    ;

grant_key
    :    SQL92_RESERVED_GRANT
    ;

truncate_key
    :    { LT(1)->getText() == "TRUNCATE" }?=> REGULAR_ID
    ;

startup_key
    :    { LT(1)->getText() == "STARTUP" }?=> REGULAR_ID
    ;

statistics_key
    :    { LT(1)->getText() == "STATISTICS" }?=> REGULAR_ID
    ;

noaudit_key
    :    { LT(1)->getText() == "NOAUDIT" }?=> REGULAR_ID
    ;

suspend_key
    :    { LT(1)->getText() == "SUSPEND" }?=> REGULAR_ID
    ;

audit_key
    :    { LT(1)->getText() == "AUDIT" }?=> REGULAR_ID
    ;

disassociate_key
    :    { LT(1)->getText() == "DISASSOCIATE" }?=> REGULAR_ID 
    ;

shutdown_key
    :    { LT(1)->getText() == "SHUTDOWN" }?=> REGULAR_ID
    ;

compound_key
    :    { LT(1)->getText() == "COMPOUND" }?=> REGULAR_ID
    ;

servererror_key
    :    { LT(1)->getText() == "SERVERERROR" }?=> REGULAR_ID
    ;

parent_key
    :    { LT(1)->getText() == "PARENT" }?=> REGULAR_ID
    ;

follows_key
    :    { LT(1)->getText() == "FOLLOWS" }?=> REGULAR_ID
    ;

nested_key
    :    { LT(1)->getText() == "NESTED" }?=> REGULAR_ID
    ;

old_key
    :    { LT(1)->getText() == "OLD" }?=> REGULAR_ID
    ;

statement_key
    :    { LT(1)->getText() == "STATEMENT" }?=> REGULAR_ID
    ;

db_role_change_key
    :    { LT(1)->getText() == "DB_ROLE_CHANGE" }?=> REGULAR_ID
    ;

each_key
    :    { LT(1)->getText() == "EACH" }?=> REGULAR_ID
    ;

logoff_key
    :    { LT(1)->getText() == "LOGOFF" }?=> REGULAR_ID
    ;

analyze_key
    :    { LT(1)->getText() == "ANALYZE" }?=> REGULAR_ID
    ;

instead_key
    :    { LT(1)->getText() == "INSTEAD" }?=> REGULAR_ID
    ;

associate_key
    :    { LT(1)->getText() == "ASSOCIATE" }?=> REGULAR_ID
    ;

new_key
    :    { LT(1)->getText() == "NEW" }?=> REGULAR_ID
    ;

revoke_key
    :    SQL92_RESERVED_REVOKE
    ;

rename_key
    :    { LT(1)->getText() == "RENAME" }?=> REGULAR_ID 
    ;

customdatum_key
    :    { LT(1)->getText() == "CUSTOMDATUM" }?=> REGULAR_ID
    ;

oradata_key
    :    { LT(1)->getText() == "ORADATA" }?=> REGULAR_ID
    ;

constructor_key
    :    { LT(1)->getText() == "CONSTRUCTOR" }?=> REGULAR_ID
    ;

sqldata_key
    :    { LT(1)->getText() == "SQLDATA" }?=> REGULAR_ID
    ;

member_key
    :    { LT(1)->getText() == "MEMBER" }?=> REGULAR_ID
    ;

self_key
    :    { LT(1)->getText() == "SELF" }?=> REGULAR_ID
    ;

object_key
    :    { LT(1)->getText() == "OBJECT" }?=> REGULAR_ID
    ;

variable_key
    :    { LT(1)->getText() == "VARIABLE" }?=> REGULAR_ID
    ;

instantiable_key
    :    { LT(1)->getText() == "INSTANTIABLE" }?=> REGULAR_ID
    ;

final_key
    :    { LT(1)->getText() == "FINAL" }?=> REGULAR_ID
    ;

static_key
    :    { LT(1)->getText() == "STATIC" }?=> REGULAR_ID
    ;

oid_key
    :    { LT(1)->getText() == "OID" }?=> REGULAR_ID
    ;

result_key
    :    { LT(1)->getText() == "RESULT" }?=> REGULAR_ID
    ;

under_key
    :    { LT(1)->getText() == "UNDER" }?=> REGULAR_ID
    ;

map_key
    :    { LT(1)->getText() == "MAP" }?=> REGULAR_ID
    ;

overriding_key
    :    { LT(1)->getText() == "OVERRIDING" }?=> REGULAR_ID
    ;

add_key
    :    { LT(1)->getText() == "ADD" }?=> REGULAR_ID
    ;

modify_key
    :    { LT(1)->getText() == "MODIFY" }?=> REGULAR_ID
    ;

including_key
    :    { LT(1)->getText() == "INCLUDING" }?=> REGULAR_ID
    ;

substitutable_key
    :    { LT(1)->getText() == "SUBSTITUTABLE" }?=> REGULAR_ID
    ;

attribute_key
    :    { LT(1)->getText() == "ATTRIBUTE" }?=> REGULAR_ID
    ;

cascade_key
    :    { LT(1)->getText() == "CASCADE" }?=> REGULAR_ID 
    ;

data_key
    :    { LT(1)->getText() == "DATA" }?=> REGULAR_ID
    ;

invalidate_key
    :    { LT(1)->getText() == "INVALIDATE" }? REGULAR_ID
    ;

element_key
    :    { LT(1)->getText() == "ELEMENT" }?=> REGULAR_ID
    ;

first_key
    :    { LT(1)->getText() == "FIRST" }?=> REGULAR_ID
    ;

check_key
    :    SQL92_RESERVED_CHECK
    ;

option_key
    :    SQL92_RESERVED_OPTION
    ;

nocycle_key
    :    { LT(1)->getText() == "NOCYCLE" }?=> REGULAR_ID
    ;

locked_key
    :    { LT(1)->getText() == "LOCKED" }?=> REGULAR_ID
    ;

block_key
    :    { LT(1)->getText() == "BLOCK" }?=> REGULAR_ID
    ;

xml_key
    :    { LT(1)->getText() == "XML" }?=> REGULAR_ID
    ;

pivot_key//:    {(input.LT(1).getText(). ("PIVOT") }?=> REGULAR_ID
    :     PLSQL_NON_RESERVED_PIVOT
    ;

prior_key
    :    SQL92_RESERVED_PRIOR
    ;

sequential_key
    :    { LT(1)->getText() == "SEQUENTIAL" }?=> REGULAR_ID
    ;

single_key
    :    { LT(1)->getText() == "SINGLE" }?=> REGULAR_ID
    ;

skip_key
    :    { LT(1)->getText() == "SKIP" }?=> REGULAR_ID
    ;

model_key
    :    //{input.LT(1).getText(). ("MODEL" }?=> REGULAR_ID
        PLSQL_NON_RESERVED_MODEL
    ;

updated_key
    :    { LT(1)->getText() == "UPDATED" }?=> REGULAR_ID
    ;

increment_key
    :    { LT(1)->getText() == "INCREMENT" }?=> REGULAR_ID
    ;

exclude_key
    :    { LT(1)->getText() == "EXCLUDE" }?=> REGULAR_ID
    ;

reference_key
    :    { LT(1)->getText() == "REFERENCE" }?=> REGULAR_ID
    ;

sets_key
    :    { LT(1)->getText() == "SETS" }?=> REGULAR_ID
    ;

until_key
    :    { LT(1)->getText() == "UNTIL" }?=> REGULAR_ID
    ;

seed_key
    :    { LT(1)->getText() == "SEED" }?=> REGULAR_ID
    ;

maxvalue_key
    :    { LT(1)->getText() == "MAXVALUE" }?=> REGULAR_ID
    ;

siblings_key
    :    { LT(1)->getText() == "SIBLINGS" }?=> REGULAR_ID
    ;

cube_key
    :    { LT(1)->getText() == "CUBE" }?=> REGULAR_ID
    ;

nulls_key
    :    { LT(1)->getText() == "NULLS" }?=> REGULAR_ID
    ;

dimension_key
    :    { LT(1)->getText() == "DIMENSION" }?=> REGULAR_ID
    ;

scn_key
    :    { LT(1)->getText() == "SCN" }?=> REGULAR_ID
    ;

snapshot_key
    :    { LT(1)->getText() == "SNAPSHOT" }?=> REGULAR_ID
    ;

decrement_key
    :    { LT(1)->getText() == "DECREMENT" }?=> REGULAR_ID
    ;

unpivot_key//:    {(input.LT(1).getText(). ("UNPIVOT") }?=> REGULAR_ID
    :    PLSQL_NON_RESERVED_UNPIVOT
    ;

keep_key
    :    { LT(1)->getText() == "KEEP" }?=> REGULAR_ID
    ;

measures_key
    :    { LT(1)->getText() == "MEASURES" }?=> REGULAR_ID
    ;

rows_key
    :    { LT(1)->getText() == "ROWS" }?=> REGULAR_ID
    ;

sample_key
    :    { LT(1)->getText() == "SAMPLE" }?=> REGULAR_ID
    ;

upsert_key
    :    { LT(1)->getText() == "UPSERT" }?=> REGULAR_ID
    ;

versions_key
    :    { LT(1)->getText() == "VERSIONS" }?=> REGULAR_ID
    ;

rules_key
    :    { LT(1)->getText() == "RULES" }?=> REGULAR_ID
    ;

iterate_key
    :    { LT(1)->getText() == "ITERATE" }?=> REGULAR_ID
    ;

minvalue_key
    :    { LT(1)->getText() == "MINVALUE" }?=> REGULAR_ID
    ;

rollup_key
    :    { LT(1)->getText() == "ROLLUP" }?=> REGULAR_ID
    ;

nav_key
    :    { LT(1)->getText() == "NAV" }?=> REGULAR_ID
    ;

automatic_key
    :    { LT(1)->getText() == "AUTOMATIC" }?=> REGULAR_ID
    ;

last_key
    :    { LT(1)->getText() == "LAST" }?=> REGULAR_ID
    ;

main_key
    :    { LT(1)->getText() == "MAIN" }?=> REGULAR_ID
    ;

grouping_key
    :    { LT(1)->getText() == "GROUPING" }?=> REGULAR_ID
    ;

include_key
    :    { LT(1)->getText() == "INCLUDE" }?=> REGULAR_ID
    ;

ignore_key
    :    { LT(1)->getText() == "IGNORE" }?=> REGULAR_ID
    ;

respect_key
    :    { LT(1)->getText() == "RESPECT" }?=> REGULAR_ID
    ;

unique_key
    :    SQL92_RESERVED_UNIQUE
    ;

submultiset_key
    :    { LT(1)->getText() == "SUBMULTISET" }?=> REGULAR_ID
    ;

at_key
    :    { LT(1)->getText() == "AT" }?=> REGULAR_ID
//    :    SQL92_RESERVED_AT
    ;

a_key
    :    { LT(1)->getText() == "A" }?=> REGULAR_ID
    ;

empty_key
    :    { LT(1)->getText() == "EMPTY" }?=> REGULAR_ID
    ;

likec_key
    :    { LT(1)->getText() == "LIKEC" }?=> REGULAR_ID
    ;

nan_key
    :    { LT(1)->getText() == "NAN" }?=> REGULAR_ID
    ;

infinite_key
    :    { LT(1)->getText() == "INFINITE" }?=> REGULAR_ID
    ;

like2_key
    :    { LT(1)->getText() == "LIKE2" }?=> REGULAR_ID
    ;

like4_key
    :    { LT(1)->getText() == "LIKE4" }?=> REGULAR_ID
    ;

present_key
    :    { LT(1)->getText() == "PRESENT" }?=> REGULAR_ID
    ;

dbtimezone_key
    :    { LT(1)->getText() == "DBTIMEZONE" }?=> REGULAR_ID
    ;

sessiontimezone_key
    :    { LT(1)->getText() == "SESSIONTIMEZONE" }?=> REGULAR_ID
    ;

nchar_cs_key
    :    { LT(1)->getText() == "NCHAR_CS" }?=> REGULAR_ID
    ;

decompose_key
    :    { LT(1)->getText() == "DECOMPOSE" }?=> REGULAR_ID
    ;

following_key
    :    { LT(1)->getText() == "FOLLOWING" }?=> REGULAR_ID
    ;

first_value_key
    :    { LT(1)->getText() == "FIRST_VALUE" }?=> REGULAR_ID
    ;

preceding_key
    :    { LT(1)->getText() == "PRECEDING" }?=> REGULAR_ID
    ;

within_key
    :    { LT(1)->getText() == "WITHIN" }?=> REGULAR_ID
    ;

canonical_key
    :    { LT(1)->getText() == "CANONICAL" }?=> REGULAR_ID
    ;

compatibility_key
    :    { LT(1)->getText() == "COMPATIBILITY" }?=> REGULAR_ID
    ;

over_key
    :    { LT(1)->getText() == "OVER" }?=> REGULAR_ID
    ;

multiset_key
    :    { LT(1)->getText() == "MULTISET" }?=> REGULAR_ID
    ;

connect_by_root_key
    :    PLSQL_NON_RESERVED_CONNECT_BY_ROOT
    ;

last_value_key
    :    { LT(1)->getText() == "LAST_VALUE" }?=> REGULAR_ID
    ;

current_key
    :    SQL92_RESERVED_CURRENT
    ;

unbounded_key
    :    { LT(1)->getText() == "UNBOUNDED" }?=> REGULAR_ID
    ;

dense_rank_key
    :    { LT(1)->getText() == "DENSE_RANK" }?=> REGULAR_ID
    ;

cost_key
    :    { LT(1)->getText() == "COST" }?=> REGULAR_ID
    ;

char_cs_key
    :    { LT(1)->getText() == "CHAR_CS" }?=> REGULAR_ID
    ;

auto_key
    :    { LT(1)->getText() == "AUTO" }?=> REGULAR_ID
    ;

treat_key
    :    { LT(1)->getText() == "TREAT" }?=> REGULAR_ID
    ;

content_key
    :    { LT(1)->getText() == "CONTENT" }?=> REGULAR_ID
    ;

xmlparse_key
    :    { LT(1)->getText() == "XMLPARSE" }?=> REGULAR_ID
    ;

xmlelement_key
    :    { LT(1)->getText() == "XMLELEMENT" }?=> REGULAR_ID
    ;

entityescaping_key
    :    { LT(1)->getText() == "ENTITYESCAPING" }?=> REGULAR_ID
    ;

standalone_key
    :    { LT(1)->getText() == "STANDALONE" }?=> REGULAR_ID
    ;

wellformed_key
    :    { LT(1)->getText() == "WELLFORMED" }?=> REGULAR_ID
    ;

xmlexists_key
    :    { LT(1)->getText() == "XMLEXISTS" }?=> REGULAR_ID
    ;

version_key
    :    { LT(1)->getText() == "VERSION" }?=> REGULAR_ID
    ;

xmlcast_key
    :    { LT(1)->getText() == "XMLCAST" }?=> REGULAR_ID
    ;

yes_key
    :    { LT(1)->getText() == "YES" }?=> REGULAR_ID
    ;

no_key
    :    { LT(1)->getText() == "NO" }?=> REGULAR_ID
    ;

evalname_key
    :    { LT(1)->getText() == "EVALNAME" }?=> REGULAR_ID
    ;

xmlpi_key
    :    { LT(1)->getText() == "XMLPI" }?=> REGULAR_ID
    ;

xmlcolattval_key
    :    { LT(1)->getText() == "XMLCOLATTVAL" }?=> REGULAR_ID
    ;

document_key
    :    { LT(1)->getText() == "DOCUMENT" }?=> REGULAR_ID
    ;

xmlforest_key
    :    { LT(1)->getText() == "XMLFOREST" }?=> REGULAR_ID
    ;

passing_key
    :    { LT(1)->getText() == "PASSING" }?=> REGULAR_ID
    ;

columns_key //: PLSQL_RESERVED_COLUMNS
    :    { LT(1)->getText() == "COLUMNS" }?=> REGULAR_ID
    ;

indent_key
    :    { LT(1)->getText() == "INDENT" }?=> REGULAR_ID
    ;

hide_key
    :    { LT(1)->getText() == "HIDE" }?=> REGULAR_ID
    ;

xmlagg_key
    :    { LT(1)->getText() == "XMLAGG" }?=> REGULAR_ID
    ;

path_key
    :    { LT(1)->getText() == "PATH" }?=> REGULAR_ID
    ;

xmlnamespaces_key
    :    { LT(1)->getText() == "XMLNAMESPACES" }?=> REGULAR_ID
    ;

size_key
    :    SQL92_RESERVED_SIZE
    ;

noschemacheck_key
    :    { LT(1)->getText() == "NOSCHEMACHECK" }?=> REGULAR_ID
    ;

noentityescaping_key
    :    { LT(1)->getText() == "NOENTITYESCAPING" }?=> REGULAR_ID
    ;

xmlquery_key
    :    { LT(1)->getText() == "XMLQUERY" }?=> REGULAR_ID
    ;

xmltable_key
    :    { LT(1)->getText() == "XMLTABLE" }?=> REGULAR_ID
    ;

xmlroot_key
    :    { LT(1)->getText() == "XMLROOT" }?=> REGULAR_ID
    ;

schemacheck_key
    :    { LT(1)->getText() == "SCHEMACHECK" }?=> REGULAR_ID
    ;

xmlattributes_key
    :    { LT(1)->getText() == "XMLATTRIBUTES" }?=> REGULAR_ID
    ;

encoding_key
    :    { LT(1)->getText() == "ENCODING" }?=> REGULAR_ID
    ;

show_key
    :    { LT(1)->getText() == "SHOW" }?=> REGULAR_ID
    ;

xmlserialize_key
    :    { LT(1)->getText() == "XMLSERIALIZE" }?=> REGULAR_ID
    ;

ordinality_key
    :    { LT(1)->getText() == "ORDINALITY" }?=> REGULAR_ID
    ;

defaults_key
    :    { LT(1)->getText() == "DEFAULTS" }?=> REGULAR_ID
    ;

sqlerror_key
    :    { LT(1)->getText() == "SQLERROR" }? REGULAR_ID 
    ;
	
oserror_key
    :    { LT(1)->getText() == "OSERROR" }? REGULAR_ID 
    ;

success_key
    :    { LT(1)->getText() == "SUCCESS" }? REGULAR_ID 
    ;

warning_key
    :    { LT(1)->getText() == "WARNING" }? REGULAR_ID 
    ;

failure_key
    :    { LT(1)->getText() == "FAILURE" }? REGULAR_ID 
    ;

insert_key
    :    SQL92_RESERVED_INSERT
    ;

order_key
    :    SQL92_RESERVED_ORDER
    ;

minus_key
    :    PLSQL_RESERVED_MINUS
    ;

row_key
    :    { LT(1)->getText() == "ROW" }? REGULAR_ID
    ;

mod_key
    :    { LT(1)->getText() == "MOD" }? REGULAR_ID
    ;

raw_key
    :    { LT(1)->getText() == "RAW" }?=> REGULAR_ID
    ;

power_key
    :    { LT(1)->getText() == "POWER" }? REGULAR_ID
    ;

lock_key
    :    PLSQL_RESERVED_LOCK
    ;

exists_key
    :    SQL92_RESERVED_EXISTS
    ;

having_key
    :    SQL92_RESERVED_HAVING
    ;

any_key
    :    SQL92_RESERVED_ANY
    ;

with_key
    :    SQL92_RESERVED_WITH
    ;

transaction_key
    :    { LT(1)->getText() == "TRANSACTION" }?=> REGULAR_ID
    ;

rawtohex_key
    :    { LT(1)->getText() == "RAWTOHEX" }? REGULAR_ID
    ;

number_key
    :    { LT(1)->getText() == "NUMBER" }?=> REGULAR_ID
    ;

nocopy_key
    :    { LT(1)->getText() == "NOCOPY" }?=> REGULAR_ID
    ;

to_key
    :    SQL92_RESERVED_TO
    ;

abs_key
    :    { LT(1)->getText() == "ABS" }? REGULAR_ID
    ;

rollback_key
    :    { LT(1)->getText() == "ROLLBACK" }?=> REGULAR_ID
    ;

share_key
    :    PLSQL_RESERVED_SHARE
    ;

greatest_key
    :    { LT(1)->getText() == "GREATEST" }? REGULAR_ID
    ;

vsize_key
    :    { LT(1)->getText() == "VSIZE" }? REGULAR_ID
    ;

exclusive_key
    :    PLSQL_RESERVED_EXCLUSIVE
    ;

varchar2_key
    :    { LT(1)->getText() == "VARCHAR2" }?=> REGULAR_ID
    ;

rowidtochar_key
    :    { LT(1)->getText() == "ROWIDTOCHAR" }? REGULAR_ID
    ;

open_key
    :    { LT(1)->getText() == "OPEN" }?=> REGULAR_ID
    ;

comment_key
    :    { LT(1)->getText() == "COMMENT" }?=> REGULAR_ID
    ;

sqrt_key
    :    { LT(1)->getText() == "SQRT" }? REGULAR_ID
    ;

instr_key
    :    { LT(1)->getText() == "INSTR" }? REGULAR_ID
    ;

nowait_key
    :    PLSQL_RESERVED_NOWAIT
    ;

lpad_key
    :    { LT(1)->getText() == "LPAD" }? REGULAR_ID
    ;

boolean_key
    :    { LT(1)->getText() == "BOOLEAN" }?=> REGULAR_ID
    ;

rpad_key
    :    { LT(1)->getText() == "RPAD" }? REGULAR_ID
    ;

savepoint_key
    :    { LT(1)->getText() == "SAVEPOINT" }?=> REGULAR_ID
    ;

decode_key
    :    { LT(1)->getText() == "DECODE" }? REGULAR_ID
    ;

reverse_key
    :    { LT(1)->getText() == "REVERSE" }? REGULAR_ID
    ;

least_key
    :    { LT(1)->getText() == "LEAST" }? REGULAR_ID
    ;

nvl_key
    :    { LT(1)->getText() == "NVL" }? REGULAR_ID
    ;

variance_key
    :    { LT(1)->getText() == "VARIANCE" }? REGULAR_ID
    ;

start_key
    :    PLSQL_RESERVED_START
    ;

desc_key
    :    SQL92_RESERVED_DESC
    ;

concat_key
    :    { LT(1)->getText() == "CONCAT" }? REGULAR_ID
    ;

dump_key
    :    { LT(1)->getText() == "DUMP" }? REGULAR_ID
    ;

soundex_key
    :    { LT(1)->getText() == "SOUNDEX" }? REGULAR_ID
    ;

positive_key
    :    { LT(1)->getText() == "POSITIVE" }?=> REGULAR_ID
    ;

union_key
    :    SQL92_RESERVED_UNION
    ;

ascii_key
    :    { LT(1)->getText() == "ASCII" }? REGULAR_ID
    ;

connect_key
    :    SQL92_RESERVED_CONNECT
    ;

asc_key
    :    SQL92_RESERVED_ASC
    ;

hextoraw_key
    :    { LT(1)->getText() == "HEXTORAW" }? REGULAR_ID
    ;

to_date_key
    :    { LT(1)->getText() == "TO_DATE" }? REGULAR_ID
    ;

floor_key
    :    { LT(1)->getText() == "FLOOR" }? REGULAR_ID
    ;

sign_key
    :    { LT(1)->getText() == "SIGN" }? REGULAR_ID
    ;

update_key
    :    SQL92_RESERVED_UPDATE
    ;

trunc_key
    :    { LT(1)->getText() == "TRUNC" }? REGULAR_ID
    ;

rtrim_key
    :    { LT(1)->getText() == "RTRIM" }? REGULAR_ID
    ;

close_key
    :    { LT(1)->getText() == "CLOSE" }?=> REGULAR_ID
    ;

to_char_key
    :    { LT(1)->getText() == "TO_CHAR" }? REGULAR_ID
    ;

ltrim_key
    :    { LT(1)->getText() == "LTRIM" }? REGULAR_ID
    ;

mode_key
    :    PLSQL_RESERVED_MODE
    ;

uid_key
    :    { LT(1)->getText() == "UID" }? REGULAR_ID
    ;

chr_key
    :    { LT(1)->getText() == "CHR" }? REGULAR_ID
    ;

intersect_key
    :    SQL92_RESERVED_INTERSECT
    ;

chartorowid_key
    :    { LT(1)->getText() == "CHARTOROWID" }? REGULAR_ID
    ;

mlslabel_key
    :    { LT(1)->getText() == "MLSLABEL" }?=> REGULAR_ID
    ;

userenv_key
    :    { LT(1)->getText() == "USERENV" }? REGULAR_ID
    ;

stddev_key
    :    { LT(1)->getText() == "STDDEV" }? REGULAR_ID
    ;

length_key
    :    { LT(1)->getText() == "LENGTH" }? REGULAR_ID
    ;

fetch_key
    :    SQL92_RESERVED_FETCH
    ;

group_key
    :    SQL92_RESERVED_GROUP
    ;

sysdate_key
    :    { LT(1)->getText() == "SYSDATE" }? REGULAR_ID
    ;

binary_integer_key
    :    { LT(1)->getText() == "BINARY_INTEGER" }?=> REGULAR_ID
    ;

to_number_key
    :    { LT(1)->getText() == "TO_NUMBER" }? REGULAR_ID
    ;

substr_key
    :    { LT(1)->getText() == "SUBSTR" }? REGULAR_ID
    ;

ceil_key
    :    { LT(1)->getText() == "CEIL" }? REGULAR_ID
    ;

initcap_key
    :    { LT(1)->getText() == "INITCAP" }? REGULAR_ID
    ;

round_key
    :    { LT(1)->getText() == "ROUND" }? REGULAR_ID
    ;

long_key
    :    { LT(1)->getText() == "LONG" }?=> REGULAR_ID
    ;

read_key
    :    { LT(1)->getText() == "READ" }?=> REGULAR_ID
    ;

only_key
    :    { LT(1)->getText() == "ONLY" }? REGULAR_ID
    ;

set_key
    :    { LT(1)->getText() == "SET" }?=> REGULAR_ID
    ;

nullif_key
    :    { LT(1)->getText() == "NULLIF" }? REGULAR_ID
    ;

coalesce_key
    :    { LT(1)->getText() == "COALESCE" }? REGULAR_ID
    ;

count_key
    :    { LT(1)->getText() == "COUNT" }? REGULAR_ID
    ;

avg_key    :    { LT(1)->getText() == "AVG" }? REGULAR_ID
    ;

max_key    :    { LT(1)->getText() == "MAX" }? REGULAR_ID
    ;

min_key    :    { LT(1)->getText() == "MIN" }? REGULAR_ID
    ;

sum_key    :    { LT(1)->getText() == "SUM" }? REGULAR_ID
    ;

unknown_key
    :    { LT(1)->getText() == "UNKNOWN" }? REGULAR_ID
    ;

escape_key
    :    { LT(1)->getText() == "ESCAPE" }? REGULAR_ID
    ;

some_key
    :    { LT(1)->getText() == "SOME" }? REGULAR_ID
    ;

match_key
    :    { LT(1)->getText() == "MATCH" }? REGULAR_ID
    ;

cast_key
    :    { LT(1)->getText() == "CAST" }? REGULAR_ID
    ;

full_key
    :    { LT(1)->getText() == "FULL" }?=> REGULAR_ID
    ;

partial_key
    :    { LT(1)->getText() == "PARTIAL" }? REGULAR_ID
    ;

character_key
    :    { LT(1)->getText() == "CHARACTER" }?=> REGULAR_ID
    ;

except_key
    :    { LT(1)->getText() == "EXCEPT" }? REGULAR_ID
    ;

char_key
    :    { LT(1)->getText() == "CHAR" }?=> REGULAR_ID
    ;

varying_key
    :    { LT(1)->getText() == "VARYING" }?=> REGULAR_ID
    ;

varchar_key
    :    { LT(1)->getText() == "VARCHAR" }?=> REGULAR_ID
    ;

national_key
    :    { LT(1)->getText() == "NATIONAL" }? REGULAR_ID
    ;

nchar_key
    :    { LT(1)->getText() == "NCHAR" }? REGULAR_ID
    ;

bit_key    :    { LT(1)->getText() == "BIT" }? REGULAR_ID
    ;

float_key
    :    { LT(1)->getText() == "FLOAT" }? REGULAR_ID
    ;
    
real_key
    :    { LT(1)->getText() == "REAL" }?=> REGULAR_ID
    ;

double_key
    :    { LT(1)->getText() == "DOUBLE" }?=> REGULAR_ID
    ;

precision_key
    :    { LT(1)->getText() == "PRECISION" }? REGULAR_ID
    ;

interval_key
    :    { LT(1)->getText() == "INTERVAL" }?=> REGULAR_ID
    ;

time_key
    :    { LT(1)->getText() == "TIME" }? REGULAR_ID
    ;
 
zone_key
    :    { LT(1)->getText() == "ZONE" }? REGULAR_ID
    ;

timestamp_key
    :    { LT(1)->getText() == "TIMESTAMP" }? REGULAR_ID
    ;

date_key//:    {input.LT(1).getText(). ("DATE" }?=> REGULAR_ID
    :    SQL92_RESERVED_DATE
    ;

numeric_key
    :    { LT(1)->getText() == "NUMERIC" }?=> REGULAR_ID
    ;

decimal_key
    :    { LT(1)->getText() == "DECIMAL" }?=> REGULAR_ID
    ;

dec_key
    :    { LT(1)->getText() == "DEC" }?=> REGULAR_ID
    ;

integer_key
    :    { LT(1)->getText() == "INTEGER" }?=> REGULAR_ID
    ;

int_key
    :    { LT(1)->getText() == "INT" }?=> REGULAR_ID
    ;

smallint_key
    :    { LT(1)->getText() == "SMALLINT" }?=> REGULAR_ID
    ;

corresponding_key
    :    { LT(1)->getText() == "CORRESPONDING" }? REGULAR_ID
    ;

cross_key
    :    { LT(1)->getText() == "CROSS" }?=> REGULAR_ID
    ;

join_key
    :    { LT(1)->getText() == "JOIN" }?=> REGULAR_ID
    ;

left_key
    :    { LT(1)->getText() == "LEFT" }?=> REGULAR_ID
    ;

right_key
    :    { LT(1)->getText() == "RIGHT" }?=> REGULAR_ID
    ;

inner_key
    :    { LT(1)->getText() == "INNER" }?=> REGULAR_ID
    ;

natural_key
    :    { LT(1)->getText() == "NATURAL" }?=> REGULAR_ID
    ;

outer_key
    :    { LT(1)->getText() == "OUTER" }?=> REGULAR_ID
    ;

using_key
    :    PLSQL_NON_RESERVED_USING
    ;

indicator_key
    :    { LT(1)->getText() == "INDICATOR" }? REGULAR_ID
    ;

user_key
    :    { LT(1)->getText() == "USER" }? REGULAR_ID
    ;

current_user_key
    :    { LT(1)->getText() == "CURRENT_USER" }? REGULAR_ID
    ;

session_user_key
    :    { LT(1)->getText() == "SESSION_USER" }? REGULAR_ID
    ;

system_user_key
    :    { LT(1)->getText() == "SYSTEM_USER" }? REGULAR_ID
    ;

value_key
    :    { LT(1)->getText() == "VALUE" }? REGULAR_ID
    ;

substring_key
    :    { LT(1)->getText() == "SUBSTRING" }?=> REGULAR_ID
    ;

upper_key
    :    { LT(1)->getText() == "UPPER" }? REGULAR_ID
    ;

lower_key
    :    { LT(1)->getText() == "LOWER" }? REGULAR_ID
    ;

convert_key
    :    { LT(1)->getText() == "CONVERT" }? REGULAR_ID
    ;

translate_key
    :    { LT(1)->getText() == "TRANSLATE" }? REGULAR_ID
    ;

trim_key
    :    { LT(1)->getText() == "TRIM" }? REGULAR_ID
    ;

leading_key
    :    { LT(1)->getText() == "LEADING" }? REGULAR_ID
    ;

trailing_key
    :    { LT(1)->getText() == "TRAILING" }? REGULAR_ID
    ;

both_key
    :    { LT(1)->getText() == "BOTH" }? REGULAR_ID
    ;

collate_key
    :    { LT(1)->getText() == "COLLATE" }? REGULAR_ID
    ;

position_key
    :    { LT(1)->getText() == "POSITION" }? REGULAR_ID
    ;

extract_key
    :    { LT(1)->getText() == "EXTRACT" }? REGULAR_ID
    ;

second_key
    :    { LT(1)->getText() == "SECOND" }? REGULAR_ID
    ;

timezone_hour_key
    :    { LT(1)->getText() == "TIMEZONE_HOUR" }? REGULAR_ID
    ;

timezone_minute_key
    :    { LT(1)->getText() == "TIMEZONE_MINUTE" }? REGULAR_ID
    ;

char_length_key
    :    { LT(1)->getText() == "CHAR_LENGTH" }? REGULAR_ID
    ;

octet_length_key
    :    { LT(1)->getText() == "OCTET_LENGTH" }? REGULAR_ID
    ;

character_length_key
    :    { LT(1)->getText() == "CHARACTER_LENGTH" }? REGULAR_ID
    ;

bit_length_key
    :    { LT(1)->getText() == "BIT_LENGTH" }? REGULAR_ID
    ;

local_key
    :    { LT(1)->getText() == "LOCAL" }? REGULAR_ID
    ;

current_timestamp_key
    :    { LT(1)->getText() == "CURRENT_TIMESTAMP" }? REGULAR_ID
    ;

current_date_key
    :    { LT(1)->getText() == "CURRENT_DATE" }? REGULAR_ID
    ;

current_time_key
    :    { LT(1)->getText() == "CURRENT_TIME" }? REGULAR_ID
    ;

module_key
    :    { LT(1)->getText() == "MODULE" }? REGULAR_ID
    ;

global_key
    :    { LT(1)->getText() == "GLOBAL" }? REGULAR_ID
    ;

year_key
    :    { LT(1)->getText() == "YEAR" }?=> REGULAR_ID
    ;

month_key
    :    { LT(1)->getText() == "MONTH" }? REGULAR_ID
    ;

day_key
    :    { LT(1)->getText() == "DAY" }?=> REGULAR_ID
    ;

hour_key
    :    { LT(1)->getText() == "HOUR" }? REGULAR_ID
    ;

minute_key
    :    { LT(1)->getText() == "MINUTE" }? REGULAR_ID
    ;

whenever_key
    :    { LT(1)->getText() == "WHENEVER" }? REGULAR_ID
    ;

is_key
    :    SQL92_RESERVED_IS
    ;

else_key
    :    SQL92_RESERVED_ELSE
    ;

table_key
    :    SQL92_RESERVED_TABLE
    ;

the_key
    :    SQL92_RESERVED_THE
    ;

then_key
    :    SQL92_RESERVED_THEN
    ;

end_key
    :    SQL92_RESERVED_END
    ;

all_key
    :    SQL92_RESERVED_ALL
    ;

on_key
    :    SQL92_RESERVED_ON
    ;

or_key
    :    SQL92_RESERVED_OR
    ;

and_key
    :    SQL92_RESERVED_AND
    ;

not_key
    :    SQL92_RESERVED_NOT
    ;

true_key
    :    SQL92_RESERVED_TRUE
    ;

false_key
    :    SQL92_RESERVED_FALSE
    ;

default_key
    :    SQL92_RESERVED_DEFAULT
    ;

distinct_key
    :    SQL92_RESERVED_DISTINCT
    ;

into_key
    :    SQL92_RESERVED_INTO
    ;

by_key
    :    SQL92_RESERVED_BY
    ;

as_key
    :    SQL92_RESERVED_AS
    ;

in_key
    :    SQL92_RESERVED_IN
    ;

of_key
    :    SQL92_RESERVED_OF
    ;

null_key
    :    SQL92_RESERVED_NULL
    ;

for_key
    :    SQL92_RESERVED_FOR
    ;

select_key
    :    SQL92_RESERVED_SELECT
    ;

when_key
    :    SQL92_RESERVED_WHEN
    ;

delete_key
    :    SQL92_RESERVED_DELETE
    ;

between_key
    :    SQL92_RESERVED_BETWEEN
    ;

like_key
    :    SQL92_RESERVED_LIKE
    ;

from_key
    :    SQL92_RESERVED_FROM
    ;

where_key
    :    SQL92_RESERVED_WHERE
    ;

sequence_key
    :    { LT(1)->getText() == "SEQUENCE" }? REGULAR_ID
    ;

noorder_key
    :    { LT(1)->getText() == "NOORDER" }? REGULAR_ID
    ;

cycle_key
    :    { LT(1)->getText() == "CYCLE" }? REGULAR_ID
    ;

cache_key
    :    { LT(1)->getText() == "CACHE" }? REGULAR_ID
    ;

nocache_key
    :    { LT(1)->getText() == "NOCACHE" }? REGULAR_ID
    ;

nomaxvalue_key
    :    { LT(1)->getText() == "NOMAXVALUE" }? REGULAR_ID
    ;

nominvalue_key
    :    { LT(1)->getText() == "NOMINVALUE" }? REGULAR_ID
    ;

search_key
    :    { LT(1)->getText() == "SEARCH" }? REGULAR_ID
    ;

depth_key
    :    { LT(1)->getText() == "DEPTH" }? REGULAR_ID
    ;

breadth_key
    :    { LT(1)->getText() == "BREADTH" }? REGULAR_ID
    ;
