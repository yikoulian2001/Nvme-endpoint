`resetall
`timescale  1ns/1ps

module  nvme_ep_top(
input                       sys_clk             ,
input                       sys_rst             ,
//localbus
input                       cbus_clk            ,
input                       cbus_rst            ,
input                       lbus_req            ,
input                       lbus_rw             ,   //1:rd 0:wr
input       [13: 0]         lbus_addr           ,
input       [31: 0]         lbus_wdata          ,
output                      lbus_ack            ,
output      [31: 0]         lbus_rdata          ,

output                      rmt_lbus_req        ,
output                      rmt_lbus_rw         ,   //1:rd 0:wr
output      [12: 0]         rmt_lbus_addr       ,
output      [31: 0]         rmt_lbus_wdata      ,
input                       rmt_lbus_ack        ,
input       [31: 0]         rmt_lbus_rdata      ,

input                       rp_init_done        ,
//interrupt
output      [ 3: 0]         msix_tab_wadrs      ,
output      [31: 0]         msix_tab_din        ,
output                      msix_tab_wen        ,
output      [ 3: 0]         nvme_irq            ,

output      [15: 0]         pcie_wr_data_ex     ,
output      [255:0]         pcie_wr_data        ,
output                      pcie_wr_wen         ,
input                       pcie_wr_ready       ,
input       [15: 0]         pcie_cpl_data_ex    ,
input       [255:0]         pcie_cpl_data       ,
input                       pcie_cpl_wen        ,
output                      pcie_cpl_ready      ,


input       [15: 0]         chan_rx_data_ex     ,
input       [127:0]         chan_rx_data        ,
input                       chan_rx_wen         ,
output                      chan_rx_ready       ,

output      [15: 0]         chan_tx_data_ex     ,
output      [127:0]         chan_tx_data        ,
output                      chan_tx_wen         ,
input                       chan_tx_ready

);


wire    [15: 0]         soft_reset              ;

//ep signal
wire    [15: 0]         nvme_tx_data_ex         ;
wire    [127:0]         nvme_tx_data            ;
wire                    nvme_tx_wen             ;
wire                    nvme_tx_ready           ;

wire    [15: 0]         nvme_rx_data_ex         ;
wire    [127:0]         nvme_rx_data            ;
wire                    nvme_rx_wen             ;
wire                    nvme_rx_ready           ;

//======================cbus ==================
wire                    vssd_lbus_req       ;
wire                    vssd_lbus_rw        ;
wire    [12: 0]         vssd_lbus_addr      ;
wire    [31: 0]         vssd_lbus_wdata     ;
wire                    vssd_lbus_ack       ;
wire    [31: 0]         vssd_lbus_rdata     ;

wire                    dfx_lbus_req        ;
wire                    dfx_lbus_rw         ;
wire    [10: 0]         dfx_lbus_addr       ;
wire    [31: 0]         dfx_lbus_wdata      ;
wire                    dfx_lbus_ack        ;
wire    [31: 0]         dfx_lbus_rdata      ;

//wire                    rmt_lbus_req        ;
//wire                    rmt_lbus_rw         ;
//wire    [13: 0]         rmt_lbus_addr       ;
//wire    [31: 0]         rmt_lbus_wdata      ;
//wire                    rmt_lbus_ack        ;
//wire    [31: 0]         rmt_lbus_rdata      ;
//
//wire    [55: 0]         cfg_tx_data         ;
//wire                    cfg_tx_wen          ;
//wire    [31: 0]         cfg_rx_data         ;
//wire                    cfg_rx_wen          ;

//status and statistic
//wire    [ 4: 0]         ep_rq_divide_inc    ;
wire    [ 0: 0]         admin_ctl_ep_inc    ;
wire    [ 4: 0]         sq_ctl_ep_inc       ;
wire    [ 4: 0]         cq_ctl_ep_inc       ;
wire    [ 3: 0]         ep_rq_order_inc     ;
wire    [ 3: 0]         ep_rc_order_inc     ;
//wire    [ 1: 0]         stream_mux_inc      ;


//wire    [31: 0]         ep_rq_divide_dbg    ;
wire    [63: 0]         admin_ctl_ep_dbg    ;
wire    [31: 0]         sq_ctl_ep_dbg       ;
wire    [31: 0]         cq_ctl_ep_dbg       ;
wire    [31: 0]         ep_rq_order_dbg     ;
wire    [31: 0]         ep_rc_order_dbg     ;
//wire    [31: 0]         stream_mux_dbg      ;

//wire    [127:0]         SQEntry             ;
//wire    [ 6: 0]         sq_cap_wadrs        ;
//wire    [ 5: 0]         sq_cap_radrs        ;
//wire    [255:0]         sq_cap_dout         ;


