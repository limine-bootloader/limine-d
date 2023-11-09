module limine;

template BaseRevision(const char[] N) {
    const char[] BaseRevision = "__gshared ulong[3] limine_base_revision = [ 0xf9562b2d5c95a6c8, 0x6a7b384944536bdc, " ~ N ~ "];";
}

template BaseRevisionSupported() {
    const char[] BaseRevisionSupported = "(limine_base_revision[2] == 0)";
}

template CommonMagic() {
    const char[] CommonMagic = "\"0xc7b1dd30df4c8b88, 0x0a82e883a194f07b\"";
}

struct UUID {
    uint a;
    ushort b;
    ushort c;
    ubyte[8] d;
}

immutable uint mediaTypeGeneric = 0;
immutable uint mediaTypeOptical = 1;
immutable uint mediaTypeTFTP = 2;

struct File {
    ulong revision;
    void* address;
    ulong size;
    char* path;
    char* cmdline;
    uint mediaType;
    uint unused;
    uint tftpIP;
    uint tftpPort;
    uint partitionIndex;
    uint mbrDiskID;
    UUID gptDiskUUID;
    UUID gptPartUUID;
    UUID partUUID;
}

// Boot info

template BootloaderInfoRequestID() {
    const char[] BootloaderInfoRequestID = "[ " ~ mixin(CommonMagic!()) ~ ", 0xf55038d8e2a1202f, 0x279426fcf5f59740 ]";
}

struct BootloaderInfoResponse {
    ulong revision;
    char* name;
    char* version_;
}

struct BootloaderInfoRequest {
    ulong[4] id;
    ulong revision;
    BootloaderInfoResponse* response;
}

// Stack size

template StackSizeRequestID() {
    const char[] StackSizeRequestID = "[ " ~ mixin(CommonMagic!()) ~ ", 0x224ef0460a8e8926, 0xe1cb0fc25f46ea3d ]";
}

struct StackSizeResponse {
    ulong revision;
}

struct StackSizeRequest {
    ulong[4] id;
    ulong revision;
    StackSizeResponse* response;
    ulong stackSize;
}

// HHDM

template HHDMRequestID() {
    const char[] HHDMRequestID = "[ " ~ mixin(CommonMagic!()) ~ ", 0x48dcf1cb8ad2b852, 0x63984e959a98244b ]";
}

struct HHDMResponse {
    ulong revision;
    ulong offset;
}

struct HHDMRequest {
    ulong[4] id;
    ulong revision;
    HHDMResponse* response;
}

// Framebuffer

template FramebufferRequestID() {
    const char[] FramebufferRequestID = "[ " ~ mixin(CommonMagic!()) ~ ", 0x9d5827dcd881dd75, 0xa3148604f6fab11b ]";
}

struct VideoMode {
    ulong pitch;
    ulong width;
    ulong height;
    ushort bpp;
    ubyte memoryModel;
    ubyte redMaskSize;
    ubyte redMaskShift;
    ubyte greenMaskSize;
    ubyte greenMaskShift;
    ubyte blueMaskSize;
    ubyte blueMaskShift;
}

struct Framebuffer {
    void* address;
    ulong width;
    ulong height;
    ulong pitch;
    ushort bpp;
    ubyte memoryModel;
    ubyte redMaskSize;
    ubyte redMaskShift;
    ubyte greenMaskSize;
    ubyte greenMaskShift;
    ubyte blueMaskSize;
    ubyte blueMaskShift;
    ubyte[7] unused;
    ulong edidSize;
    void* edid;
    /* Response revision 1 */
    ulong modeCount;
    VideoMode** modes;
}

struct FramebufferResponse {
    ulong revision;
    ulong framebufferCount;
    Framebuffer** framebuffers;
}

struct FramebufferRequest {
    ulong[4] id;
    ulong revision;
    FramebufferResponse* response;
}

// Paging mode

