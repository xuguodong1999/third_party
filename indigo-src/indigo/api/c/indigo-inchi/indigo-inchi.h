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

#ifndef __indigo_inchi__
#define __indigo_inchi__

#include "indigo.h"
#include <indigo_inchi_export.h>

INDIGO_INCHI_EXPORT const char *indigoInchiVersion();

INDIGO_INCHI_EXPORT int indigoInchiInit(qword id);
INDIGO_INCHI_EXPORT int indigoInchiDispose(qword id);

INDIGO_INCHI_EXPORT int indigoInchiResetOptions();

INDIGO_INCHI_EXPORT int indigoInchiLoadMolecule(const char *inchi_string);

INDIGO_INCHI_EXPORT const char *indigoInchiGetInchi(int molecule);

INDIGO_INCHI_EXPORT const char *indigoInchiGetInchiKey(const char *inchi_string);

INDIGO_INCHI_EXPORT const char *indigoInchiGetWarning();

INDIGO_INCHI_EXPORT const char *indigoInchiGetLog();

INDIGO_INCHI_EXPORT const char *indigoInchiGetAuxInfo();

#endif // __indigo_inchi__