nvme_lbus_ctl u_nvme_lbus_ctl(
    .cbus_clk               ( cbus_clk          ),
    .cbus_rst               ( cbus_rst          ),

    .ilbus_req              ( lbus_req          ),
    .ilbus_rw               ( lbus_rw           ),   //1:rd 0:wr
    .ilbus_addr             ( lbus_addr         ),
    .ilbus_wdata            ( lbus_wdata        ),
    .olbus_ack              ( lbus_ack          ),
    .olbus_rdata            ( lbus_rdata        ),

    .olbus_req_vssd         ( vssd_lbus_req     ),
    .olbus_rw_vssd          ( vssd_lbus_rw      ),
    .olbus_addr_vssd        ( vssd_lbus_addr    ),
    .olbus_wdata_vssd       ( vssd_lbus_wdata   ),
    .ilbus_ack_vssd         ( vssd_lbus_ack     ),
    .ilbus_rdata_vssd       ( vssd_lbus_rdata   ),

    .olbus_req_dfx          ( dfx_lbus_req      ),
    .olbus_rw_dfx           ( dfx_lbus_rw       ),
    .olbus_addr_dfx         ( dfx_lbus_addr     ),
    .olbus_wdata_dfx        ( dfx_lbus_wdata    ),
    .ilbus_ack_dfx          ( dfx_lbus_ack      ),
    .ilbus_rdata_dfx        ( dfx_lbus_rdata    ),

    .olbus_req_rmt          ( rmt_lbus_req      ),
    .olbus_rw_rmt           ( rmt_lbus_rw       ),
    .olbus_addr_rmt         ( rmt_lbus_addr     ),
    .olbus_wdata_rmt        ( rmt_lbus_wdata    ),
    .ilbus_ack_rmt          ( rmt_lbus_ack      ),
    .ilbus_rdata_rmt        ( rmt_lbus_rdata    )
);


//ep_rq_divide u_ep_rq_divide(
//    .sys_clk                ( sys_clk           ),
//    .sys_rst                ( sys_rst           ),
//    .rq_mix_data_ex         ( chan_rx_data_ex   ),   //data and message
//    .rq_mix_data            ( chan_rx_data      ),
//    .rq_mix_wen             ( chan_rx_wen       ),
//    .rq_mix_ready           ( chan_rx_ready     ),
//
//    .nvme_rx_data_ex        ( nvme_rx_data_ex   ),
//    .nvme_rx_data           ( nvme_rx_data      ),
//    .nvme_rx_wen            ( nvme_rx_wen       ),
//    .nvme_rx_ready          ( nvme_rx_ready     ),
//
//    .cfg_rx_data            ( cfg_rx_data       ),
//    .cfg_rx_wen             ( cfg_rx_wen        ),
//
//    .ostat_inc              ( ep_rq_divide_inc  ),
//    .ostatus_dbg            ( ep_rq_divide_dbg  )
//);
assign nvme_rx_data_ex = chan_rx_data_ex;
assign nvme_rx_data    = chan_rx_data   ;
assign nvme_rx_wen     = chan_rx_wen    ;
assign chan_rx_ready = nvme_rx_ready;


nvme_ep #(
    .DEV_NUM    ( 1 )
)
u_nvme_ep(
    .sys_clk                ( sys_clk           ),
    .sys_rst                ( sys_rst           ),
    .cbus_clk               ( cbus_clk          ),
    .cbus_rst               ( cbus_rst          ),
//    .pcie_fn                ( 2'b0              ),
    .lbus_req               ( vssd_lbus_req     ),
    .lbus_rw                ( vssd_lbus_rw      ),   //1:rd 0:wr
    .lbus_addr              ( vssd_lbus_addr    ),
    .lbus_wdata             ( vssd_lbus_wdata   ),
    .lbus_ack               ( vssd_lbus_ack     ),
    .lbus_rdata             ( vssd_lbus_rdata   ),

    .rp_init_done           ( rp_init_done      ),
    .msix_tab_wadrs         ( msix_tab_wadrs    ),
    .msix_tab_din           ( msix_tab_din      ),
    .msix_tab_wen           ( msix_tab_wen      ),
    .nvme_irq               ( nvme_irq          ),

    .pcie_wr_data_ex        ( pcie_wr_data_ex   ),
    .pcie_wr_data           ( pcie_wr_data      ),
    .pcie_wr_wen            ( pcie_wr_wen       ),
    .pcie_wr_ready          ( pcie_wr_ready     ),
    .pcie_cpl_data_ex       ( pcie_cpl_data_ex  ),
    .pcie_cpl_data          ( pcie_cpl_data     ),
    .pcie_cpl_wen           ( pcie_cpl_wen      ),
    .pcie_cpl_ready         ( pcie_cpl_ready    ),

    .nvme_tx_data_ex        ( nvme_tx_data_ex   ),
    .nvme_tx_data           ( nvme_tx_data      ),
    .nvme_tx_wen            ( nvme_tx_wen       ),
    .nvme_tx_ready          ( nvme_tx_ready     ),

    .nvme_rx_data_ex        ( nvme_rx_data_ex   ),
    .nvme_rx_data           ( nvme_rx_data      ),
    .nvme_rx_wen            ( nvme_rx_wen       ),
    .nvme_rx_ready          ( nvme_rx_ready     ),

//    .curr_time              ( curr_time         ),
//    .cap_radrs              ( cap_radrs         ),

//    .SQEntry                ( SQEntry           ),
    .admin_ctl_ep_inc       ( admin_ctl_ep_inc  ),
    .sq_ctl_ep_inc          ( sq_ctl_ep_inc     ),
    .cq_ctl_ep_inc          ( cq_ctl_ep_inc     ),
    .ep_rq_order_inc        ( ep_rq_order_inc   ),
    .ep_rc_order_inc        ( ep_rc_order_inc   ),
    .admin_ctl_ep_dbg       ( admin_ctl_ep_dbg  ),
    .sq_ctl_ep_dbg          ( sq_ctl_ep_dbg     ),
    .cq_ctl_ep_dbg          ( cq_ctl_ep_dbg     ),
    .ep_rq_order_dbg        ( ep_rq_order_dbg   ),
    .ep_rc_order_dbg        ( ep_rc_order_dbg   )

);