template PagingModeRequestID() {
    const char[] PagingModeRequestID = "[ " ~ mixin(CommonMagic!()) ~ ", 0x95c1a0edab0944cb, 0xa4e5cb3842f7488a ]";
}

version (X86_64) {
    immutable ulong pagingMode4Level = 0;
    immutable ulong pagingMode5Level = 1;
    immutable ulong pagingModeMax = pagingMode5Level;
    immutable ulong pagingModeDefault = pagingMode4Level;
} else version (AArch64) {
    immutable ulong pagingMode4Level = 0;
    immutable ulong pagingMode5Level = 1;
    immutable ulong pagingModeMax = pagingMode5Level;
    immutable ulong pagingModeDefault = pagingMode4Level;
} else version (RISCV64) {
    immutable ulong pagingModeSv39 = 0;
    immutable ulong pagingModeSv48 = 1;
    immutable ulong pagingModeSv57 = 2;
    immutable ulong pagingModeMax = pagingModeSv57;
    immutable ulong pagingModeDefault = pagingModeSv48;
}

struct PagingModeResponse {
    ulong revision;
    ulong mode;
    ulong flags;
}

struct PagingModeRequest {
    ulong[4] id;
    ulong revision;
    PagingModeResponse* response;
    ulong mode;
    ulong flags;
}

// SMP

template SMPRequestID() {
    const char[] SMPRequestID = "[ " ~ mixin(CommonMagic!()) ~ ", 0x95a67b819a1b857e, 0xa0b61b723b6a73e0 ]";
}

version (X86_64) {
    immutable uint smpX2APIC = (1 << 0);

    struct SMPInfo {
        uint processorID;
        uint lapicID;
        ulong reserved;
        void *gotoAddress;
        ulong extraArgument;
    }

    struct SMPResponse {
        ulong revision;
        uint flags;
        uint bspLAPICID;
        ulong cpuCount;
        SMPInfo** cpus;
    }
} else version (AArch64) {
    struct SMPInfo {
        uint processorID;
        uint gicIfaceNo;
        ulong mpidr;
        ulong reserved;
        void *gotoAddress;
        ulong extraArgument;
    }

    struct SMPResponse {
        ulong revision;
        ulong flags;
        ulong bspMPIDR;
        ulong cpuCount;
        SMPInfo** cpus;
    }
} else version (RISCV64) {
    struct SMPInfo {
        ulong processorID;
        ulong hartID;
        ulong reserved;
        void *gotoAddress;
        ulong extraArgument;
    }

    struct SMPResponse {
        ulong revision;
        ulong flags;
        ulong bspHARTID;
        ulong cpuCount;
        SMPInfo** cpus;
    }
}

struct SMPRequest {
    ulong[4] id;
    ulong revision;
    SMPResponse* response;
    ulong flags;
}

// Memory map

template MemoryMapRequestID() {
    const char[] MemoryMapRequestID = "[ " ~ mixin(CommonMagic!()) ~ ", 0x67cf3d9d378a806f, 0xe304acdfc50c3c62 ]";
}

immutable ulong MemoryMapUsable = 0;
immutable ulong MemoryMapReserved = 1;
immutable ulong MemoryMapACPIReclaimable = 2;
immutable ulong MemoryMapACPINVS = 3;
immutable ulong MemoryMapBadMemory = 4;
immutable ulong MemoryMapBootloaderReclaimable = 5;
immutable ulong MemoryMapKernelAndModules = 6;
immutable ulong MemoryMapFramebuffer = 7;

struct MemmapEntry {
    ulong base;
    ulong length;
    ulong type;
}

struct MemmapResponse {
    ulong revision;
    ulong entryCount;
    MemmapEntry** entries;
}

struct MemmapRequest {
    ulong[4] id;
    ulong revision;
    MemmapResponse* response;
}

// Entry point

template EntryPointRequestID() {
    const char[] EntryPointRequestID = "[ " ~ mixin(CommonMagic!()) ~ ", 0xad97e90e83f1ed67, 0x31eb5d1c5ff23b69 ]";
}

