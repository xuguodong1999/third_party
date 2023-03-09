/**********************************************************************
op2.cpp - Plugin to adds 2D coordinates using RDKit routines

Copyright (C) 2007 by Chris Morley

This file is part of the Open Babel project.
For more information, see <http://openbabel.org/>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation version 2 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
**********************************************************************

This code calls C++ routines in RDKit which are
  Copyright (C) 2003-2006 Rational Discovery LLC
    BSD license

***********************************************************************/

#include <openbabel/babelconfig.h>
#include <iostream>
#include<openbabel/op.h>
#include<openbabel/atom.h>
#include<openbabel/mol.h>
#include<openbabel/oberror.h>
#include <RDKitConv.h>
#include <GraphMol/Depictor/RDDepictor.h>
#include <Geometry/point.h>
#include <GraphMol/MolOps.h>
#include <boost/algorithm/string.hpp>
#include <boost/convert.hpp>
#include <boost/convert/strtol.hpp>

#include <string_view>
#include <vector>
#ifndef OBERROR
 #define OBERROR
#endif

namespace OpenBabel
{
  class Op2D : public OBOp //was OBERROR when with OpenBabelDLL
{
public:
  Op2D(const char* ID) : OBOp(ID, false){};
  const char* Description()
  {
    return "Generate 2D coordinates\n"
      "Uses RDKit http://www.rdkit.org";
  }
  virtual bool WorksWith(OBBase* pOb)const{ return dynamic_cast<OBMol*>(pOb)!=NULL; }
  virtual bool Do(OBBase* pOb, const char*, OpMap*, OBConversion*);
};

Op2D theOp2D("2D"); //Global instance

static void string_view_to_double(const std::string_view&s, double&v){
  auto value = boost::convert<double>(s, boost::cnv::strtol());
  if (value.has_value()) {
    v = value.get();
  }
}

/////////////////////////////////////////////////////////////////
bool Op2D::Do(OBBase* pOb, const char*, OpMap*pOptions, OBConversion*)
{
  OBMol* pmol = dynamic_cast<OBMol*>(pOb);
  if(!pmol)
    return false;

  //Do the conversion
  try
  {
    RDKit::RWMol RDMol = OBMolToRWMol(pmol);
    RDKit::MolOps::sanitizeMol(RDMol); //initializes various internl parameters
    RDGeom::INT_POINT2D_MAP coordMap;
    if (pOptions) {
      for(const auto &[key, value]: *pOptions) {
        std::string_view view = value;
        std::vector<std::string_view> tokens;
        boost::algorithm::split(tokens, view, boost::is_any_of(","));
        if (2 == tokens.size()) {
          double x, y;
          string_view_to_double(tokens[0], x);
          string_view_to_double(tokens[1], y);
          coordMap.try_emplace(std::stoi(key), RDGeom::Point2D{x, y});
        }
      }
    }
    unsigned int ConformerID = RDDepict::compute2DCoords(RDMol, &coordMap);
    RDKit::Conformer confmer = RDMol.getConformer(ConformerID);
    for(int i=0; i<confmer.getNumAtoms(); ++i)
    {
      //transfer coordinates from the RDKit conformer to equivalent atoms in the OBMol
      RDGeom::Point3D atompos = confmer.getAtomPos(i);
      OBAtom* obat = pmol->GetAtom(i+1);
      obat->SetVector(atompos.x, atompos.y, 0);
    }
  }
  catch(...)
  {
    obErrorLog.ThrowError(__FUNCTION__, "Op2D failed with an exception, probably in RDKit Code" , obError);
    return false;
  }
  pmol->SetDimension(2); //No longer without coordinates!
  return true;
}

}//namespace
