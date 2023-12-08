// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: graph.proto

#include "graph.pb.h"

#include <algorithm>
#include "google/protobuf/io/coded_stream.h"
#include "google/protobuf/extension_set.h"
#include "google/protobuf/wire_format_lite.h"
#include "google/protobuf/descriptor.h"
#include "google/protobuf/generated_message_reflection.h"
#include "google/protobuf/reflection_ops.h"
#include "google/protobuf/wire_format.h"
#include "google/protobuf/generated_message_tctable_impl.h"
// @@protoc_insertion_point(includes)

// Must be included last.
#include "google/protobuf/port_def.inc"
PROTOBUF_PRAGMA_INIT_SEG
namespace _pb = ::google::protobuf;
namespace _pbi = ::google::protobuf::internal;
namespace _fl = ::google::protobuf::internal::field_layout;
namespace opencv_tensorflow {
      template <typename>
PROTOBUF_CONSTEXPR NodeDef_AttrEntry_DoNotUse::NodeDef_AttrEntry_DoNotUse(::_pbi::ConstantInitialized) {}
struct NodeDef_AttrEntry_DoNotUseDefaultTypeInternal {
  PROTOBUF_CONSTEXPR NodeDef_AttrEntry_DoNotUseDefaultTypeInternal() : _instance(::_pbi::ConstantInitialized{}) {}
  ~NodeDef_AttrEntry_DoNotUseDefaultTypeInternal() {}
  union {
    NodeDef_AttrEntry_DoNotUse _instance;
  };
};

PROTOBUF_ATTRIBUTE_NO_DESTROY PROTOBUF_CONSTINIT
    PROTOBUF_ATTRIBUTE_INIT_PRIORITY1 NodeDef_AttrEntry_DoNotUseDefaultTypeInternal _NodeDef_AttrEntry_DoNotUse_default_instance_;

inline constexpr NodeDef::Impl_::Impl_(
    ::_pbi::ConstantInitialized) noexcept
      : input_{},
        attr_{},
        name_(
            &::google::protobuf::internal::fixed_address_empty_string,
            ::_pbi::ConstantInitialized()),
        op_(
            &::google::protobuf::internal::fixed_address_empty_string,
            ::_pbi::ConstantInitialized()),
        device_(
            &::google::protobuf::internal::fixed_address_empty_string,
            ::_pbi::ConstantInitialized()),
        _cached_size_{0} {}

template <typename>
PROTOBUF_CONSTEXPR NodeDef::NodeDef(::_pbi::ConstantInitialized)
    : _impl_(::_pbi::ConstantInitialized()) {}
struct NodeDefDefaultTypeInternal {
  PROTOBUF_CONSTEXPR NodeDefDefaultTypeInternal() : _instance(::_pbi::ConstantInitialized{}) {}
  ~NodeDefDefaultTypeInternal() {}
  union {
    NodeDef _instance;
  };
};

PROTOBUF_ATTRIBUTE_NO_DESTROY PROTOBUF_CONSTINIT
    PROTOBUF_ATTRIBUTE_INIT_PRIORITY1 NodeDefDefaultTypeInternal _NodeDef_default_instance_;

inline constexpr GraphDef::Impl_::Impl_(
    ::_pbi::ConstantInitialized) noexcept
      : _cached_size_{0},
        node_{},
        library_{nullptr},
        versions_{nullptr},
        version_{0} {}

template <typename>
PROTOBUF_CONSTEXPR GraphDef::GraphDef(::_pbi::ConstantInitialized)
    : _impl_(::_pbi::ConstantInitialized()) {}
struct GraphDefDefaultTypeInternal {
  PROTOBUF_CONSTEXPR GraphDefDefaultTypeInternal() : _instance(::_pbi::ConstantInitialized{}) {}
  ~GraphDefDefaultTypeInternal() {}
  union {
    GraphDef _instance;
  };
};

PROTOBUF_ATTRIBUTE_NO_DESTROY PROTOBUF_CONSTINIT
    PROTOBUF_ATTRIBUTE_INIT_PRIORITY1 GraphDefDefaultTypeInternal _GraphDef_default_instance_;
}  // namespace opencv_tensorflow
static ::_pb::Metadata file_level_metadata_graph_2eproto[3];
static constexpr const ::_pb::EnumDescriptor**
    file_level_enum_descriptors_graph_2eproto = nullptr;
static constexpr const ::_pb::ServiceDescriptor**
    file_level_service_descriptors_graph_2eproto = nullptr;
