--サイコ・オムニバスター
-- 效果：
-- 调整＋调整以外的念动力族怪兽1只以上
-- 对方把卡的效果在场上发动时（伤害步骤除外）：可以支付2000基本分，宣言1个卡的种类（怪兽·魔法·陷阱）（每个卡的种类1回合只能为让「念力汇总破坏者」的这个效果发动宣言1次）；随机把对方1张手卡确认，那是宣言种类的场合，适用以下效果。
-- ●这个回合，这张卡不会被宣言种类的卡的效果破坏。
-- ●确认的卡直到结束阶段以表侧除外。
local s,id,o=GetID()
-- 定义卡片初始效果函数，添加同调召唤手续并启用复活限制。
function s.initial_effect(c)
	-- 为当前卡添加同调召唤流程，要求一个调整怪兽和一个非调整念动力族怪兽。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_PSYCHO),1)
	c:EnableReviveLimit()
●这个回合，这张卡不会被宣言种类的卡的效果破坏。
●确认的卡直到结束阶段以表侧除外。
	-- 创建诱发即时效果，用于在对方发动效果时进行除外操作。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.rmcon)
	e1:SetCost(s.rmcost)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
end
-- 定义rmcon函数，判断是否可以发动效果：检查连锁发生的地点是否为场上、玩家是否不同以及当前卡是否未被战斗破坏。
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁发生的位置。
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return bit.band(loc,LOCATION_ONFIELD)~=0 and rp==1-tp
		and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 定义rmcost函数，支付LP费用。
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付2000基本分。
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	-- 让玩家支付2000基本分。
	Duel.PayLPCost(tp,2000)
end
-- 定义rmtg函数，选择除外的卡片种类并设置目标。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前玩家的Flag效果计数，判断是否已经选择了怪兽类型。
	local b1=Duel.GetFlagEffect(tp,id)==0
	-- 获取当前玩家的Flag效果计数，判断是否已经选择了魔法类型。
	local b2=Duel.GetFlagEffect(tp,id+o)==0
	-- 获取当前玩家的Flag效果计数，判断是否已经选择了陷阱类型。
	local b3=Duel.GetFlagEffect(tp,id+o*2)==0
	-- 检查是否可以选择除外卡片种类（怪兽、魔法或陷阱）并且对方手牌不为空。
	if chk==0 then return (b1 or b2 or b3) and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)~=0 end
	local op=0
	if b1 or b2 or b3 then
		-- 使用aux.SelectFromOptions让玩家选择要除外的卡片种类：怪兽、魔法或陷阱。
		op=aux.SelectFromOptions(tp,
			{b1,1050,TYPE_MONSTER},
			{b2,1051,TYPE_SPELL},
			{b3,1052,TYPE_TRAP})
	end
	e:SetLabel(op)
	if op==TYPE_MONSTER then
		-- 为当前玩家注册Flag效果，标记已选择了怪兽类型。
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	elseif op==TYPE_SPELL then
		-- 为当前玩家注册Flag效果，标记已选择了魔法类型。
		Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
	elseif op==TYPE_TRAP then
		-- 为当前玩家注册Flag效果，标记已选择了陷阱类型。
		Duel.RegisterFlagEffect(tp,id+o*2,RESET_PHASE+PHASE_END,0,1)
	end
	-- 设置操作信息，指示将卡片从对方手牌中移除。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,1-tp,LOCATION_HAND)
end
-- 定义rmop函数，执行除外和保护效果。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上的手牌组。
	local g=Duel.GetFieldGroup(ep,LOCATION_HAND,0)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(ep,1)
	-- 确认随机选择的卡片。
	Duel.ConfirmCards(tp,sg)
	if sg:GetFirst():IsType(e:GetLabel()) then
		if c:IsRelateToChain() then
			-- 创建单张卡片效果，使这张卡不会被宣言种类的卡的效果破坏。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetRange(LOCATION_MZONE)
			e1:SetLabel(e:GetLabel())
			e1:SetValue(s.efilter)
			c:RegisterEffect(e1)
			-- 中断当前效果链，防止连锁响应。
			Duel.BreakEffect()
		end
		-- 如果成功移除卡片，则执行以下操作。
		if Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)~=0 then
			local tc=sg:GetFirst()
			local fid=c:GetFieldID()
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
			-- 定义s.efilter函数，用于判断怪兽类型是否与选择的种类一致。注册一个持续字段效果，在结束阶段将除外的卡送回手牌。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetLabel(fid)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetLabelObject(tc)
			e1:SetCondition(s.retcon)
			e1:SetOperation(s.retop)
			-- 注册创建的字段效果。
			Duel.RegisterEffect(e1,tp)
		end
	end
	-- 洗切对方的手牌。
	Duel.ShuffleHand(1-tp)
end
-- 定义efilter函数，用于判断怪兽类型是否与选择的种类一致。
function s.efilter(e,re)
	return re:GetOwner():IsType(e:GetLabel())
end
-- 定义retcon函数，检查除外卡是否仍然有效。
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
-- 定义retop函数，将除外的卡送回手牌。
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将目标卡片送回对方的手牌。
	Duel.SendtoHand(tc,1-tp,REASON_EFFECT)
end