struct EntryPointResponse {
    ulong revision;
}

struct EntryPointRequest {
    ulong[4] id;
    ulong revision;
    EntryPointResponse* response;
    void *entryPoint;
}

// Kernel file

template KernelFileRequestID() {
    const char[] KernelFileRequestID = "[ " ~ mixin(CommonMagic!()) ~ ", 0xad97e90e83f1ed67, 0x31eb5d1c5ff23b69 ]";
}

struct KernelFileResponse {
    ulong revision;
    File* kernelFile;
}

struct KernelFileRequest {
    ulong[4] id;
    ulong revision;
    KernelFileResponse* response;
}

// Module

template ModuleRequestID() {
    const char[] ModuleRequestID = "[ " ~ mixin(CommonMagic!()) ~ ", 0x3e7e279702be32af, 0xca1c4f3bd1280cee ]";
}

immutable ulong InternalModuleRequired = (1 << 0);

struct InternalModule {
    const(char)* path;
    const(char)* cmdline;
    ulong flags;
}

struct ModuleResponse {
    ulong revision;
    ulong moduleCount;
    File** modules;
}

struct ModuleRequest {
    ulong[4] id;
    ulong revision;
    ModuleResponse* response;
    ulong internalModuleCount;
    InternalModule** internalModules;
}

// RSDP

template RSDPRequestID() {
    const char[] RSDPRequestID = "[ " ~ mixin(CommonMagic!()) ~ ", 0xc5e77b6b397e7b43, 0x27637845accdcf3c ]";
}

struct RSDPResponse {
    ulong revision;
    void* address;
}

struct RSDPRequest {
    ulong[4] id;
    ulong revision;
    RSDPResponse* response;
}

// SMBIOS

template SMBIOSRequestID() {
    const char[] SMBIOSRequestID = "[ " ~ mixin(CommonMagic!()) ~ ", 0x9e9046f11e095391, 0xaa4a520fefbde5ee ]";
}

struct SMBIOSResponse {
    ulong revision;
    void* entry32;
    void* entry64;
}

struct SMBIOSRequest {
    ulong[4] id;
    ulong revision;
    SMBIOSResponse* response;
}

// EFI system table

template EFISystemTableRequestID() {
    const char[] EFISystemTableRequestID = "[ " ~ mixin(CommonMagic!()) ~ ", 0x5ceba5163eaaf6d6, 0x0a6981610cf65fcc ]";
}

struct EFISystemTableResponse {
    ulong revision;
    void* address;
}

struct EFISystemTableRequest {
    ulong[4] id;
    ulong revision;
    EFISystemTableResponse* response;
}

// Boot time

template BootTimeRequestID() {
    const char[] BootTimeRequestID = "[ " ~ mixin(CommonMagic!()) ~ ", 0x502746e184c088aa, 0xfbc5ec83e6327893 ]";
}

struct BootTimeResponse {
    ulong revision;
    long bootTime;
}

struct BootTimeRequest {
    ulong[4] id;
    ulong revision;
    BootTimeResponse* response;
}

// Kernel address

template KernelAddressRequestID() {
    const char[] KernelAddressRequestID = "[ " ~ mixin(CommonMagic!()) ~ ", 0x71ba76863cc55f63, 0xb2644a48c516a487 ]";
}

struct KernelAddressResponse {
    ulong revision;
    ulong physicalBase;
    ulong virtualBase;
}

struct KernelAddressRequest {
    ulong[4] id;
    ulong revision;
    KernelAddressResponse* response;
}

// DTB

template DTBRequestID() {
    const char[] DTBRequestID = "[ " ~ mixin(CommonMagic!()) ~ ", 0xb40ddb48fb54bac7, 0x545081493f81ffb7 ]";
}

struct DTBResponse {
    ulong revision;
    void* dtbPtr;
}

struct DTBRequest {
    ulong[4] id;
    ulong revision;
    DTBResponse* response;
}
