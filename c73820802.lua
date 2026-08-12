--鬼くじ
-- 效果：
-- ①：自己准备阶段把这个效果发动。对方宣言卡的种类（怪兽·魔法·陷阱）。自己卡组最上面的卡翻开，翻开的卡是宣言的种类的卡的场合，对方从卡组抽1张。不是的场合，对方手卡随机选1张丢弃。翻开的卡回到卡组最下面。
function c73820802.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_STANDBY_PHASE,0)
	c:RegisterEffect(e1)
	-- ①：自己准备阶段把这个效果发动。对方宣言卡的种类（怪兽·魔法·陷阱）。自己卡组最上面的卡翻开，翻开的卡是宣言的种类的卡的场合，对方从卡组抽1张。不是的场合，对方手卡随机选1张丢弃。翻开的卡回到卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73820802,0))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES_OPPO)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1)
	e2:SetCondition(c73820802.condition)
	e2:SetOperation(c73820802.operation)
	c:RegisterEffect(e2)
end
-- 效果发动条件：当前回合是自己的回合
function c73820802.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return tp==Duel.GetTurnPlayer()
end
-- 效果处理：对方宣言卡片种类并翻开自己卡组最上方的卡，根据是否吻合让对方抽卡或随机丢弃手牌，最后将翻开的卡放回卡组最下方
function c73820802.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己卡组没有卡，则不处理效果
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	-- 给对方玩家发送“请选择一个种类”的提示信息
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
	-- 让对方玩家宣言一个卡片种类（怪兽·魔法·陷阱）
	local op=Duel.AnnounceType(1-tp)
	-- 确认（翻开）自己卡组最上方的一张卡
	Duel.ConfirmDecktop(tp,1)
	-- 获取自己卡组最上方的一张卡
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if (op==0 and tc:IsType(TYPE_MONSTER)) or (op==1 and tc:IsType(TYPE_SPELL)) or (op==2 and tc:IsType(TYPE_TRAP)) then
		-- 对方玩家从卡组抽1张卡
		Duel.Draw(1-tp,1,REASON_EFFECT)
	else
		-- 获取对方玩家的手牌
		local hg=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
		if hg:GetCount()>0 then
			local sg=hg:RandomSelect(1-tp,1)
			-- 将选中的对方手牌以效果丢弃送去墓地
			Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
		end
	end
	-- 将翻开的卡移动到卡组最下面
	Duel.MoveSequence(tc,SEQ_DECKBOTTOM)
end
