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
/************************************************************************/
/*                                                                      */
/*    File:           graph.h                                           */
/*                                                                      */
/*    Purpose:        This file defines the data structures used in     */
/*                    graph handling functions as well as the           */
/*                    function prototypes of them.                      */
/*                                                                      */
/************************************************************************/

#include "set.h"

struct BOND_SET_NODE
   {
      struct BOND_SET_NODE *next;
      unsigned              cardinality;
      bit_set_t            *bond_set;
   };

typedef struct BOND_SET_NODE bond_set_node;

/**************************   function prototypes   ************************/

extern
bond_set_node *NewBondSetNode(unsigned max_member);
/*
 * Allocates a new node.
 */

extern
void DisposeBondSetList(bond_set_node *node);
/*
 * Deallocates a list of bond set nodes.
 */

extern
bond_set_node *RingList(unsigned bonds[][2],
                        unsigned nbonds);
/*
 * Returns a list of basis rings of the graph defined by
 * bonds[0..nbonds-1][0..1]
 *
 * Generalized to ignore any bonds that contain nodes with number 0.
 * This can be used to perform ring analysis only on a selected subset
 * of the bonds of the source graph.
 */

extern
bond_set_node *SortRings(bond_set_node *list);
/*
 * Sorts *list into descending order with respect to cardinality.
 */

extern
bond_set_node *CombineRings(bond_set_node *list);
/*
 * Combines pairs of rings until selfconsistency to get a list of
 * smaller basis rings.
 */

extern
bond_set_node *ProperRingPairs(bond_set_node *base_rings, int maxnode,
                               unsigned bonds[][2]);
/*
 * Returns the list of all proper rings that can be generated by XORing
 * the base_rings. Note: It may happen that the XOR of two proper rings
 * yields a disconnected set of more than one ring!
 * maxnode is needed to speed up internal operations.
 */

extern
void PrintRingList(FILE *fp, bond_set_node *list, unsigned bonds[][2]);
/*
 * Debugging procedure to print a list of rings in a readable way.
 * bonds[][] is used to produce a more meaningful output.
 */
