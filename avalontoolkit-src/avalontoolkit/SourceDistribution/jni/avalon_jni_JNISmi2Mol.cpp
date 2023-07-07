//
//  Copyright (c) 2010, Novartis Institutes for BioMedical Research Inc.
//  All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met: 
//
//     * Redistributions of source code must retain the above copyright 
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above
//       copyright notice, this list of conditions and the following 
//       disclaimer in the documentation and/or other materials provided 
//       with the distribution.
//     * Neither the name of Novartis Institutes for BioMedical Research Inc. 
//       nor the names of its contributors may be used to endorse or promote 
//       products derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
// OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
// LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
/*
 * File: avalon_jni_JNISmi2Mol.cpp
 *
 * Implements the wrappers for the JNISmi2Mol class.
 */

#include "avalon_jni_JNISmi2Mol.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#ifdef __cplusplus
extern "C" {
#endif

#include "local.h"
#include "reaccs.h"
#include "reaccsio.h"
#include "utilities.h"
#include "smi2mol.h"
#include "shortcut.h"
#include "depictutil.h"
#include "patclean.h"

/* Referred to in local.h but not used */
FILE *log_file = (FILE *)NULL;

void logString(char *str)
{
   FILE *fp;
   fp = fopen("c:\\temp\\tmp.log", "a");
   fprintf(fp, "%s\n", str);
   fclose(fp);
}

/*
 * Class:     JNISmi2Mol
 * Method:    smilesToMOLFile
 * Signature: (Ljava/lang/String;Ljava/lang/String;)I
 *
 * Converts the SMILES string *smiles to a MOL-file named *fname.
 *
 * The file is cleared in case of error.
 */
JNIEXPORT jint JNICALL
Java_avalon_jni_JNISmi2Mol_smilesToMOLFile(JNIEnv *env,
                                          jobject thisObj,
                                          jstring smilesObj,
                                          jstring fnameObj)
{
   int result = TRUE;
   FILE *fp;
   struct reaccs_molecule_t *mp;
   unsigned int i;
   const char *const_smiles;
   const char *const_fname;
   jboolean isCopy = JNI_FALSE;

   const_smiles = env->GetStringUTFChars(smilesObj, &isCopy);
   mp = SMIToMOL(const_smiles, DO_LAYOUT | DROP_TRIVIAL_HYDROGENS);
   if (isCopy == JNI_TRUE) env->ReleaseStringUTFChars(smilesObj, const_smiles);

   const_fname = env->GetStringUTFChars(fnameObj, &isCopy);
   fp = fopen(const_fname,"w");
   if (isCopy == JNI_TRUE) env->ReleaseStringUTFChars(fnameObj, const_fname);

   /* The following is a patch to get the correct sizes into ISIS */
   if (mp)
   {
      for (i=0; i<mp->n_atoms; i++)
      {
         mp->atom_array[i].x *= 0.5;
         mp->atom_array[i].y *= 0.5;
      }

      PrintREACCSMolecule(fp,mp,"");
      FreeMolecule(mp);
   }
   else
      result = FALSE;
   fclose(fp);
   return (result);
}

/*
 * Class:     JNISmi2Mol
 * Method:    smilesToMOLFileWithFlags
 * Signature: (Ljava/lang/String;Ljava/lang/String;)I
 *
 * Converts the SMILES string *smiles to a MOL-file named *fname.
 *
 * The file is cleared in case of error.
 */
JNIEXPORT jint JNICALL
Java_avalon_jni_JNISmi2Mol_smilesToMOLFileWithFlags(JNIEnv *env,
                                                    jobject thisObj,
                                                    jstring smilesObj,
                                                    jstring fnameObj,
                                                    jint flags)
{
   int result = TRUE;
   FILE *fp;
   struct reaccs_molecule_t *mp;
   unsigned int i, shortcut_flags;
   const char *const_smiles;
   const char *const_fname;
   char *smiles;
   jboolean isCopy = JNI_FALSE;

   const_smiles = env->GetStringUTFChars(smilesObj, &isCopy);
   if (flags & avalon_jni_JNISmi2Mol_EXPECT_SMARTS)
       mp = SMIToMOL(const_smiles, DO_LAYOUT | EXPECT_SMARTS);
   else
       mp = SMIToMOL(const_smiles, DO_LAYOUT | DROP_TRIVIAL_HYDROGENS);
   if (isCopy == JNI_TRUE) env->ReleaseStringUTFChars(smilesObj, const_smiles);

   const_fname = env->GetStringUTFChars(fnameObj, &isCopy);
   fp = fopen(const_fname,"w");
   if (isCopy == JNI_TRUE) env->ReleaseStringUTFChars(fnameObj, const_fname);

   if (mp)
   {
      if (flags & avalon_jni_JNISmi2Mol_APPLY_SHORTCUTS)        // check mask if any shortcuts are to be applied
      {
         InitShortcuts();
         shortcut_flags = 0;
         if (flags & avalon_jni_JNISmi2Mol_APPLY_AMINO_ACIDS) shortcut_flags |= AMINO_ACIDS | STANDARD_SHORTCUT;
         if (flags & avalon_jni_JNISmi2Mol_EXTENDED_SHORTCUTS) shortcut_flags |= EXTENDED_SHORTCUT|N_METHYL_SHORTCUT;
         if (flags & avalon_jni_JNISmi2Mol_NON_STANDARD_SHORTCUTS) shortcut_flags |= NON_STANDARD_SHORTCUT;
         if (flags & avalon_jni_JNISmi2Mol_APPLY_PROTECTING_GROUPS) shortcut_flags |= PROTECTING_GROUP;
         if (flags & avalon_jni_JNISmi2Mol_CATCH_ALL_SHORTCUTS) shortcut_flags |= CATCH_ALL;
         mp = ApplyShortcuts(mp, shortcut_flags);
         if (mp)
         {
             smiles = MOLToSMIExt(mp, ISOMERIC_SMILES|AROMATIC_SMILES, (int *)NULL, (char **)NULL);
             if (smiles)
             {
                 FreeMolecule(mp);
                 mp = SMIToMOL(smiles, DO_LAYOUT | DROP_TRIVIAL_HYDROGENS);
                 MyFree((char *)smiles);
             }
else fprintf(stderr, "broken SMILES\n");
         }
else fprintf(stderr, "broken molecule\n");
      }
      if (mp)   // it's possible that the SMILES with shortcuts get's screwed up
      {
          /* The following is a patch to get the correct sizes into ISIS */
          for (i=0; i<mp->n_atoms; i++)
          {
             mp->atom_array[i].x *= 0.5;
             mp->atom_array[i].y *= 0.5;
          }

          PrintREACCSMolecule(fp,mp,"");
          FreeMolecule(mp);
      }
      else
         fprintf(stderr, "broken abbreviated SMILES = '%s'\n", smiles);
   }
   else
      result = FALSE;
   fclose(fp);
   return (result);
}

/*
 * Class:     JNISmi2Mol
 * Method:    smilesToMOLFileWithTemplate
 * Signature: (Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I
 *
 * This function writes the MOL file corresponding to smiles to the
 * file fname using the connection table in tplCT to clean it.
 *
 * It returns 0 if the operation was successful and non-0 otherwise.
 */
JNIEXPORT jint JNICALL
Java_avalon_jni_JNISmi2Mol_smilesToMOLFileWithTemplate(JNIEnv *env,
                                                      jobject thisObj,
                                                      jstring smilesObj,
                                                      jstring fnameObj,
                                                      jstring tplCTObj)
{
   int result = TRUE;
   FILE *fp;
   struct reaccs_molecule_t *mp;
   unsigned int i;
   int itmp;
   const char *const_smiles;
   const char *const_fname;
   jboolean isCopy = JNI_FALSE;

   const char *const_tplCT;
   Fortran_FILE *ffp;
   struct reaccs_molecule_t *tpl;

   // Read template
   const_tplCT = env->GetStringUTFChars(tplCTObj, &isCopy);
   ffp = FortranStringOpen((char *)const_tplCT);
   tpl = TypeAlloc(1,struct reaccs_molecule_t);
   if (FORTRAN_NORMAL != ReadREACCSMolecule(ffp,tpl,""))
   {
      fprintf(stderr, "failed to read template\n");
      FreeMolecule(tpl);
      tpl = (struct reaccs_molecule_t *)NULL;
   }
   else
      MakeHydrogensImplicit(tpl);
   FortranClose(ffp);
   if (isCopy == JNI_TRUE) env->ReleaseStringUTFChars(tplCTObj, const_tplCT);

   const_smiles = env->GetStringUTFChars(smilesObj, &isCopy);
   mp = SMIToMOL(const_smiles, DO_LAYOUT | DROP_TRIVIAL_HYDROGENS);
   if (isCopy == JNI_TRUE) env->ReleaseStringUTFChars(smilesObj, const_smiles);

   if (tpl != (struct reaccs_molecule_t *)NULL)
   {
      itmp = TemplateClean(mp, tpl);
   }

   const_fname = env->GetStringUTFChars(fnameObj, &isCopy);
   fp = fopen(const_fname,"w");
   if (isCopy == JNI_TRUE) env->ReleaseStringUTFChars(fnameObj, const_fname);

   /* The following is a patch to get the correct sizes into ISIS */
   if (mp)
   {
      for (i=0; i<mp->n_atoms; i++)
      {
         mp->atom_array[i].x *= 0.5;
         mp->atom_array[i].y *= 0.5;
      }

      PrintREACCSMolecule(fp,mp,"");
      FreeMolecule(mp);
   }
   else
      result = FALSE;
   fclose(fp);
   if (tpl != (struct reaccs_molecule_t *)NULL) FreeMolecule(tpl);
   return (result);
}

/*
 * Class:     JNISmi2Mol
 * Method:    mwFromSmiles
 * Signature: (Ljava/lang/String;)D
 */
JNIEXPORT jdouble JNICALL
Java_avalon_jni_JNISmi2Mol_mwFromSmiles(JNIEnv  *env,
                                       jobject  thisObj,
                                       jstring smilesObj)
{
   char buffer[100];
   double mw;
   const char *const_smiles;
   char smiles[1000];
   jboolean isCopy = JNI_FALSE;
   
   const_smiles = env->GetStringUTFChars(smilesObj, &isCopy);
   strcpy(smiles, const_smiles);
   SmilesToMWMF(smiles, &mw, buffer);
   if (isCopy == JNI_TRUE) env->ReleaseStringUTFChars(smilesObj, const_smiles);

   return (mw);
}

/*
 * Class:     JNISmi2Mol
 * Method:    MOLFileToSmilesBytes
 * Signature: ([BLjava/lang/String;)I
 */
JNIEXPORT jint JNICALL
Java_avalon_jni_JNISmi2Mol_MOLFileToSmilesBytes(JNIEnv *env,
                                               jobject thisObj,
                                               jbyteArray buffer,
                                               jstring fnameObj)
{
   const char *const_fname;
   int size;
   char *smiles;
   jbyte *bytes;
   jboolean isCopy = JNI_FALSE;

   const_fname = env->GetStringUTFChars(fnameObj, &isCopy);
   size = 999;
   smiles = MOLFileToSMILESString(&size, (char*)const_fname);
   if (isCopy == JNI_TRUE) env->ReleaseStringUTFChars(fnameObj, const_fname);

   if (size <= 0) return (0);
   size = strlen(smiles);
   if (size >= env->GetArrayLength(buffer))
   {
       MyFree(smiles);
       return (-size);
   }

   bytes = env->GetByteArrayElements(buffer, &isCopy);
   strncpy((char *)bytes, smiles, size);
   if (isCopy == JNI_TRUE) env->ReleaseByteArrayElements(buffer, bytes, 0);
   MyFree(smiles);
   return (size);
}

/*
 * Class:     JNISmi2Mol
 * Method:    MOLFileToSMARTSBytes
 * Signature: ([BLjava/lang/String;)I
 */
JNIEXPORT jint JNICALL
Java_avalon_jni_JNISmi2Mol_MOLFileToSMARTSBytes(JNIEnv *env,
                                                jobject thisObj,
                                                jbyteArray buffer,
                                                jstring fnameObj)
{
   const char *const_fname;
   int size;
   char *smarts;
   jbyte *bytes;
   jboolean isCopy = JNI_FALSE;

   const_fname = env->GetStringUTFChars(fnameObj, &isCopy);
   size = 999;
   smarts = MOLFileToSMARTSString(&size, (char*)const_fname);
   if (isCopy == JNI_TRUE) env->ReleaseStringUTFChars(fnameObj, const_fname);

   if (smarts == 0  ||  size <= 0) return (0);
   size = strlen(smarts);
   if (size >= env->GetArrayLength(buffer))
   {
       MyFree(smarts);
       return (-size);
   }

   bytes = env->GetByteArrayElements(buffer, &isCopy);
   strncpy((char *)bytes, smarts, size);
   if (isCopy == JNI_TRUE) env->ReleaseByteArrayElements(buffer, bytes, 0);
   MyFree(smarts);
   return (size);
}

#ifdef __cplusplus
}
#endif