const ::uint32_t TableStruct_graph_2eproto::offsets[] PROTOBUF_SECTION_VARIABLE(
    protodesc_cold) = {
    PROTOBUF_FIELD_OFFSET(::opencv_tensorflow::GraphDef, _impl_._has_bits_),
    PROTOBUF_FIELD_OFFSET(::opencv_tensorflow::GraphDef, _internal_metadata_),
    ~0u,  // no _extensions_
    ~0u,  // no _oneof_case_
    ~0u,  // no _weak_field_map_
    ~0u,  // no _inlined_string_donated_
    ~0u,  // no _split_
    ~0u,  // no sizeof(Split)
    PROTOBUF_FIELD_OFFSET(::opencv_tensorflow::GraphDef, _impl_.node_),
    PROTOBUF_FIELD_OFFSET(::opencv_tensorflow::GraphDef, _impl_.versions_),
    PROTOBUF_FIELD_OFFSET(::opencv_tensorflow::GraphDef, _impl_.version_),
    PROTOBUF_FIELD_OFFSET(::opencv_tensorflow::GraphDef, _impl_.library_),
    ~0u,
    1,
    ~0u,
    0,
    PROTOBUF_FIELD_OFFSET(::opencv_tensorflow::NodeDef_AttrEntry_DoNotUse, _has_bits_),
    PROTOBUF_FIELD_OFFSET(::opencv_tensorflow::NodeDef_AttrEntry_DoNotUse, _internal_metadata_),
    ~0u,  // no _extensions_
    ~0u,  // no _oneof_case_
    ~0u,  // no _weak_field_map_
    ~0u,  // no _inlined_string_donated_
    ~0u,  // no _split_
    ~0u,  // no sizeof(Split)
    PROTOBUF_FIELD_OFFSET(::opencv_tensorflow::NodeDef_AttrEntry_DoNotUse, key_),
    PROTOBUF_FIELD_OFFSET(::opencv_tensorflow::NodeDef_AttrEntry_DoNotUse, value_),
    0,
    1,
    ~0u,  // no _has_bits_
    PROTOBUF_FIELD_OFFSET(::opencv_tensorflow::NodeDef, _internal_metadata_),
    ~0u,  // no _extensions_
    ~0u,  // no _oneof_case_
    ~0u,  // no _weak_field_map_
    ~0u,  // no _inlined_string_donated_
    ~0u,  // no _split_
    ~0u,  // no sizeof(Split)
    PROTOBUF_FIELD_OFFSET(::opencv_tensorflow::NodeDef, _impl_.name_),
    PROTOBUF_FIELD_OFFSET(::opencv_tensorflow::NodeDef, _impl_.op_),
    PROTOBUF_FIELD_OFFSET(::opencv_tensorflow::NodeDef, _impl_.input_),
    PROTOBUF_FIELD_OFFSET(::opencv_tensorflow::NodeDef, _impl_.device_),
    PROTOBUF_FIELD_OFFSET(::opencv_tensorflow::NodeDef, _impl_.attr_),
};

static const ::_pbi::MigrationSchema
    schemas[] PROTOBUF_SECTION_VARIABLE(protodesc_cold) = {
        {0, 12, -1, sizeof(::opencv_tensorflow::GraphDef)},
        {16, 26, -1, sizeof(::opencv_tensorflow::NodeDef_AttrEntry_DoNotUse)},
        {28, -1, -1, sizeof(::opencv_tensorflow::NodeDef)},
};

static const ::_pb::Message* const file_default_instances[] = {
    &::opencv_tensorflow::_GraphDef_default_instance_._instance,
    &::opencv_tensorflow::_NodeDef_AttrEntry_DoNotUse_default_instance_._instance,
    &::opencv_tensorflow::_NodeDef_default_instance_._instance,
};
const char descriptor_table_protodef_graph_2eproto[] PROTOBUF_SECTION_VARIABLE(protodesc_cold) = {
    "\n\013graph.proto\022\021opencv_tensorflow\032\020attr_v"
    "alue.proto\032\016function.proto\032\016versions.pro"
    "to\"\262\001\n\010GraphDef\022(\n\004node\030\001 \003(\0132\032.opencv_t"
    "ensorflow.NodeDef\022/\n\010versions\030\004 \001(\0132\035.op"
    "encv_tensorflow.VersionDef\022\023\n\007version\030\003 "
    "\001(\005B\002\030\001\0226\n\007library\030\002 \001(\0132%.opencv_tensor"
    "flow.FunctionDefLibrary\"\301\001\n\007NodeDef\022\014\n\004n"
    "ame\030\001 \001(\t\022\n\n\002op\030\002 \001(\t\022\r\n\005input\030\003 \003(\t\022\016\n\006"
    "device\030\004 \001(\t\0222\n\004attr\030\005 \003(\0132$.opencv_tens"
    "orflow.NodeDef.AttrEntry\032I\n\tAttrEntry\022\013\n"
    "\003key\030\001 \001(\t\022+\n\005value\030\002 \001(\0132\034.opencv_tenso"
    "rflow.AttrValue:\0028\001B,\n\030org.tensorflow.fr"
    "ameworkB\013GraphProtosP\001\370\001\001b\006proto3"
};
static const ::_pbi::DescriptorTable* const descriptor_table_graph_2eproto_deps[3] =
    {
        &::descriptor_table_attr_5fvalue_2eproto,
        &::descriptor_table_function_2eproto,
        &::descriptor_table_versions_2eproto,
};
static ::absl::once_flag descriptor_table_graph_2eproto_once;
const ::_pbi::DescriptorTable descriptor_table_graph_2eproto = {
    false,
    false,
    513,
    descriptor_table_protodef_graph_2eproto,
    "graph.proto",
    &descriptor_table_graph_2eproto_once,
    descriptor_table_graph_2eproto_deps,
    3,
    3,
    schemas,
    file_default_instances,
    TableStruct_graph_2eproto::offsets,
    file_level_metadata_graph_2eproto,
    file_level_enum_descriptors_graph_2eproto,
    file_level_service_descriptors_graph_2eproto,
};

