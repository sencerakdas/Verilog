`timescale 1s/1ms
// ============================================================
// dead_hand.v  (STUDENT STARTER CODE)
// BBM233 Logic Design Laboratory
// Final Project: World War III – Dead Hand Protocol
//
// IMPORTANT:
// - Do NOT change module name or port list.
// - clk is 1 Hz (1 tick per second).
// - reset is synchronous, active-high.
// - Implement Main FSM + Engagement Sub-FSM.
// ============================================================

module dead_hand(
    input  wire       clk,
    input  wire       reset,
    input  wire [1:0] threat_level,
    input  wire       diplomatic_override,
    input  wire       comms_lost,
    input  wire       system_fault,

    output reg        armed_out,
    output reg        tracking_out,
    output reg        authorization_out,
    output reg        override_ignored,
    output reg [2:0]  main_state_out,
    output reg [1:0]  sub_state_out,
    output reg [31:0] timer_out
);

    // ---------------- STATES ----------------
    localparam PEACE        = 3'b000,
               ALERT        = 3'b001,
               MOBILIZATION = 3'b010,
               ENGAGEMENT   = 3'b011,
               GLOBAL_WAR   = 3'b101,
               DEADLOCK     = 3'b110;

    localparam SUB_ARM       = 2'b00,
               SUB_TRACK     = 2'b01,
               SUB_AUTHORIZE = 2'b10,
               SUB_ABORT     = 2'b11;

    reg [2:0]  m_state;
    reg [1:0]  s_state;
    reg [31:0] m_timer;
    reg [31:0] s_timer;

    // ---------------- MAIN FSM ----------------
    always @(posedge clk) begin

        // ---------- RESET ----------
        if (reset) begin
            m_state          <= PEACE;
            s_state          <= SUB_ABORT;
            m_timer          <= 0;
            s_timer          <= 0;
            override_ignored <= 0;
        end

        // ---------- SYSTEM FAULT ----------
        else if (system_fault && m_state != GLOBAL_WAR && m_state != DEADLOCK) begin
            m_state <= GLOBAL_WAR;
        end

        else begin

            // ---------- LATE OVERRIDE ----------
            
            if (diplomatic_override &&
               (m_state == GLOBAL_WAR ||
                m_state == DEADLOCK ||
               (m_state == ENGAGEMENT &&
                s_state == SUB_AUTHORIZE &&
                s_timer > 2)))  // 3. saniye ve sonrası
                override_ignored <= 1;

            // ---------- MAIN FSM ----------
            case (m_state)

                PEACE: begin
                    s_state <= SUB_ABORT;
                    s_timer <= 0;

                    if (threat_level >= 2'b01) begin
                        m_timer <= m_timer + 1;
                        if (m_timer == 4) begin
                            m_state <= ALERT;
                            m_timer <= 0;
                        end
                    end else m_timer <= 0;
                end

                ALERT: begin
                    s_state <= SUB_ABORT;
                    s_timer <= 0;

                    if (threat_level >= 2'b10) begin
                        m_timer <= m_timer + 1;
                        if (m_timer == 9) begin
                            m_state <= MOBILIZATION;
                            m_timer <= 0;
                        end
                    end
                    else if (threat_level == 2'b00) begin
                        m_timer <= m_timer + 1;
                        if (m_timer == 3) begin
                            m_state <= PEACE;
                            m_timer <= 0;
                        end
                    end
                    else m_timer <= 0;
                end

                MOBILIZATION: begin
                    s_state <= SUB_ABORT;
                    s_timer <= 0;

                    if (threat_level == 2'b11 || comms_lost) begin
                        m_state <= ENGAGEMENT;
                        s_state <= SUB_ARM;
                        m_timer <= 0;
                        s_timer <= 0;
                    end
                    else if (threat_level <= 2'b01) begin
                        m_timer <= m_timer + 1;
                        if (m_timer == 3) begin
                            m_state <= ALERT;
                            m_timer <= 0;
                        end
                    end
                    else m_timer <= 0;
                end

                ENGAGEMENT: begin
                    m_timer <= 0;

                    if (diplomatic_override && !override_ignored) begin
                        s_state <= SUB_ABORT;
                        s_timer <= 0;
                    end
                    else begin
                        
                        if (s_state == SUB_ARM && s_timer == 3) begin
                            s_state <= SUB_TRACK;
                            s_timer <= 0;
                        end
                        else if (s_state == SUB_TRACK && s_timer == 5) begin
                            s_state <= SUB_AUTHORIZE;
                            s_timer <= 0;
                        end
                        else if (s_state == SUB_AUTHORIZE && s_timer == 2) begin
                            m_state <= DEADLOCK;
                            s_timer <= 0;
                        end
                        else if (s_state == SUB_ABORT && s_timer == 4) begin
                            m_state <= MOBILIZATION;
                            m_timer <= 0;
                            s_timer <= 0;
                        end
                        else begin
                            
                            s_timer <= s_timer + 1;
                        end
                    end
                end

                default: begin
                    m_state <= m_state;
                end
            endcase
        end
    end

    // ---------------- OUTPUT LOGIC ----------------
    always @(*) begin
        main_state_out = m_state;
        sub_state_out  = s_state;
        timer_out      = (m_state == ENGAGEMENT) ? s_timer : m_timer;

        armed_out         = (m_state == ENGAGEMENT && s_state == SUB_ARM);
        tracking_out      = (m_state == ENGAGEMENT && s_state == SUB_TRACK);
        authorization_out = (m_state == ENGAGEMENT && s_state == SUB_AUTHORIZE);
    end

endmodule