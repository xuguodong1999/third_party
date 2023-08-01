/****************************************************************************
 * Copyright (C) from 2009 to Present EPAM Systems.
 *
 * This file is part of Indigo toolkit.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 ***************************************************************************/

#ifndef __indigo_bingo__
#define __indigo_bingo__

#include "indigo.h"
#include "bingo_nosql_export.h"

BINGO_NOSQL_EXPORT const char* bingoVersion();

// options = "id: <property-name>"
BINGO_NOSQL_EXPORT int bingoCreateDatabaseFile(const char* location, const char* type, const char* options);
BINGO_NOSQL_EXPORT int bingoLoadDatabaseFile(const char* location, const char* options);
BINGO_NOSQL_EXPORT int bingoCloseDatabase(int db);

//
// Record insertion/deletion
//
BINGO_NOSQL_EXPORT int bingoInsertRecordObj(int db, int obj);
BINGO_NOSQL_EXPORT int bingoInsertIteratorObj(int db, int iterator_obj_id);
BINGO_NOSQL_EXPORT int bingoInsertRecordObjWithId(int db, int obj, int id);
BINGO_NOSQL_EXPORT int bingoInsertRecordObjWithExtFP(int db, int obj, int fp);
BINGO_NOSQL_EXPORT int bingoInsertRecordObjWithIdAndExtFP(int db, int obj, int id, int fp);
BINGO_NOSQL_EXPORT int bingoDeleteRecord(int db, int id);
BINGO_NOSQL_EXPORT int bingoGetRecordObj(int db, int id);

BINGO_NOSQL_EXPORT int bingoOptimize(int db);

// Search methods that returns search object
// Search object is an iterator
BINGO_NOSQL_EXPORT int bingoSearchSub(int db, int query_obj, const char* options);
BINGO_NOSQL_EXPORT int bingoSearchExact(int db, int query_obj, const char* options);
BINGO_NOSQL_EXPORT int bingoSearchMolFormula(int db, const char* query, const char* options);
BINGO_NOSQL_EXPORT int bingoSearchSim(int db, int query_obj, float min, float max, const char* options);
BINGO_NOSQL_EXPORT int bingoSearchSimWithExtFP(int db, int query_obj, float min, float max, int fp, const char* options);

BINGO_NOSQL_EXPORT int bingoSearchSimTopN(int db, int query_obj, int limit, float min, const char* options);
BINGO_NOSQL_EXPORT int bingoSearchSimTopNWithExtFP(int db, int query_obj, int limit, float min, int fp, const char* options);

BINGO_NOSQL_EXPORT int bingoEnumerateId(int db);

//
// Search object methods
//
BINGO_NOSQL_EXPORT int bingoNext(int search_obj);
BINGO_NOSQL_EXPORT int bingoGetCurrentId(int search_obj);
BINGO_NOSQL_EXPORT float bingoGetCurrentSimilarityValue(int search_obj);

// Estimation methods
BINGO_NOSQL_EXPORT int bingoEstimateRemainingResultsCount(int search_obj);
BINGO_NOSQL_EXPORT int bingoEstimateRemainingResultsCountError(int search_obj);
BINGO_NOSQL_EXPORT int bingoEstimateRemainingTime(int search_obj, float* time_sec);
BINGO_NOSQL_EXPORT int bingoContainersCount(int search_obj);
BINGO_NOSQL_EXPORT int bingoCellsCount(int search_obj);
BINGO_NOSQL_EXPORT int bingoCurrentCell(int search_obj);
BINGO_NOSQL_EXPORT int bingoMinCell(int search_obj);
BINGO_NOSQL_EXPORT int bingoMaxCell(int search_obj);

// This method return IndigoObject that represents current object.
// After calling bingoNext this object automatically points to the next found result
BINGO_NOSQL_EXPORT int bingoGetObject(int search_obj);

BINGO_NOSQL_EXPORT int bingoEndSearch(int search_obj);

BINGO_NOSQL_EXPORT const char* bingoProfilingGetStatistics(int for_session);

#endif // __indigo_bingo__