// This function exists to be marked as weak.
// It can significantly speed up compilation by breaking up LLVM's SCC
// in the .pb.cc translation units. Large translation units see a
// reduction of more than 35% of walltime for optimized builds. Without
// the weak attribute all the messages in the file, including all the
// vtables and everything they use become part of the same SCC through
// a cycle like:
// GetMetadata -> descriptor table -> default instances ->
//   vtables -> GetMetadata
// By adding a weak function here we break the connection from the
// individual vtables back into the descriptor table.
PROTOBUF_ATTRIBUTE_WEAK const ::_pbi::DescriptorTable* descriptor_table_graph_2eproto_getter() {
  return &descriptor_table_graph_2eproto;
}
// Force running AddDescriptors() at dynamic initialization time.
PROTOBUF_ATTRIBUTE_INIT_PRIORITY2
static ::_pbi::AddDescriptorsRunner dynamic_init_dummy_graph_2eproto(&descriptor_table_graph_2eproto);
namespace opencv_tensorflow {
// ===================================================================

class GraphDef::_Internal {
 public:
  using HasBits = decltype(std::declval<GraphDef>()._impl_._has_bits_);
  static constexpr ::int32_t kHasBitsOffset =
    8 * PROTOBUF_FIELD_OFFSET(GraphDef, _impl_._has_bits_);
  static const ::opencv_tensorflow::VersionDef& versions(const GraphDef* msg);
  static void set_has_versions(HasBits* has_bits) {
    (*has_bits)[0] |= 2u;
  }
  static const ::opencv_tensorflow::FunctionDefLibrary& library(const GraphDef* msg);
  static void set_has_library(HasBits* has_bits) {
    (*has_bits)[0] |= 1u;
  }
};

const ::opencv_tensorflow::VersionDef& GraphDef::_Internal::versions(const GraphDef* msg) {
  return *msg->_impl_.versions_;
}
const ::opencv_tensorflow::FunctionDefLibrary& GraphDef::_Internal::library(const GraphDef* msg) {
  return *msg->_impl_.library_;
}
void GraphDef::clear_versions() {
  PROTOBUF_TSAN_WRITE(&_impl_._tsan_detect_race);
  if (_impl_.versions_ != nullptr) _impl_.versions_->Clear();
  _impl_._has_bits_[0] &= ~0x00000002u;
}
void GraphDef::clear_library() {
  PROTOBUF_TSAN_WRITE(&_impl_._tsan_detect_race);
  if (_impl_.library_ != nullptr) _impl_.library_->Clear();
  _impl_._has_bits_[0] &= ~0x00000001u;
}
GraphDef::GraphDef(::google::protobuf::Arena* arena)
    : ::google::protobuf::Message(arena) {
  SharedCtor(arena);
  // @@protoc_insertion_point(arena_constructor:opencv_tensorflow.GraphDef)
}
inline PROTOBUF_NDEBUG_INLINE GraphDef::Impl_::Impl_(
    ::google::protobuf::internal::InternalVisibility visibility, ::google::protobuf::Arena* arena,
    const Impl_& from)
      : _has_bits_{from._has_bits_},
        _cached_size_{0},
        node_{visibility, arena, from.node_} {}

GraphDef::GraphDef(
    ::google::protobuf::Arena* arena,
    const GraphDef& from)
    : ::google::protobuf::Message(arena) {
  GraphDef* const _this = this;
  (void)_this;
  _internal_metadata_.MergeFrom<::google::protobuf::UnknownFieldSet>(
      from._internal_metadata_);
  new (&_impl_) Impl_(internal_visibility(), arena, from._impl_);
  ::uint32_t cached_has_bits = _impl_._has_bits_[0];
  _impl_.library_ = (cached_has_bits & 0x00000001u)
                ? CreateMaybeMessage<::opencv_tensorflow::FunctionDefLibrary>(arena, *from._impl_.library_)
                : nullptr;
  _impl_.versions_ = (cached_has_bits & 0x00000002u)
                ? CreateMaybeMessage<::opencv_tensorflow::VersionDef>(arena, *from._impl_.versions_)
                : nullptr;
  _impl_.version_ = from._impl_.version_;

  // @@protoc_insertion_point(copy_constructor:opencv_tensorflow.GraphDef)
}
inline PROTOBUF_NDEBUG_INLINE GraphDef::Impl_::Impl_(
    ::google::protobuf::internal::InternalVisibility visibility,
    ::google::protobuf::Arena* arena)
      : _cached_size_{0},
        node_{visibility, arena} {}

inline void GraphDef::SharedCtor(::_pb::Arena* arena) {
  new (&_impl_) Impl_(internal_visibility(), arena);
  ::memset(reinterpret_cast<char *>(&_impl_) +
               offsetof(Impl_, library_),
           0,
           offsetof(Impl_, version_) -
               offsetof(Impl_, library_) +
               sizeof(Impl_::version_));
}
GraphDef::~GraphDef() {
  // @@protoc_insertion_point(destructor:opencv_tensorflow.GraphDef)
  _internal_metadata_.Delete<::google::protobuf::UnknownFieldSet>();
  SharedDtor();
}
inline void GraphDef::SharedDtor() {
  ABSL_DCHECK(GetArena() == nullptr);
  delete _impl_.library_;
  delete _impl_.versions_;
  _impl_.~Impl_();
}

PROTOBUF_NOINLINE void GraphDef::Clear() {
// @@protoc_insertion_point(message_clear_start:opencv_tensorflow.GraphDef)
  PROTOBUF_TSAN_WRITE(&_impl_._tsan_detect_race);
  ::uint32_t cached_has_bits = 0;
  // Prevent compiler warnings about cached_has_bits being unused
  (void) cached_has_bits;

  _impl_.node_.Clear();
  cached_has_bits = _impl_._has_bits_[0];
  if (cached_has_bits & 0x00000003u) {
    if (cached_has_bits & 0x00000001u) {
      ABSL_DCHECK(_impl_.library_ != nullptr);
      _impl_.library_->Clear();
    }
    if (cached_has_bits & 0x00000002u) {
      ABSL_DCHECK(_impl_.versions_ != nullptr);
      _impl_.versions_->Clear();
    }
  }
  _impl_.version_ = 0;
  _impl_._has_bits_.Clear();
  _internal_metadata_.Clear<::google::protobuf::UnknownFieldSet>();
}

const char* GraphDef::_InternalParse(
    const char* ptr, ::_pbi::ParseContext* ctx) {
  ptr = ::_pbi::TcParser::ParseLoop(this, ptr, ctx, &_table_.header);
  return ptr;
}


PROTOBUF_CONSTINIT PROTOBUF_ATTRIBUTE_INIT_PRIORITY1
const ::_pbi::TcParseTable<2, 4, 3, 0, 2> GraphDef::_table_ = {
  {
    PROTOBUF_FIELD_OFFSET(GraphDef, _impl_._has_bits_),
    0, // no _extensions_
    4, 24,  // max_field_number, fast_idx_mask
    offsetof(decltype(_table_), field_lookup_table),
    4294967280,  // skipmap
    offsetof(decltype(_table_), field_entries),
    4,  // num_field_entries
    3,  // num_aux_entries
    offsetof(decltype(_table_), aux_entries),
    &_GraphDef_default_instance_._instance,
    ::_pbi::TcParser::GenericFallback,  // fallback
  }, {{
    // .opencv_tensorflow.VersionDef versions = 4;
    {::_pbi::TcParser::FastMtS1,
     {34, 1, 2, PROTOBUF_FIELD_OFFSET(GraphDef, _impl_.versions_)}},
    // repeated .opencv_tensorflow.NodeDef node = 1;
    {::_pbi::TcParser::FastMtR1,
     {10, 63, 0, PROTOBUF_FIELD_OFFSET(GraphDef, _impl_.node_)}},
    // .opencv_tensorflow.FunctionDefLibrary library = 2;
    {::_pbi::TcParser::FastMtS1,
     {18, 0, 1, PROTOBUF_FIELD_OFFSET(GraphDef, _impl_.library_)}},
    // int32 version = 3 [deprecated = true];
    {::_pbi::TcParser::SingularVarintNoZag1<::uint32_t, offsetof(GraphDef, _impl_.version_), 63>(),
     {24, 63, 0, PROTOBUF_FIELD_OFFSET(GraphDef, _impl_.version_)}},
  }}, {{
    65535, 65535
  }}, {{
    // repeated .opencv_tensorflow.NodeDef node = 1;
    {PROTOBUF_FIELD_OFFSET(GraphDef, _impl_.node_), -1, 0,
    (0 | ::_fl::kFcRepeated | ::_fl::kMessage | ::_fl::kTvTable)},
    // .opencv_tensorflow.FunctionDefLibrary library = 2;
    {PROTOBUF_FIELD_OFFSET(GraphDef, _impl_.library_), _Internal::kHasBitsOffset + 0, 1,
    (0 | ::_fl::kFcOptional | ::_fl::kMessage | ::_fl::kTvTable)},
    // int32 version = 3 [deprecated = true];
    {PROTOBUF_FIELD_OFFSET(GraphDef, _impl_.version_), -1, 0,
    (0 | ::_fl::kFcSingular | ::_fl::kInt32)},
    // .opencv_tensorflow.VersionDef versions = 4;
    {PROTOBUF_FIELD_OFFSET(GraphDef, _impl_.versions_), _Internal::kHasBitsOffset + 1, 2,
    (0 | ::_fl::kFcOptional | ::_fl::kMessage | ::_fl::kTvTable)},
  }}, {{
    {::_pbi::TcParser::GetTable<::opencv_tensorflow::NodeDef>()},
    {::_pbi::TcParser::GetTable<::opencv_tensorflow::FunctionDefLibrary>()},
    {::_pbi::TcParser::GetTable<::opencv_tensorflow::VersionDef>()},
  }}, {{
  }},
};

::uint8_t* GraphDef::_InternalSerialize(
    ::uint8_t* target,
    ::google::protobuf::io::EpsCopyOutputStream* stream) const {
  // @@protoc_insertion_point(serialize_to_array_start:opencv_tensorflow.GraphDef)
  ::uint32_t cached_has_bits = 0;
  (void)cached_has_bits;

  // repeated .opencv_tensorflow.NodeDef node = 1;
  for (unsigned i = 0,
      n = static_cast<unsigned>(this->_internal_node_size()); i < n; i++) {
    const auto& repfield = this->_internal_node().Get(i);
    target = ::google::protobuf::internal::WireFormatLite::
        InternalWriteMessage(1, repfield, repfield.GetCachedSize(), target, stream);
  }

  cached_has_bits = _impl_._has_bits_[0];
  // .opencv_tensorflow.FunctionDefLibrary library = 2;
  if (cached_has_bits & 0x00000001u) {
    target = ::google::protobuf::internal::WireFormatLite::InternalWriteMessage(
        2, _Internal::library(this),
        _Internal::library(this).GetCachedSize(), target, stream);
  }

  // int32 version = 3 [deprecated = true];
  if (this->_internal_version() != 0) {
    target = ::google::protobuf::internal::WireFormatLite::
        WriteInt32ToArrayWithField<3>(
            stream, this->_internal_version(), target);
  }

  // .opencv_tensorflow.VersionDef versions = 4;
  if (cached_has_bits & 0x00000002u) {
    target = ::google::protobuf::internal::WireFormatLite::InternalWriteMessage(
        4, _Internal::versions(this),
        _Internal::versions(this).GetCachedSize(), target, stream);
  }

  if (PROTOBUF_PREDICT_FALSE(_internal_metadata_.have_unknown_fields())) {
    target =
        ::_pbi::WireFormat::InternalSerializeUnknownFieldsToArray(
            _internal_metadata_.unknown_fields<::google::protobuf::UnknownFieldSet>(::google::protobuf::UnknownFieldSet::default_instance), target, stream);
  }
  // @@protoc_insertion_point(serialize_to_array_end:opencv_tensorflow.GraphDef)
  return target;
}

::size_t GraphDef::ByteSizeLong() const {
// @@protoc_insertion_point(message_byte_size_start:opencv_tensorflow.GraphDef)
  ::size_t total_size = 0;

  ::uint32_t cached_has_bits = 0;
  // Prevent compiler warnings about cached_has_bits being unused
  (void) cached_has_bits;

  // repeated .opencv_tensorflow.NodeDef node = 1;
  total_size += 1UL * this->_internal_node_size();
  for (const auto& msg : this->_internal_node()) {
    total_size +=
      ::google::protobuf::internal::WireFormatLite::MessageSize(msg);
  }
  cached_has_bits = _impl_._has_bits_[0];
  if (cached_has_bits & 0x00000003u) {
    // .opencv_tensorflow.FunctionDefLibrary library = 2;
    if (cached_has_bits & 0x00000001u) {
      total_size +=
          1 + ::google::protobuf::internal::WireFormatLite::MessageSize(*_impl_.library_);
    }

    // .opencv_tensorflow.VersionDef versions = 4;
    if (cached_has_bits & 0x00000002u) {
      total_size +=
          1 + ::google::protobuf::internal::WireFormatLite::MessageSize(*_impl_.versions_);
    }

  }
  // int32 version = 3 [deprecated = true];
  if (this->_internal_version() != 0) {
    total_size += ::_pbi::WireFormatLite::Int32SizePlusOne(
        this->_internal_version());
  }

  return MaybeComputeUnknownFieldsSize(total_size, &_impl_._cached_size_);
}

const ::google::protobuf::Message::ClassData GraphDef::_class_data_ = {
    GraphDef::MergeImpl,
    nullptr,  // OnDemandRegisterArenaDtor
};
const ::google::protobuf::Message::ClassData* GraphDef::GetClassData() const {
  return &_class_data_;
}

void GraphDef::MergeImpl(::google::protobuf::Message& to_msg, const ::google::protobuf::Message& from_msg) {
  auto* const _this = static_cast<GraphDef*>(&to_msg);
  auto& from = static_cast<const GraphDef&>(from_msg);
  // @@protoc_insertion_point(class_specific_merge_from_start:opencv_tensorflow.GraphDef)
  ABSL_DCHECK_NE(&from, _this);
  ::uint32_t cached_has_bits = 0;
  (void) cached_has_bits;

  _this->_internal_mutable_node()->MergeFrom(
      from._internal_node());
  cached_has_bits = from._impl_._has_bits_[0];
  if (cached_has_bits & 0x00000003u) {
    if (cached_has_bits & 0x00000001u) {
      _this->_internal_mutable_library()->::opencv_tensorflow::FunctionDefLibrary::MergeFrom(
          from._internal_library());
    }
    if (cached_has_bits & 0x00000002u) {
      _this->_internal_mutable_versions()->::opencv_tensorflow::VersionDef::MergeFrom(
          from._internal_versions());
    }
  }
  if (from._internal_version() != 0) {
    _this->_internal_set_version(from._internal_version());
  }
  _this->_internal_metadata_.MergeFrom<::google::protobuf::UnknownFieldSet>(from._internal_metadata_);
}

void GraphDef::CopyFrom(const GraphDef& from) {
// @@protoc_insertion_point(class_specific_copy_from_start:opencv_tensorflow.GraphDef)
  if (&from == this) return;
  Clear();
  MergeFrom(from);
}

PROTOBUF_NOINLINE bool GraphDef::IsInitialized() const {
  return true;
}

::_pbi::CachedSize* GraphDef::AccessCachedSize() const {
  return &_impl_._cached_size_;
}
void GraphDef::InternalSwap(GraphDef* PROTOBUF_RESTRICT other) {
  using std::swap;
  _internal_metadata_.InternalSwap(&other->_internal_metadata_);
  swap(_impl_._has_bits_[0], other->_impl_._has_bits_[0]);
  _impl_.node_.InternalSwap(&other->_impl_.node_);
  ::google::protobuf::internal::memswap<
      PROTOBUF_FIELD_OFFSET(GraphDef, _impl_.version_)
      + sizeof(GraphDef::_impl_.version_)
      - PROTOBUF_FIELD_OFFSET(GraphDef, _impl_.library_)>(
          reinterpret_cast<char*>(&_impl_.library_),
          reinterpret_cast<char*>(&other->_impl_.library_));
}

::google::protobuf::Metadata GraphDef::GetMetadata() const {
  return ::_pbi::AssignDescriptors(
      &descriptor_table_graph_2eproto_getter, &descriptor_table_graph_2eproto_once,
      file_level_metadata_graph_2eproto[0]);
}
// ===================================================================

NodeDef_AttrEntry_DoNotUse::NodeDef_AttrEntry_DoNotUse() {}
NodeDef_AttrEntry_DoNotUse::NodeDef_AttrEntry_DoNotUse(::google::protobuf::Arena* arena)
    : SuperType(arena) {}
::google::protobuf::Metadata NodeDef_AttrEntry_DoNotUse::GetMetadata() const {
  return ::_pbi::AssignDescriptors(
      &descriptor_table_graph_2eproto_getter, &descriptor_table_graph_2eproto_once,
      file_level_metadata_graph_2eproto[1]);
}
// ===================================================================

class NodeDef::_Internal {
 public:
};

void NodeDef::clear_attr() {
  PROTOBUF_TSAN_WRITE(&_impl_._tsan_detect_race);
  _impl_.attr_.Clear();
}
NodeDef::NodeDef(::google::protobuf::Arena* arena)
    : ::google::protobuf::Message(arena) {
  SharedCtor(arena);
  // @@protoc_insertion_point(arena_constructor:opencv_tensorflow.NodeDef)
}
inline PROTOBUF_NDEBUG_INLINE NodeDef::Impl_::Impl_(
    ::google::protobuf::internal::InternalVisibility visibility, ::google::protobuf::Arena* arena,
    const Impl_& from)
      : input_{visibility, arena, from.input_},
        attr_{visibility, arena, from.attr_},
        name_(arena, from.name_),
        op_(arena, from.op_),
        device_(arena, from.device_),
        _cached_size_{0} {}

NodeDef::NodeDef(
    ::google::protobuf::Arena* arena,
    const NodeDef& from)
    : ::google::protobuf::Message(arena) {
  NodeDef* const _this = this;
  (void)_this;
  _internal_metadata_.MergeFrom<::google::protobuf::UnknownFieldSet>(
      from._internal_metadata_);
  new (&_impl_) Impl_(internal_visibility(), arena, from._impl_);

  // @@protoc_insertion_point(copy_constructor:opencv_tensorflow.NodeDef)
}
inline PROTOBUF_NDEBUG_INLINE NodeDef::Impl_::Impl_(
    ::google::protobuf::internal::InternalVisibility visibility,
    ::google::protobuf::Arena* arena)
      : input_{visibility, arena},
        attr_{visibility, arena},
        name_(arena),
        op_(arena),
        device_(arena),
        _cached_size_{0} {}

inline void NodeDef::SharedCtor(::_pb::Arena* arena) {
  new (&_impl_) Impl_(internal_visibility(), arena);
}
NodeDef::~NodeDef() {
  // @@protoc_insertion_point(destructor:opencv_tensorflow.NodeDef)
  _internal_metadata_.Delete<::google::protobuf::UnknownFieldSet>();
  SharedDtor();
}
inline void NodeDef::SharedDtor() {
  ABSL_DCHECK(GetArena() == nullptr);
  _impl_.name_.Destroy();
  _impl_.op_.Destroy();
  _impl_.device_.Destroy();
  _impl_.~Impl_();
}

PROTOBUF_NOINLINE void NodeDef::Clear() {
// @@protoc_insertion_point(message_clear_start:opencv_tensorflow.NodeDef)
  PROTOBUF_TSAN_WRITE(&_impl_._tsan_detect_race);
  ::uint32_t cached_has_bits = 0;
  // Prevent compiler warnings about cached_has_bits being unused
  (void) cached_has_bits;

  _impl_.input_.Clear();
  _impl_.attr_.Clear();
  _impl_.name_.ClearToEmpty();
  _impl_.op_.ClearToEmpty();
  _impl_.device_.ClearToEmpty();
  _internal_metadata_.Clear<::google::protobuf::UnknownFieldSet>();
}

const char* NodeDef::_InternalParse(
    const char* ptr, ::_pbi::ParseContext* ctx) {
  ptr = ::_pbi::TcParser::ParseLoop(this, ptr, ctx, &_table_.header);
  return ptr;
}


PROTOBUF_CONSTINIT PROTOBUF_ATTRIBUTE_INIT_PRIORITY1
const ::_pbi::TcParseTable<2, 5, 2, 55, 2> NodeDef::_table_ = {
  {
    0,  // no _has_bits_
    0, // no _extensions_
    5, 24,  // max_field_number, fast_idx_mask
    offsetof(decltype(_table_), field_lookup_table),
    4294967264,  // skipmap
    offsetof(decltype(_table_), field_entries),
    5,  // num_field_entries
    2,  // num_aux_entries
    offsetof(decltype(_table_), aux_entries),
    &_NodeDef_default_instance_._instance,
    ::_pbi::TcParser::GenericFallback,  // fallback
  }, {{
    // string device = 4;
    {::_pbi::TcParser::FastUS1,
     {34, 63, 0, PROTOBUF_FIELD_OFFSET(NodeDef, _impl_.device_)}},
    // string name = 1;
    {::_pbi::TcParser::FastUS1,
     {10, 63, 0, PROTOBUF_FIELD_OFFSET(NodeDef, _impl_.name_)}},
    // string op = 2;
    {::_pbi::TcParser::FastUS1,
     {18, 63, 0, PROTOBUF_FIELD_OFFSET(NodeDef, _impl_.op_)}},
    // repeated string input = 3;
    {::_pbi::TcParser::FastUR1,
     {26, 63, 0, PROTOBUF_FIELD_OFFSET(NodeDef, _impl_.input_)}},
  }}, {{
    65535, 65535
  }}, {{
    // string name = 1;
    {PROTOBUF_FIELD_OFFSET(NodeDef, _impl_.name_), 0, 0,
    (0 | ::_fl::kFcSingular | ::_fl::kUtf8String | ::_fl::kRepAString)},
    // string op = 2;
    {PROTOBUF_FIELD_OFFSET(NodeDef, _impl_.op_), 0, 0,
    (0 | ::_fl::kFcSingular | ::_fl::kUtf8String | ::_fl::kRepAString)},
    // repeated string input = 3;
    {PROTOBUF_FIELD_OFFSET(NodeDef, _impl_.input_), 0, 0,
    (0 | ::_fl::kFcRepeated | ::_fl::kUtf8String | ::_fl::kRepSString)},
    // string device = 4;
    {PROTOBUF_FIELD_OFFSET(NodeDef, _impl_.device_), 0, 0,
    (0 | ::_fl::kFcSingular | ::_fl::kUtf8String | ::_fl::kRepAString)},
    // map<string, .opencv_tensorflow.AttrValue> attr = 5;
    {PROTOBUF_FIELD_OFFSET(NodeDef, _impl_.attr_), 0, 0,
    (0 | ::_fl::kFcRepeated | ::_fl::kMap)},
  }}, {{
    {::_pbi::TcParser::GetMapAuxInfo<
        decltype(NodeDef()._impl_.attr_)>(
        1, 0, 0, 9,
        11)},
    {::_pbi::TcParser::CreateInArenaStorageCb<::opencv_tensorflow::AttrValue>},
  }}, {{
    "\31\4\2\5\6\4\0\0"
    "opencv_tensorflow.NodeDef"
    "name"
    "op"
    "input"
    "device"
    "attr"
  }},
};

::uint8_t* NodeDef::_InternalSerialize(
    ::uint8_t* target,
    ::google::protobuf::io::EpsCopyOutputStream* stream) const {
  // @@protoc_insertion_point(serialize_to_array_start:opencv_tensorflow.NodeDef)
  ::uint32_t cached_has_bits = 0;
  (void)cached_has_bits;

  // string name = 1;
  if (!this->_internal_name().empty()) {
    const std::string& _s = this->_internal_name();
    ::google::protobuf::internal::WireFormatLite::VerifyUtf8String(
        _s.data(), static_cast<int>(_s.length()), ::google::protobuf::internal::WireFormatLite::SERIALIZE, "opencv_tensorflow.NodeDef.name");
    target = stream->WriteStringMaybeAliased(1, _s, target);
  }

  // string op = 2;
  if (!this->_internal_op().empty()) {
    const std::string& _s = this->_internal_op();
    ::google::protobuf::internal::WireFormatLite::VerifyUtf8String(
        _s.data(), static_cast<int>(_s.length()), ::google::protobuf::internal::WireFormatLite::SERIALIZE, "opencv_tensorflow.NodeDef.op");
    target = stream->WriteStringMaybeAliased(2, _s, target);
  }

  // repeated string input = 3;
  for (int i = 0, n = this->_internal_input_size(); i < n; ++i) {
    const auto& s = this->_internal_input().Get(i);
    ::google::protobuf::internal::WireFormatLite::VerifyUtf8String(
        s.data(), static_cast<int>(s.length()), ::google::protobuf::internal::WireFormatLite::SERIALIZE, "opencv_tensorflow.NodeDef.input");
    target = stream->WriteString(3, s, target);
  }

  // string device = 4;
  if (!this->_internal_device().empty()) {
    const std::string& _s = this->_internal_device();
    ::google::protobuf::internal::WireFormatLite::VerifyUtf8String(
        _s.data(), static_cast<int>(_s.length()), ::google::protobuf::internal::WireFormatLite::SERIALIZE, "opencv_tensorflow.NodeDef.device");
    target = stream->WriteStringMaybeAliased(4, _s, target);
  }

  // map<string, .opencv_tensorflow.AttrValue> attr = 5;
  if (!_internal_attr().empty()) {
    using MapType = ::google::protobuf::Map<std::string, ::opencv_tensorflow::AttrValue>;
    using WireHelper = _pbi::MapEntryFuncs<std::string, ::opencv_tensorflow::AttrValue,
                                   _pbi::WireFormatLite::TYPE_STRING,
                                   _pbi::WireFormatLite::TYPE_MESSAGE>;
    const auto& field = _internal_attr();

    if (stream->IsSerializationDeterministic() && field.size() > 1) {
      for (const auto& entry : ::google::protobuf::internal::MapSorterPtr<MapType>(field)) {
        target = WireHelper::InternalSerialize(
            5, entry.first, entry.second, target, stream);
        ::google::protobuf::internal::WireFormatLite::VerifyUtf8String(
            entry.first.data(), static_cast<int>(entry.first.length()),
 ::google::protobuf::internal::WireFormatLite::SERIALIZE, "opencv_tensorflow.NodeDef.attr");
      }
    } else {
      for (const auto& entry : field) {
        target = WireHelper::InternalSerialize(
            5, entry.first, entry.second, target, stream);
        ::google::protobuf::internal::WireFormatLite::VerifyUtf8String(
            entry.first.data(), static_cast<int>(entry.first.length()),
 ::google::protobuf::internal::WireFormatLite::SERIALIZE, "opencv_tensorflow.NodeDef.attr");
      }
    }
  }

  if (PROTOBUF_PREDICT_FALSE(_internal_metadata_.have_unknown_fields())) {
    target =
        ::_pbi::WireFormat::InternalSerializeUnknownFieldsToArray(
            _internal_metadata_.unknown_fields<::google::protobuf::UnknownFieldSet>(::google::protobuf::UnknownFieldSet::default_instance), target, stream);
  }
  // @@protoc_insertion_point(serialize_to_array_end:opencv_tensorflow.NodeDef)
  return target;
}

::size_t NodeDef::ByteSizeLong() const {
// @@protoc_insertion_point(message_byte_size_start:opencv_tensorflow.NodeDef)
  ::size_t total_size = 0;

  ::uint32_t cached_has_bits = 0;
  // Prevent compiler warnings about cached_has_bits being unused
  (void) cached_has_bits;

  // repeated string input = 3;
  total_size += 1 * ::google::protobuf::internal::FromIntSize(_internal_input().size());
  for (int i = 0, n = _internal_input().size(); i < n; ++i) {
    total_size += ::google::protobuf::internal::WireFormatLite::StringSize(
        _internal_input().Get(i));
  }
  // map<string, .opencv_tensorflow.AttrValue> attr = 5;
  total_size += 1 * ::google::protobuf::internal::FromIntSize(_internal_attr_size());
  for (const auto& entry : _internal_attr()) {
    total_size += _pbi::MapEntryFuncs<std::string, ::opencv_tensorflow::AttrValue,
                                   _pbi::WireFormatLite::TYPE_STRING,
                                   _pbi::WireFormatLite::TYPE_MESSAGE>::ByteSizeLong(entry.first, entry.second);
  }
  // string name = 1;
  if (!this->_internal_name().empty()) {
    total_size += 1 + ::google::protobuf::internal::WireFormatLite::StringSize(
                                    this->_internal_name());
  }

  // string op = 2;
  if (!this->_internal_op().empty()) {
    total_size += 1 + ::google::protobuf::internal::WireFormatLite::StringSize(
                                    this->_internal_op());
  }

  // string device = 4;
  if (!this->_internal_device().empty()) {
    total_size += 1 + ::google::protobuf::internal::WireFormatLite::StringSize(
                                    this->_internal_device());
  }

  return MaybeComputeUnknownFieldsSize(total_size, &_impl_._cached_size_);
}

const ::google::protobuf::Message::ClassData NodeDef::_class_data_ = {
    NodeDef::MergeImpl,
    nullptr,  // OnDemandRegisterArenaDtor
};
const ::google::protobuf::Message::ClassData* NodeDef::GetClassData() const {
  return &_class_data_;
}

void NodeDef::MergeImpl(::google::protobuf::Message& to_msg, const ::google::protobuf::Message& from_msg) {
  auto* const _this = static_cast<NodeDef*>(&to_msg);
  auto& from = static_cast<const NodeDef&>(from_msg);
  // @@protoc_insertion_point(class_specific_merge_from_start:opencv_tensorflow.NodeDef)
  ABSL_DCHECK_NE(&from, _this);
  ::uint32_t cached_has_bits = 0;
  (void) cached_has_bits;

  _this->_internal_mutable_input()->MergeFrom(from._internal_input());
  _this->_impl_.attr_.MergeFrom(from._impl_.attr_);
  if (!from._internal_name().empty()) {
    _this->_internal_set_name(from._internal_name());
  }
  if (!from._internal_op().empty()) {
    _this->_internal_set_op(from._internal_op());
  }
  if (!from._internal_device().empty()) {
    _this->_internal_set_device(from._internal_device());
  }
  _this->_internal_metadata_.MergeFrom<::google::protobuf::UnknownFieldSet>(from._internal_metadata_);
}

void NodeDef::CopyFrom(const NodeDef& from) {
// @@protoc_insertion_point(class_specific_copy_from_start:opencv_tensorflow.NodeDef)
  if (&from == this) return;
  Clear();
  MergeFrom(from);
}

PROTOBUF_NOINLINE bool NodeDef::IsInitialized() const {
  return true;
}

::_pbi::CachedSize* NodeDef::AccessCachedSize() const {
  return &_impl_._cached_size_;
}
void NodeDef::InternalSwap(NodeDef* PROTOBUF_RESTRICT other) {
  using std::swap;
  auto* arena = GetArena();
  ABSL_DCHECK_EQ(arena, other->GetArena());
  _internal_metadata_.InternalSwap(&other->_internal_metadata_);
  _impl_.input_.InternalSwap(&other->_impl_.input_);
  _impl_.attr_.InternalSwap(&other->_impl_.attr_);
  ::_pbi::ArenaStringPtr::InternalSwap(&_impl_.name_, &other->_impl_.name_, arena);
  ::_pbi::ArenaStringPtr::InternalSwap(&_impl_.op_, &other->_impl_.op_, arena);
  ::_pbi::ArenaStringPtr::InternalSwap(&_impl_.device_, &other->_impl_.device_, arena);
}

::google::protobuf::Metadata NodeDef::GetMetadata() const {
  return ::_pbi::AssignDescriptors(
      &descriptor_table_graph_2eproto_getter, &descriptor_table_graph_2eproto_once,
      file_level_metadata_graph_2eproto[2]);
}
// @@protoc_insertion_point(namespace_scope)
}  // namespace opencv_tensorflow
namespace google {
namespace protobuf {
}  // namespace protobuf
}  // namespace google
// @@protoc_insertion_point(global_scope)
#include "google/protobuf/port_undef.inc"
