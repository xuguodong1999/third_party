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

#ifndef __indigo__
#define __indigo__

#include <stdint.h>
#include "indigo_export.h"

#if defined(_WIN32) && !defined(__MINGW32__)
#define qword unsigned __int64
#else
#define qword unsigned long long
#endif

#ifndef __byte_typedef__
#define __byte_typedef__
typedef unsigned char byte;
#endif

#ifdef __cplusplus
extern "C" {
#endif
/* All integer and float functions return -1 on error. */
/* All string functions return zero pointer on error. */

/* Almost all string functions return the same pointer on success;
   you should not free() it, but rather strdup() it if you want to keep it. */

/* System */

INDIGO_EXPORT const char *indigoVersion();

// Allocate a new session. Each session has its own
// set of objects created and options set up.
INDIGO_EXPORT qword indigoAllocSessionId();
// Switch to another session. The session, if was not allocated
// previously, is allocated automatically and initialized with
// empty set of objects and default options.
INDIGO_EXPORT void indigoSetSessionId(qword id);
// Release session. The memory used by the released session
// is not freed, but the number will be reused on
// further allocations.
INDIGO_EXPORT void indigoReleaseSessionId(qword id);

// Get the last error message
INDIGO_EXPORT const char *indigoGetLastError(void);

typedef void (*INDIGO_ERROR_HANDLER)(const char *message, void *context);
INDIGO_EXPORT void indigoSetErrorHandler(INDIGO_ERROR_HANDLER handler, void *context);

// Free an object
INDIGO_EXPORT int indigoFree(int handle);
// Clone an object
INDIGO_EXPORT int indigoClone(int object);
// Count object currently allocated
INDIGO_EXPORT int indigoCountReferences(void);

// Deallocate all the objects in the current session
INDIGO_EXPORT int indigoFreeAllObjects();

/* Options */

INDIGO_EXPORT int indigoSetOption(const char *name, const char *value);
INDIGO_EXPORT int indigoSetOptionInt(const char *name, int value);
INDIGO_EXPORT int indigoSetOptionBool(const char *name, int value);
INDIGO_EXPORT int indigoSetOptionFloat(const char *name, float value);
INDIGO_EXPORT int indigoSetOptionColor(const char *name, float r, float g, float b);
INDIGO_EXPORT int indigoSetOptionXY(const char *name, int x, int y);
INDIGO_EXPORT int indigoResetOptions();

INDIGO_EXPORT const char *indigoGetOption(const char *name);
INDIGO_EXPORT int indigoGetOptionInt(const char *name, int *value);
INDIGO_EXPORT int indigoGetOptionBool(const char *name, int *value);
INDIGO_EXPORT int indigoGetOptionFloat(const char *name, float *value);
INDIGO_EXPORT int indigoGetOptionColor(const char *name, float *r, float *g, float *b);
INDIGO_EXPORT int indigoGetOptionXY(const char *name, int *x, int *y);

INDIGO_EXPORT const char *indigoGetOptionType(const char *name);

/* Basic input-output */

// indigoRead*** return a new reader object.
// indigoLoad*** return a new reader object which already
// contains all the data and does not depend on the given
// string/buffer. All these functions are low-level and
// rarely needed to anyone.

INDIGO_EXPORT int indigoReadFile(const char *filename);
INDIGO_EXPORT int indigoReadString(const char *str);
INDIGO_EXPORT int indigoLoadString(const char *str);
INDIGO_EXPORT int indigoReadBuffer(const char *buffer, int size);
INDIGO_EXPORT int indigoLoadBuffer(const char *buffer, int size);

// indigoWrite*** return a new writer object.

INDIGO_EXPORT int indigoWriteFile(const char *filename);
INDIGO_EXPORT int indigoWriteBuffer(void);

// Closes the file output stream but does not delete the object
INDIGO_EXPORT int indigoClose(int output);

/* Iterators */

/* Iterators work in the following way:
 *
 * int item, iter = indigoIterate***(...)
 *
 * if (iter == -1)
 * {
 *    fprintf(stderr, "%s", indigoGetLastError());
 *    return;
 * }
 *
 * while (item = indigoNext(iter))
 * {
 *    if (item == -1)
 *    {
 *       fprintf(stderr, "%s", indigoGetLastError());
 *       break;
 *    }
 *
 *    printf("on item #%d\n", indigoIndex(item));
 *
 *    // do something with item
 *
 *    indigoFree(item);
 * }
 * indigoFree(iter);
 */

// Obtains the next element, returns zero if there is no next element
INDIGO_EXPORT int indigoNext(int iter);
// Does not obtain the next element, just tells if there is one
INDIGO_EXPORT int indigoHasNext(int iter);
// Returns the index of the element
INDIGO_EXPORT int indigoIndex(int item);

// Removes the item from its container (usually a molecule)
INDIGO_EXPORT int indigoRemove(int item);

/* Molecules, query molecules, SMARTS */

INDIGO_EXPORT int indigoCreateMolecule(void);
INDIGO_EXPORT int indigoCreateQueryMolecule(void);

INDIGO_EXPORT int indigoLoadStructureFromString(const char *string, const char *params);
INDIGO_EXPORT int indigoLoadStructureFromBuffer(const byte *string, int bufferSize, const char *params);
INDIGO_EXPORT int indigoLoadStructureFromFile(const char *filename, const char *params);

INDIGO_EXPORT int indigoLoadMolecule(int source);
INDIGO_EXPORT int indigoLoadMoleculeFromString(const char *string);
INDIGO_EXPORT int indigoLoadMoleculeFromFile(const char *filename);
INDIGO_EXPORT int indigoLoadMoleculeFromBuffer(const char *buffer, int size);

INDIGO_EXPORT int indigoLoadQueryMolecule(int source);
INDIGO_EXPORT int indigoLoadQueryMoleculeFromString(const char *string);
INDIGO_EXPORT int indigoLoadQueryMoleculeFromFile(const char *filename);
INDIGO_EXPORT int indigoLoadQueryMoleculeFromBuffer(const char *buffer, int size);

INDIGO_EXPORT int indigoLoadSmarts(int source);
INDIGO_EXPORT int indigoLoadSmartsFromString(const char *string);
INDIGO_EXPORT int indigoLoadSmartsFromFile(const char *filename);
INDIGO_EXPORT int indigoLoadSmartsFromBuffer(const char *buffer, int size);

INDIGO_EXPORT int indigoSaveMolfile(int molecule, int output);
INDIGO_EXPORT int indigoSaveMolfileToFile(int molecule, const char *filename);
INDIGO_EXPORT const char *indigoMolfile(int molecule);

INDIGO_EXPORT int indigoSaveJsonToFile(int item, const char *filename);
INDIGO_EXPORT int indigoSaveJson(int item, int output);

// accepts molecules and reactions (but not query ones)
INDIGO_EXPORT int indigoSaveCml(int object, int output);
INDIGO_EXPORT int indigoSaveCmlToFile(int object, const char *filename);
INDIGO_EXPORT const char *indigoCml(int object);
INDIGO_EXPORT const char *indigoCdxBase64(int object);

// accepts molecules and reactions
INDIGO_EXPORT int indigoSaveCdxml(int object, int output);
INDIGO_EXPORT int indigoSaveCdx(int item, int output);

INDIGO_EXPORT const char *indigoCdxml(int item);

INDIGO_EXPORT int indigoSaveCdxmlToFile(int object, const char *filename);
INDIGO_EXPORT int indigoSaveCdxToFile(int item, const char *filename);

INDIGO_EXPORT const char *indigoCdxml(int object);

// the output must be a file or a buffer, but not a string
// (because MDLCT data usually contains zeroes)
INDIGO_EXPORT int indigoSaveMDLCT(int item, int output);

INDIGO_EXPORT const char *indigoJson(int object);

/*
Converts a chemical name into a corresponding structure
Returns -1 if parsing fails or no structure is found
Parameters:
   name - a name to parse
   params - a string containing parsing options or nullptr if no options are changed
*/
INDIGO_EXPORT int indigoNameToStructure(const char *name, const char *params);

/* Reactions, query reactions */
/*
 * Reaction centers
 */
enum {
    INDIGO_RC_NOT_CENTER = -1,
    INDIGO_RC_UNMARKED = 0,
    INDIGO_RC_CENTER = 1,
    INDIGO_RC_UNCHANGED = 2,
    INDIGO_RC_MADE_OR_BROKEN = 4,
    INDIGO_RC_ORDER_CHANGED = 8
};
INDIGO_EXPORT int indigoLoadReaction(int source);
INDIGO_EXPORT int indigoLoadReactionFromString(const char *string);
INDIGO_EXPORT int indigoLoadReactionFromFile(const char *filename);
INDIGO_EXPORT int indigoLoadReactionFromBuffer(const char *buffer, int size);

INDIGO_EXPORT int indigoLoadQueryReaction(int source);
INDIGO_EXPORT int indigoLoadQueryReactionFromString(const char *string);
INDIGO_EXPORT int indigoLoadQueryReactionFromFile(const char *filename);
INDIGO_EXPORT int indigoLoadQueryReactionFromBuffer(const char *buffer, int size);

INDIGO_EXPORT int indigoLoadReactionSmarts(int source);
INDIGO_EXPORT int indigoLoadReactionSmartsFromString(const char *string);
INDIGO_EXPORT int indigoLoadReactionSmartsFromFile(const char *filename);
INDIGO_EXPORT int indigoLoadReactionSmartsFromBuffer(const char *buffer, int size);

INDIGO_EXPORT int indigoCreateReaction(void);
INDIGO_EXPORT int indigoCreateQueryReaction(void);

INDIGO_EXPORT int indigoAddReactant(int reaction, int molecule);
INDIGO_EXPORT int indigoAddProduct(int reaction, int molecule);
INDIGO_EXPORT int indigoAddCatalyst(int reaction, int molecule);

INDIGO_EXPORT int indigoCountReactants(int reaction);
INDIGO_EXPORT int indigoCountProducts(int reaction);
INDIGO_EXPORT int indigoCountCatalysts(int reaction);
// Counts reactants, products, and catalysts.
INDIGO_EXPORT int indigoCountMolecules(int reaction);
INDIGO_EXPORT int indigoGetMolecule(int reaction, int index);

INDIGO_EXPORT int indigoIterateReactants(int reaction);
INDIGO_EXPORT int indigoIterateProducts(int reaction);
INDIGO_EXPORT int indigoIterateCatalysts(int reaction);
// Returns an iterator for reactants, products, and catalysts.
INDIGO_EXPORT int indigoIterateMolecules(int reaction);

INDIGO_EXPORT int indigoSaveRxnfile(int reaction, int output);
INDIGO_EXPORT int indigoSaveRxnfileToFile(int reaction, const char *filename);
INDIGO_EXPORT const char *indigoRxnfile(int reaction);

// Method for query optimizations for faster substructure search
// (works for both query molecules and query reactions)
INDIGO_EXPORT int indigoOptimize(int query, const char *options);

// Methods for structure normalization
// It neutrailzes charges, resolves 5-valence Nitrogen, removes hydrogens and etc.
// Default options is empty.
INDIGO_EXPORT int indigoNormalize(int structure, const char *options);

// Method for molecule and query standardizing
// It stadrdize charges, stereo and etc.
INDIGO_EXPORT int indigoStandardize(int item);

// Method for structure ionization at specified pH and pH tollerance
INDIGO_EXPORT int indigoIonize(int item, float pH, float pH_toll);

// Method for building PKA model
INDIGO_EXPORT int indigoBuildPkaModel(int max_level, float threshold, const char *filename);

INDIGO_EXPORT float *indigoGetAcidPkaValue(int item, int atom, int level, int min_level);
INDIGO_EXPORT float *indigoGetBasicPkaValue(int item, int atom, int level, int min_level);

// Automatic reaction atom-to-atom mapping
// mode is one of the following (separated by a space):
//    "discard" : discards the existing mapping entirely and considers only
//                the existing reaction centers (the default)
//    "keep"    : keeps the existing mapping and maps unmapped atoms
//    "alter"   : alters the existing mapping, and maps the rest of the
//                reaction but may change the existing mapping
//    "clear"   : removes the mapping from the reaction.
//
//    "ignore_charges" : do not consider atom charges while searching
//    "ignore_isotopes" : do not consider atom isotopes while searching
//    "ignore_valence" : do not consider atom valence while searching
//    "ignore_radicals" : do not consider atom radicals while searching
INDIGO_EXPORT int indigoAutomap(int reaction, const char *mode);

// Returns mapping number. It might appear that there is more them
// one atom with the same number in AAM
// Value 0 means no mapping number has been specified.
INDIGO_EXPORT int indigoGetAtomMappingNumber(int reaction, int reaction_atom);
INDIGO_EXPORT int indigoSetAtomMappingNumber(int reaction, int reaction_atom, int number);

// Getters and setters for reacting centers
INDIGO_EXPORT int indigoGetReactingCenter(int reaction, int reaction_bond, int *rc);
INDIGO_EXPORT int indigoSetReactingCenter(int reaction, int reaction_bond, int rc);

// Clears all reaction AAM information
INDIGO_EXPORT int indigoClearAAM(int reaction);

// Corrects reacting centers according to AAM
INDIGO_EXPORT int indigoCorrectReactingCenters(int reaction);

/* Accessing a molecule */

enum {
    INDIGO_ABS = 1,
    INDIGO_OR = 2,
    INDIGO_AND = 3,
    INDIGO_EITHER = 4,
    INDIGO_UP = 5,
    INDIGO_DOWN = 6,
    INDIGO_CIS = 7,
    INDIGO_TRANS = 8,
    INDIGO_CHAIN = 9,
    INDIGO_RING = 10,
    INDIGO_ALLENE = 11,

    INDIGO_SINGLET = 101,
    INDIGO_DOUBLET = 102,
    INDIGO_TRIPLET = 103,
};

// Returns an iterator for all atoms of the given
// molecule, including r-sites and pseudoatoms.
INDIGO_EXPORT int indigoIterateAtoms(int molecule);
INDIGO_EXPORT int indigoIteratePseudoatoms(int molecule);
INDIGO_EXPORT int indigoIterateRSites(int molecule);
INDIGO_EXPORT int indigoIterateStereocenters(int molecule);
INDIGO_EXPORT int indigoIterateAlleneCenters(int molecule);
INDIGO_EXPORT int indigoIterateRGroups(int molecule);

INDIGO_EXPORT int indigoCountRGroups(int molecule);

INDIGO_EXPORT int indigoIsPseudoatom(int atom);
INDIGO_EXPORT int indigoIsRSite(int atom);
INDIGO_EXPORT int indigoIsTemplateAtom(int atom);

// returns INDIGO_{ABS,OR,AND,EITHER}
// or zero if the atom is not a stereoatom
INDIGO_EXPORT int indigoStereocenterType(int atom);
INDIGO_EXPORT int indigoChangeStereocenterType(int atom, int type);

INDIGO_EXPORT int indigoStereocenterGroup(int atom);
INDIGO_EXPORT int indigoSetStereocenterGroup(int atom, int group);

// returns 4 integers with atom indices that defines stereocenter pyramid
INDIGO_EXPORT const int *indigoStereocenterPyramid(int atom);

INDIGO_EXPORT int indigoSingleAllowedRGroup(int rsite);

INDIGO_EXPORT int indigoAddStereocenter(int atom, int type, int v1, int v2, int v3, int v4);

// Applicable to an R-Group, but not to a molecule
INDIGO_EXPORT int indigoIterateRGroupFragments(int rgroup);
// Applicable to an R-Group and to a molecule
// Returns maximal order of attachment points
INDIGO_EXPORT int indigoCountAttachmentPoints(int item);
INDIGO_EXPORT int indigoIterateAttachmentPoints(int item, int order);

INDIGO_EXPORT const char *indigoSymbol(int atom);
INDIGO_EXPORT int indigoDegree(int atom);

// Returns zero if the charge is ambiguous
// If the charge is nonambiguous, returns 1 and writes *charge
INDIGO_EXPORT int indigoGetCharge(int atom, int *charge);
// Same as indigoGetCharge
INDIGO_EXPORT int indigoGetExplicitValence(int atom, int *valence);

INDIGO_EXPORT int indigoSetExplicitValence(int atom, int valence);

// Returns a number of element from the periodic table.
// Returns zero on ambiguous atom.
// Can not be applied to pseudo-atoms and R-sites.
INDIGO_EXPORT int indigoAtomicNumber(int atom);
// Returns zero on unspecified or ambiguous isotope
INDIGO_EXPORT int indigoIsotope(int atom);
// Not applicable to query molecules.
INDIGO_EXPORT int indigoValence(int atom);
// Return atom hybridization
// S = 1,
// SP = 2,
// SP2 = 3,
// SP3 = 4,
// SP3D = 5,
// SP3D2 = 6,
// SP3D3 = 7,
// SP3D4 = 8,
// SP2D = 9
INDIGO_EXPORT int indigoGetHybridization(int atom);
// Returns zero if valence of the atom is wrong
INDIGO_EXPORT int indigoCheckValence(int atom);

// Returns one if atom or bond belongs Query or has any query feature
INDIGO_EXPORT int indigoCheckQuery(int item);

// Returns one if structure contains RGroup features (RSites, RGroups or attachment points
INDIGO_EXPORT int indigoCheckRGroups(int item);

// Returns check result for Indigo object as text file for requested properties as JSON
INDIGO_EXPORT const char *indigoCheck(const char *item, const char *check_flags, const char *load_params);

// Returns check result for Indigo object for requested properties as JSON
INDIGO_EXPORT const char *indigoCheckObj(int item, const char *check_flags);

// Returns check result for structure against requested properties
INDIGO_EXPORT const char *indigoCheckStructure(const char *structure, const char *props);

// Applicable to atoms, query atoms, and molecules. Can fail
// (return zero) on query atoms where the number of hydrogens
// is not definitely known. Otherwise, returns one and writes *hydro.
INDIGO_EXPORT int indigoCountHydrogens(int item, int *hydro);

// Applicable to non-query molecules and atoms.
INDIGO_EXPORT int indigoCountImplicitHydrogens(int item);

// On success, returns always the same pointer to a 3-element array;
// you should not free() it, but rather memcpy() it if you want to keep it.
INDIGO_EXPORT float *indigoXYZ(int atom);

INDIGO_EXPORT int indigoSetXYZ(int atom, float x, float y, float z);

INDIGO_EXPORT int indigoCountSuperatoms(int molecule);
INDIGO_EXPORT int indigoCountDataSGroups(int molecule);
INDIGO_EXPORT int indigoCountRepeatingUnits(int molecule);
INDIGO_EXPORT int indigoCountMultipleGroups(int molecule);
INDIGO_EXPORT int indigoCountGenericSGroups(int molecule);
INDIGO_EXPORT int indigoIterateDataSGroups(int molecule);
INDIGO_EXPORT int indigoIterateSuperatoms(int molecule);
INDIGO_EXPORT int indigoIterateGenericSGroups(int molecule);
INDIGO_EXPORT int indigoIterateRepeatingUnits(int molecule);
INDIGO_EXPORT int indigoIterateMultipleGroups(int molecule);

INDIGO_EXPORT int indigoIterateTGroups(int molecule);
INDIGO_EXPORT int indigoIterateSGroups(int molecule);

INDIGO_EXPORT int indigoGetSuperatom(int molecule, int index);
INDIGO_EXPORT int indigoGetDataSGroup(int molecule, int index);
INDIGO_EXPORT int indigoGetGenericSGroup(int molecule, int index);
INDIGO_EXPORT int indigoGetMultipleGroup(int molecule, int index);
INDIGO_EXPORT int indigoGetRepeatingUnit(int molecule, int index);

INDIGO_EXPORT const char *indigoDescription(int data_sgroup);
INDIGO_EXPORT const char *indigoData(int data_sgroup);

INDIGO_EXPORT int
indigoAddDataSGroup(int molecule, int natoms, int *atoms, int nbonds, int *bonds, const char *description,
                    const char *data);

INDIGO_EXPORT int indigoAddSuperatom(int molecule, int natoms, int *atoms, const char *name);

INDIGO_EXPORT int indigoSetDataSGroupXY(int sgroup, float x, float y, const char *options);

INDIGO_EXPORT int indigoSetSGroupData(int sgroup, const char *data);
INDIGO_EXPORT int indigoSetSGroupCoords(int sgroup, float x, float y);
INDIGO_EXPORT int indigoSetSGroupDescription(int sgroup, const char *description);
INDIGO_EXPORT int indigoSetSGroupFieldName(int sgroup, const char *name);
INDIGO_EXPORT int indigoSetSGroupQueryCode(int sgroup, const char *querycode);
INDIGO_EXPORT int indigoSetSGroupQueryOper(int sgroup, const char *queryoper);
INDIGO_EXPORT int indigoSetSGroupDisplay(int sgroup, const char *option);
INDIGO_EXPORT int indigoSetSGroupLocation(int sgroup, const char *option);
INDIGO_EXPORT int indigoSetSGroupTag(int sgroup, const char *tag);
INDIGO_EXPORT int indigoSetSGroupTagAlign(int sgroup, int tag_align);
INDIGO_EXPORT int indigoSetSGroupDataType(int sgroup, const char *type);
INDIGO_EXPORT int indigoSetSGroupXCoord(int sgroup, float x);
INDIGO_EXPORT int indigoSetSGroupYCoord(int sgroup, float y);

INDIGO_EXPORT int indigoCreateSGroup(const char *type, int mapping, const char *name);
INDIGO_EXPORT const char *indigoGetSGroupClass(int sgroup);
INDIGO_EXPORT const char *indigoGetSGroupName(int sgroup);
INDIGO_EXPORT int indigoSetSGroupClass(int sgroup, const char *sgclass);
INDIGO_EXPORT int indigoSetSGroupName(int sgroup, const char *sgname);
INDIGO_EXPORT int indigoGetSGroupNumCrossBonds(int sgroup);

INDIGO_EXPORT int indigoAddSGroupAttachmentPoint(int sgroup, int aidx, int lvidx, const char *apid);
INDIGO_EXPORT int indigoDeleteSGroupAttachmentPoint(int sgroup, int index);
INDIGO_EXPORT int indigoGetSGroupDisplayOption(int sgroup);
INDIGO_EXPORT int indigoSetSGroupDisplayOption(int sgroup, int option);
INDIGO_EXPORT int indigoGetSGroupSeqId(int sgroup);
INDIGO_EXPORT float *indigoGetSGroupCoords(int sgroup);

INDIGO_EXPORT int indigoGetSGroupMultiplier(int sgroup);
INDIGO_EXPORT int indigoSetSGroupMultiplier(int sgroup, int multiplier);

INDIGO_EXPORT const char *indigoGetRepeatingUnitSubscript(int sgroup);
INDIGO_EXPORT int indigoGetRepeatingUnitConnectivity(int sgroup);

INDIGO_EXPORT int
indigoSetSGroupBrackets(int sgroup, int brk_style, float x1, float y1, float x2, float y2, float x3, float y3, float x4,
                        float y4);

INDIGO_EXPORT int indigoFindSGroups(int item, const char *property, const char *value);

INDIGO_EXPORT int indigoGetSGroupType(int item);
INDIGO_EXPORT int indigoGetSGroupIndex(int item);

INDIGO_EXPORT int indigoGetSGroupOriginalId(int sgroup);
INDIGO_EXPORT int indigoSetSGroupOriginalId(int sgroup, int original);
INDIGO_EXPORT int indigoGetSGroupParentId(int sgroup);
INDIGO_EXPORT int indigoSetSGroupParentId(int sgroup, int parent);

INDIGO_EXPORT int indigoAddTemplate(int molecule, int templates, const char *tname);
INDIGO_EXPORT int indigoRemoveTemplate(int molecule, const char *tname);
INDIGO_EXPORT int indigoFindTemplate(int molecule, const char *tname);

INDIGO_EXPORT const char *indigoGetTGroupClass(int tgroup);
INDIGO_EXPORT const char *indigoGetTGroupName(int tgroup);
INDIGO_EXPORT const char *indigoGetTGroupAlias(int tgroup);

INDIGO_EXPORT int indigoTransformSCSRtoCTAB(int item);
INDIGO_EXPORT int indigoTransformCTABtoSCSR(int molecule, int templates);

INDIGO_EXPORT int indigoResetCharge(int atom);
INDIGO_EXPORT int indigoResetExplicitValence(int atom);
INDIGO_EXPORT int indigoResetIsotope(int atom);

INDIGO_EXPORT int indigoSetAttachmentPoint(int atom, int order);
INDIGO_EXPORT int indigoClearAttachmentPoints(int item);

INDIGO_EXPORT int indigoRemoveConstraints(int item, const char *type);
INDIGO_EXPORT int indigoAddConstraint(int item, const char *type, const char *value);
INDIGO_EXPORT int indigoAddConstraintNot(int item, const char *type, const char *value);
INDIGO_EXPORT int indigoAddConstraintOr(int atom, const char *type, const char *value);

INDIGO_EXPORT int indigoResetStereo(int item);
INDIGO_EXPORT int indigoInvertStereo(int item);

INDIGO_EXPORT int indigoCountAtoms(int molecule);
INDIGO_EXPORT int indigoCountBonds(int molecule);
INDIGO_EXPORT int indigoCountPseudoatoms(int molecule);
INDIGO_EXPORT int indigoCountRSites(int molecule);

INDIGO_EXPORT int indigoIterateBonds(int molecule);
// Returns 1/2/3 if the bond is a single/double/triple bond
// Returns 4 if the bond is an aromatic bond
// Returns zero if the bond is ambiguous (query bond)
INDIGO_EXPORT int indigoBondOrder(int bond);

// Returns INDIGO_{UP/DOWN/EITHER/CIS/TRANS},
// or zero if the bond is not a stereobond
INDIGO_EXPORT int indigoBondStereo(int bond);

// Returns INDIGO_{CHAIN/RING},
INDIGO_EXPORT int indigoTopology(int bond);

// Returns an iterator whose elements can be treated as atoms.
// At the same time, they support indigoBond() call.
INDIGO_EXPORT int indigoIterateNeighbors(int atom);

// Applicable exclusively to the "atom neighbors iterator".
// Returns a bond to the neighbor atom.
INDIGO_EXPORT int indigoBond(int nei);

// Accessing atoms and bonds by index
INDIGO_EXPORT int indigoGetAtom(int molecule, int idx);
INDIGO_EXPORT int indigoGetBond(int molecule, int idx);

INDIGO_EXPORT int indigoSource(int bond);
INDIGO_EXPORT int indigoDestination(int bond);

INDIGO_EXPORT int indigoClearCisTrans(int handle);
INDIGO_EXPORT int indigoClearStereocenters(int handle);
INDIGO_EXPORT int indigoCountStereocenters(int molecule);
INDIGO_EXPORT int indigoClearAlleneCenters(int molecule);
INDIGO_EXPORT int indigoCountAlleneCenters(int molecule);

INDIGO_EXPORT int indigoResetSymmetricCisTrans(int handle);
INDIGO_EXPORT int indigoResetSymmetricStereocenters(int handle);
INDIGO_EXPORT int indigoMarkEitherCisTrans(int handle);
INDIGO_EXPORT int indigoMarkStereobonds(int handle);

INDIGO_EXPORT int indigoValidateChirality(int handle);

// Accepts a symbol from the periodic table (like "C" or "Br"),
// or a pseudoatom symbol, like "Pol". Returns the added atom.
INDIGO_EXPORT int indigoAddAtom(int molecule, const char *symbol);
// Set a new atom instead of specified
INDIGO_EXPORT int indigoResetAtom(int atom, const char *symbol);

INDIGO_EXPORT const char *indigoGetTemplateAtomClass(int atom);
INDIGO_EXPORT int indigoSetTemplateAtomClass(int atom, const char *name);

// Accepts Rsite name "R" (or just ""), "R1", "R2" or list with names "R1 R3"
INDIGO_EXPORT int indigoAddRSite(int molecule, const char *name);
INDIGO_EXPORT int indigoSetRSite(int atom, const char *name);

INDIGO_EXPORT int indigoSetCharge(int atom, int charge);
INDIGO_EXPORT int indigoSetIsotope(int atom, int isotope);

// If the radical is nonambiguous, returns 1 and writes *electrons
INDIGO_EXPORT int indigoGetRadicalElectrons(int atom, int *electrons);
// If the radical is nonambiguous, returns 1 and writes *radical
INDIGO_EXPORT int indigoGetRadical(int atom, int *radical);
INDIGO_EXPORT int indigoSetRadical(int atom, int radical);
INDIGO_EXPORT int indigoResetRadical(int atom);

// Used for hacks with aromatic molecules; not recommended to use
// in other situations
INDIGO_EXPORT int indigoSetImplicitHCount(int atom, int impl_h);

// Accepts two atoms (source and destination) and the order of the new bond
// (1/2/3/4 = single/double/triple/aromatic). Returns the added bond.
INDIGO_EXPORT int indigoAddBond(int source, int destination, int order);

INDIGO_EXPORT int indigoSetBondOrder(int bond, int order);

INDIGO_EXPORT int indigoMerge(int where_to, int what);

/* Highlighting */

// Access atoms and bonds
INDIGO_EXPORT int indigoHighlight(int item);

// Access atoms, bonds, molecules, and reactions
INDIGO_EXPORT int indigoUnhighlight(int item);

// Access atoms and bonds
INDIGO_EXPORT int indigoIsHighlighted(int item);

/* Selection */

// Access atoms and bonds
INDIGO_EXPORT int indigoSelect(int item);

// Access atoms, bonds, molecules, and reactions
INDIGO_EXPORT int indigoUnselect(int item);

// Access atoms and bonds
INDIGO_EXPORT int indigoIsSelected(int item);

/* Connected components of molecules */

INDIGO_EXPORT int indigoCountComponents(int molecule);
INDIGO_EXPORT int indigoComponentIndex(int atom);
INDIGO_EXPORT int indigoIterateComponents(int molecule);

// Returns a 'molecule component' object, which can not be used as a
// [query] molecule, but supports the indigo{Count,Iterate}{Atoms,Bonds} calls,
// and also the indigoClone() call, which returns a [query] molecule.
INDIGO_EXPORT int indigoComponent(int molecule, int index);

/* Smallest Set of Smallest Rings */

INDIGO_EXPORT int indigoCountSSSR(int molecule);
INDIGO_EXPORT int indigoIterateSSSR(int molecule);

INDIGO_EXPORT int indigoIterateSubtrees(int molecule, int min_atoms, int max_atoms);
INDIGO_EXPORT int indigoIterateRings(int molecule, int min_atoms, int max_atoms);
INDIGO_EXPORT int indigoIterateEdgeSubmolecules(int molecule, int min_bonds, int max_bonds);

/* Calculation on molecules */

INDIGO_EXPORT int indigoCountHeavyAtoms(int molecule);
INDIGO_EXPORT int indigoGrossFormula(int molecule);
INDIGO_EXPORT double indigoMolecularWeight(int molecule);
INDIGO_EXPORT double indigoMostAbundantMass(int molecule);
INDIGO_EXPORT double indigoMonoisotopicMass(int molecule);
INDIGO_EXPORT const char *indigoMassComposition(int molecule);
INDIGO_EXPORT double indigoTPSA(int molecule, int includeSP);
INDIGO_EXPORT int indigoNumRotatableBonds(int molecule);
INDIGO_EXPORT int indigoNumHydrogenBondAcceptors(int molecule);
INDIGO_EXPORT int indigoNumHydrogenBondDonors(int molecule);
INDIGO_EXPORT double indigoLogP(int molecule);
INDIGO_EXPORT double indigoMolarRefractivity(int molecule);
INDIGO_EXPORT double indigoPka(int molecule);

INDIGO_EXPORT const char *indigoCanonicalSmiles(int molecule);
INDIGO_EXPORT const char *indigoLayeredCode(int molecule);

INDIGO_EXPORT int64_t indigoHash(int chemicalObject);

INDIGO_EXPORT const int *indigoSymmetryClasses(int molecule, int *count_out);

INDIGO_EXPORT int indigoHasCoord(int molecule);
INDIGO_EXPORT int indigoHasZCoord(int molecule);
INDIGO_EXPORT int indigoIsChiral(int molecule);
INDIGO_EXPORT int indigoCheckChirality(int molecule);
INDIGO_EXPORT int indigoCheck3DStereo(int molecule);
INDIGO_EXPORT int indigoCheckStereo(int molecule);

INDIGO_EXPORT int indigoIsPossibleFischerProjection(int molecule, const char *options);

INDIGO_EXPORT int indigoCreateSubmolecule(int molecule, int nvertices, int *vertices);
INDIGO_EXPORT int indigoCreateEdgeSubmolecule(int molecule, int nvertices, int *vertices, int nedges, int *edges);

INDIGO_EXPORT int indigoGetSubmolecule(int molecule, int nvertices, int *vertices);

INDIGO_EXPORT int indigoRemoveAtoms(int molecule, int nvertices, int *vertices);
INDIGO_EXPORT int indigoRemoveBonds(int molecule, int nbonds, int *bonds);

// Determines and applies the best transformation to the given molecule
// so that the specified atoms move as close as possible to the desired
// positions. The size of desired_xyz is equal to 3 * natoms.
// The return value is the root-mean-square measure of the difference
// between the desired and obtained positions.
INDIGO_EXPORT float indigoAlignAtoms(int molecule, int natoms, int *atom_ids, float *desired_xyz);

/* Things that work for both molecules and reactions */

INDIGO_EXPORT int indigoAromatize(int item);
INDIGO_EXPORT int indigoDearomatize(int item);

INDIGO_EXPORT int indigoFoldHydrogens(int item);
INDIGO_EXPORT int indigoUnfoldHydrogens(int item);

INDIGO_EXPORT int indigoLayout(int object);
INDIGO_EXPORT int indigoClean2d(int object);

INDIGO_EXPORT const char *indigoSmiles(int item);
INDIGO_EXPORT const char *indigoSmarts(int item);
INDIGO_EXPORT const char *indigoCanonicalSmarts(int item);

// Returns a "mapping" if there is an exact match, zero otherwise
// The flags string consists of space-separated flags.
// The more flags, the more restrictive matching is done.
// "ELE": Distribution of electrons: bond types, atom charges, radicals, valences
// "MAS": Atom isotopes
// "STE": Stereochemistry: chiral centers, stereogroups, and cis-trans bonds
// "FRA": Connected fragments: disallows match of separate ions in salts
// "ALL": All of the above
// By default (with null or empty flags string) all flags are on.
INDIGO_EXPORT int indigoExactMatch(int item1, int item2, const char *flags);

// "beg" and "end" refer to the two ends of the tautomeric chain. Allowed
// elements are separated by commas. '1' at the beginning means an aromatic
// atom, while '0' means an aliphatic atom.
INDIGO_EXPORT int indigoSetTautomerRule(int id, const char *beg, const char *end);

INDIGO_EXPORT int indigoRemoveTautomerRule(int id);

INDIGO_EXPORT int indigoClearTautomerRules();

INDIGO_EXPORT const char *indigoName(int handle);
INDIGO_EXPORT int indigoSetName(int handle, const char *name);

// You should not free() the obtained buffer, but rather memcpy() it if you want to keep it
INDIGO_EXPORT int indigoSerialize(int handle, byte **buf, int *size);

INDIGO_EXPORT int indigoUnserialize(const byte *buf, int size);

// Applicable to molecules/reactions obtained from SDF or RDF files,
// and to their clones, and to their R-Group deconvolutions.
INDIGO_EXPORT int indigoHasProperty(int handle, const char *prop);
INDIGO_EXPORT const char *indigoGetProperty(int handle, const char *prop);

// Applicable to newly created or cloned molecules/reactions,
// and also to molecules/reactions obtained from SDF or RDF files.
// If the property with the given name does not exist, it is created automatically.
INDIGO_EXPORT int indigoSetProperty(int item, const char *prop, const char *value);

// Does not raise an error if the given property does not exist
INDIGO_EXPORT int indigoRemoveProperty(int item, const char *prop);

// Returns an iterator that one can pass to indigoName() to
// know the name of the property. The value of the property can be
// obtained via indigoGetProperty() call to the object
INDIGO_EXPORT int indigoIterateProperties(int handle);

// Clears all properties of the molecule
INDIGO_EXPORT int indigoClearProperties(int handle);

// Accepts a molecule or reaction (but not query molecule or query reaction).
// Returns a string describing the first encountered mistake with valence.
// Returns an empty string if the input molecule/reaction is fine.
INDIGO_EXPORT const char *indigoCheckBadValence(int handle);

// Accepts a molecule or reaction (but not query molecule or query reaction).
// Returns a string describing the first encountered mistake with ambiguous H counter.
// Returns an empty string if the input molecule/reaction is fine.
INDIGO_EXPORT const char *indigoCheckAmbiguousH(int handle);

/* Fingerprints */

// Returns a 'fingerprint' object, which can then be passed to:
//   indigoToString() -- to get hexadecimal representation
//   indigoToBuffer() -- to get raw byte data
//   indigoSimilarity() -- to calculate similarity with another fingerprint
// The following fingerprint types are available:
//   "sim"     -- "Similarity fingerprint", useful for calculating
//                 similarity measures (the default)
//   "sub"     -- "Substructure fingerprint", useful for substructure screening
//   "sub-res" -- "Resonance substructure fingerprint", useful for resonance
//                 substructure screening
//   "sub-tau" -- "Tautomer substructure fingerprint", useful for tautomer
//                 substructure screening
//   "full"    -- "Full fingerprint", which has all the mentioned
//                 fingerprint types included
INDIGO_EXPORT int indigoFingerprint(int item, const char *type);

// Counts the nonzero (i.e. one) bits in a fingerprint
INDIGO_EXPORT int indigoCountBits(int fingerprint);

// Counts the number of the coinincident in two fingerprints
INDIGO_EXPORT int indigoCommonBits(int fingerprint1, int fingerprint2);

// Return one bits string for the fingerprint object
INDIGO_EXPORT const char *indigoOneBitsList(int fingerprint);

// Returns a 'fingerprint' object with data from 'buffer'
INDIGO_EXPORT int indigoLoadFingerprintFromBuffer(const byte *buffer, int size);

// Constructs a 'fingerprint' object from a normalized array of double descriptors
INDIGO_EXPORT int indigoLoadFingerprintFromDescriptors(const double *arr, int arr_len, int size, double density);

// Accepts two molecules, two reactions, or two fingerprints.
// Returns the similarity measure between them.
// Metrics: "tanimoto", "tversky", "tversky <alpha> <beta>", "euclid-sub" or "normalized-edit"
// Zero pointer or empty string defaults to "tanimoto".
// "tversky" without numbers defaults to alpha = beta = 0.5
INDIGO_EXPORT float indigoSimilarity(int item1, int item2, const char *metrics);

/* Working with SDF/RDF/SMILES/CML/CDX files  */

INDIGO_EXPORT int indigoIterateSDF(int reader);
INDIGO_EXPORT int indigoIterateRDF(int reader);
INDIGO_EXPORT int indigoIterateSmiles(int reader);
INDIGO_EXPORT int indigoIterateCML(int reader);
INDIGO_EXPORT int indigoIterateCDX(int reader);

INDIGO_EXPORT int indigoIterateSDFile(const char *filename);
INDIGO_EXPORT int indigoIterateRDFile(const char *filename);
INDIGO_EXPORT int indigoIterateSmilesFile(const char *filename);
INDIGO_EXPORT int indigoIterateCMLFile(const char *filename);
INDIGO_EXPORT int indigoIterateCDXFile(const char *filename);

// Applicable to items returned by SDF/RDF iterators.
// Returns the content of SDF/RDF item.
INDIGO_EXPORT const char *indigoRawData(int item);

// Applicable to items returned by SDF/RDF iterators.
// Returns the offset in the SDF/RDF file.
INDIGO_EXPORT int indigoTell(int handle);
INDIGO_EXPORT long long indigoTell64(int handle);

// Saves the molecule to an SDF output stream
INDIGO_EXPORT int indigoSdfAppend(int output, int item);
// Saves the molecule to a multiline SMILES output stream
INDIGO_EXPORT int indigoSmilesAppend(int output, int item);

// Similarly for RDF files, except that the header should be written first
INDIGO_EXPORT int indigoRdfHeader(int output);
INDIGO_EXPORT int indigoRdfAppend(int output, int item);

// Similarly for CML files, except that they have both header and footer
INDIGO_EXPORT int indigoCmlHeader(int output);
INDIGO_EXPORT int indigoCmlAppend(int output, int item);
INDIGO_EXPORT int indigoCmlFooter(int output);

// Create saver objects that can be used to save molecules or reactions
// Supported formats: 'sdf', 'smi' or 'smiles', 'cml', 'rdf'
// Format argument is case-insensitive
// Saver should be closed with indigoClose function
INDIGO_EXPORT int indigoCreateSaver(int output, const char *format);
INDIGO_EXPORT int indigoCreateFileSaver(const char *filename, const char *format);

// Append object to a specified saver stream
INDIGO_EXPORT int indigoAppend(int saver, int object);

/* Arrays */

INDIGO_EXPORT int indigoCreateArray();
// Note: a clone of the object is added, not the object itself
INDIGO_EXPORT int indigoArrayAdd(int arr, int object);
INDIGO_EXPORT int indigoAt(int item, int index);
INDIGO_EXPORT int indigoCount(int item);
INDIGO_EXPORT int indigoClear(int arr);
INDIGO_EXPORT int indigoIterateArray(int arr);

/* Substructure matching */

// Returns a new 'matcher' object
// 'mode' is reserved for future use; currently its value is ignored
INDIGO_EXPORT int indigoSubstructureMatcher(int target, const char *mode);

// Ignore target atom in the substructure matcher
INDIGO_EXPORT int indigoIgnoreAtom(int matcher, int atom_object);

// Ignore target atom in the substructure matcher
INDIGO_EXPORT int indigoUnignoreAtom(int matcher, int atom_object);

// Clear list of ignored target atoms in the substructure matcher
INDIGO_EXPORT int indigoUnignoreAllAtoms(int matcher);

// Returns a new 'match' object on success, zero on fail
//    matcher is an matcher object returned by indigoSubstructureMatcher
INDIGO_EXPORT int indigoMatch(int matcher, int query);

// Counts the number of embeddings of the query structure into the target
INDIGO_EXPORT int indigoCountMatches(int matcher, int query);

// Counts the number of embeddings of the query structure into the target
// If number of embeddings is more then limit then limit is returned
INDIGO_EXPORT int indigoCountMatchesWithLimit(int matcher, int query, int embeddings_limit);

// Returns substructure matches iterator
INDIGO_EXPORT int indigoIterateMatches(int matcher, int query);

// Accepts a 'match' object obtained from indigoMatchSubstructure.
// Returns a new molecule which has the query highlighted.
INDIGO_EXPORT int indigoHighlightedTarget(int match);

// Accepts an atom from the query, not an atom index.
//   You can use indigoGetAtom() to obtain the atom by its index.
// Returns the corresponding target atom, not an atom index. If query
// atom doesn't match particular atom in the target (R-group or explicit
// hydrogen) then return value is zero.
//   You can use indigoIndex() to obtain the index of the returned atom.
INDIGO_EXPORT int indigoMapAtom(int handle, int atom);

// Accepts a bond from the query, not a bond index.
//   You can use indigoGetBond() to obtain the bond by its index.
// Returns the corresponding target bond, not a bond index. If query
// bond doesn't match particular bond in the target (R-group or explicit
// hydrogen) then return value is zero.
//   You can use indigoIndex() to obtain the index of the returned bond.
INDIGO_EXPORT int indigoMapBond(int handle, int bond);

// Accepts a molecule from the query reaction, not a molecule index.
//   You can use indigoGetMolecule() to obtain the bond by its index.
// Returns the corresponding target molecule, not a reaction index. If query
// molecule doesn't match particular molecule in the target then return
// value is zero.
//   You can use indigoIndex() to obtain the index of the returned molecule.
INDIGO_EXPORT int indigoMapMolecule(int handle, int molecule);

// Accepts a molecule and options for tautomer enumeration algorithms
// Returns an iterator object over the molecules that are tautomers of this molecule.
INDIGO_EXPORT int indigoIterateTautomers(int molecule, const char *options);

/* Scaffold detection */

// Returns zero if no common substructure is found.
// Otherwise, it returns a new object, which can be
//   (i) treated as a structure: the maximum (by the number of rings) common
//       substructure of the given structures.
//  (ii) passed to indigoAllScaffolds()
INDIGO_EXPORT int indigoExtractCommonScaffold(int structures, const char *options);

// Returns an array of all possible scaffolds.
// The input parameter is the value returned by indigoExtractCommonScaffold().
INDIGO_EXPORT int indigoAllScaffolds(int extracted);

/* R-Group deconvolution */

// Returns a ``decomposition'' object that can be passed to
// indigoDecomposedMoleculeScaffold() and
// indigoIterateDecomposedMolecules()
INDIGO_EXPORT int indigoDecomposeMolecules(int scaffold, int structures);

// Returns a scaffold molecule with r-sites marking the place
// for substituents to add to form the structures given above.
INDIGO_EXPORT int indigoDecomposedMoleculeScaffold(int decomp);

// Returns an iterator which corresponds to the given collection of structures.
// indigoDecomposedMoleculeHighlighted() and
// indigoDecomposedMoleculeWithRGroups() are applicable to the
// values returned by the iterator.
INDIGO_EXPORT int indigoIterateDecomposedMolecules(int decomp);

// Returns a molecule with highlighted scaffold
INDIGO_EXPORT int indigoDecomposedMoleculeHighlighted(int decomp);

// Returns a query molecule with r-sites and "R1=...", "R2=..."
// substituents defined. The 'scaffold' part of the molecule
// is identical to the indigoDecomposedMoleculeScaffold()
INDIGO_EXPORT int indigoDecomposedMoleculeWithRGroups(int decomp);

/*
 * Decomposition Iteration API
 */
// Returns a 'decomposition' object
INDIGO_EXPORT int indigoCreateDecomposer(int scaffold);
// Returns a 'decomposition' item
INDIGO_EXPORT int indigoDecomposeMolecule(int decomp, int mol);
// Returns decomposition iterator
INDIGO_EXPORT int indigoIterateDecompositions(int deco_item);
// Adds the input decomposition to a full scaffold
INDIGO_EXPORT int indigoAddDecomposition(int decomp, int q_match);

/* R-Group convolution */

INDIGO_EXPORT int indigoGetFragmentedMolecule(int elem, const char *options);
INDIGO_EXPORT int indigoRGroupComposition(int molecule, const char *options);

/*
 * Abbreviations
 */
INDIGO_EXPORT int indigoExpandAbbreviations(int molecule);

/* Other */

INDIGO_EXPORT const char *indigoToString(int handle);
INDIGO_EXPORT const char *indigoToBase64String(int handle);
INDIGO_EXPORT int indigoToBuffer(int handle, char **buf, int *size);

/* Reaction products enumeration */

// Accepts a query reaction with markd R-sites, and array of arrays
// of substituents corresponding to the R-Sites. Returns an array of
// reactions with R-Sites replaced by the actual substituents.
INDIGO_EXPORT int indigoReactionProductEnumerate(int reaction, int monomers);

INDIGO_EXPORT int indigoTransform(int reaction, int monomers);

INDIGO_EXPORT int indigoTransformHELMtoSCSR(int monomer);

/* Debug functionality */

// Returns internal type of an object
INDIGO_EXPORT const char *indigoDbgInternalType(int object);

// Internal breakpoint
INDIGO_EXPORT void indigoDbgBreakpoint(void);

// Methods that returns profiling infromation in a human readable format
INDIGO_EXPORT const char *indigoDbgProfiling(int /*bool*/ whole_session);

// Reset profiling counters either for the current state or for the whole session
INDIGO_EXPORT int indigoDbgResetProfiling(int /*bool*/ whole_session);

// Methods that returns profiling counter value for a particular counter
INDIGO_EXPORT qword indigoDbgProfilingGetCounter(const char *name, int /*bool*/ whole_session);
#ifdef __cplusplus
}
#endif
#endif