//stream_mux_ep u_stream_mux_ep(
//    .clk                    ( sys_clk           ),
//    .reset                  ( sys_rst           ),
//
//    .cfg_tx_data            ( cfg_tx_data       ),
//    .cfg_tx_wen             ( cfg_tx_wen        ),
//
//    .stream_in_data_ex      ( nvme_tx_data_ex   ),
//    .stream_in_data         ( nvme_tx_data      ),
//    .stream_in_wen          ( nvme_tx_wen       ),
//    .stream_in_ready        ( nvme_tx_ready     ),
//
//    .stream_out_data_ex     ( chan_tx_data_ex   ),
//    .stream_out_data        ( chan_tx_data      ),
//    .stream_out_wen         ( chan_tx_wen       ),
//    .stream_out_ready       ( chan_tx_ready     ),
//
//    .ostat_inc              ( stream_mux_inc    ),
//    .ostatus_dbg            ( stream_mux_dbg    )
//);
assign chan_tx_data_ex = nvme_tx_data_ex;
assign chan_tx_data    = nvme_tx_data   ;
assign chan_tx_wen     = nvme_tx_wen    ;
assign nvme_tx_ready = chan_tx_ready;


nvme_ep_dfx u_nvme_ep_dfx(
    .cbus_clk               ( cbus_clk              ),
    .cbus_rst               ( cbus_rst              ),
    .sys_clk                ( sys_clk               ),

    .ilbus_req              ( dfx_lbus_req          ),
    .ilbus_rw               ( dfx_lbus_rw           ),   //1:rd 0:wr
    .ilbus_addr             ( dfx_lbus_addr         ),
    .ilbus_wdata            ( dfx_lbus_wdata        ),
    .olbus_ack              ( dfx_lbus_ack          ),
    .olbus_rdata            ( dfx_lbus_rdata        ),

    .soft_reset             ( soft_reset            ),
    .clear_stat             ( ),

//    .SQEntry                ( SQEntry               ),
//    .ep_rq_divide_inc       ( ep_rq_divide_inc      ),
    .admin_ctl_ep_inc       ( admin_ctl_ep_inc      ),
    .sq_ctl_ep_inc          ( sq_ctl_ep_inc         ),
    .cq_ctl_ep_inc          ( cq_ctl_ep_inc         ),
    .ep_rq_order_inc        ( ep_rq_order_inc       ),
    .ep_rc_order_inc        ( ep_rc_order_inc       ),
//    .stream_mux_inc         ( stream_mux_inc        ),
//    .ep_rq_divide_dbg       ( ep_rq_divide_dbg      ),
    .admin_ctl_ep_dbg       ( admin_ctl_ep_dbg      ),
    .sq_ctl_ep_dbg          ( sq_ctl_ep_dbg         ),
    .cq_ctl_ep_dbg          ( cq_ctl_ep_dbg         ),
    .ep_rq_order_dbg        ( ep_rq_order_dbg       ),
    .ep_rc_order_dbg        ( ep_rc_order_dbg       )
//    .stream_mux_dbg         ( stream_mux_dbg        )
);

//rmt_cfg_intf_ep u_rmt_cfg_intf_ep(
//    .cbus_clk               ( cbus_clk              ),
//    .cbus_rst               ( cbus_rst              ),
//    .ilbus_req              ( rmt_lbus_req          ),
//    .ilbus_rw               ( rmt_lbus_rw           ),   //1:rd 0:wr
//    .ilbus_addr             ( rmt_lbus_addr         ),
//    .ilbus_wdata            ( rmt_lbus_wdata        ),
//    .olbus_ack              ( rmt_lbus_ack          ),
//    .olbus_rdata            ( rmt_lbus_rdata        ),
//
//    .sys_clk                ( sys_clk               ),
//    .sys_rst                ( sys_rst               ),
//    .cfg_tx_data            ( cfg_tx_data           ),
//    .cfg_tx_wen             ( cfg_tx_wen            ),
//    .cfg_rx_data            ( cfg_rx_data           ),
//    .cfg_rx_wen             ( cfg_rx_wen            )
//);

endmodule