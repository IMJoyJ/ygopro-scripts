--サイコ・オムニバスター
-- 效果：
-- 调整＋调整以外的念动力族怪兽1只以上
-- 对方把卡的效果在场上发动时（伤害步骤除外）：可以支付2000基本分，宣言1个卡的种类（怪兽·魔法·陷阱）（每个卡的种类1回合只能为让「念力汇总破坏者」的这个效果发动宣言1次）；随机把对方1张手卡确认，那是宣言种类的场合，适用以下效果。
-- ●这个回合，这张卡不会被宣言种类的卡的效果破坏。
-- ●确认的卡直到结束阶段以表侧除外。
local s,id,o=GetID()
-- 初始化卡片效果：注册同调召唤手续、对方在场上发动卡的效果时宣言种类随机确认手牌并适用抗性/除外效果
function s.initial_effect(c)
	-- 同调召唤手续：调整＋调整以外的念动力族怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_PSYCHO),1)
	c:EnableReviveLimit()
	-- 对方把卡的效果在场上发动时（伤害步骤除外）：可以支付2000基本分，宣言1个卡的种类（怪兽·魔法·陷阱）（每个卡的种类1回合只能为让「念力汇总破坏者」的这个效果发动宣言1次）；随机把对方1张手卡确认，那是宣言种类的场合，适用以下效果。
●这个回合，这张卡不会被宣言种类的卡的效果破坏。
●确认的卡直到结束阶段以表侧除外。
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
-- 效果触发条件：对方在场上发动卡的效果
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发连锁效果的发生位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return bit.band(loc,LOCATION_ONFIELD)~=0 and rp==1-tp
		and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 效果发动Cost：支付2000基本分
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否有不低于2000的基本分可供支付
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	-- 扣除玩家2000基本分
	Duel.PayLPCost(tp,2000)
end
-- 效果发动准备：宣言未在本回合宣言过的卡片种类，并设置除外操作信息
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合是否尚未宣言过【怪兽】种类
	local b1=Duel.GetFlagEffect(tp,id)==0
	-- 检查本回合是否尚未宣言过【魔法】种类
	local b2=Duel.GetFlagEffect(tp,id+o)==0
	-- 检查本回合是否尚未宣言过【陷阱】种类
	local b3=Duel.GetFlagEffect(tp,id+o*2)==0
	-- 检查是否存在可选种类且对方手牌不为0
	if chk==0 then return (b1 or b2 or b3) and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)~=0 end
	local op=0
	if b1 or b2 or b3 then
		-- 让玩家选择并宣言1个本回合未宣言过的卡片种类
		op=aux.SelectFromOptions(tp,
			{b1,1050,TYPE_MONSTER},
			{b2,1051,TYPE_SPELL},
			{b3,1052,TYPE_TRAP})
	end
	e:SetLabel(op)
	if op==TYPE_MONSTER then
		-- 注册本回合已宣言【怪兽】种类的标记
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	elseif op==TYPE_SPELL then
		-- 注册本回合已宣言【魔法】种类的标记
		Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
	elseif op==TYPE_TRAP then
		-- 注册本回合已宣言【陷阱】种类的标记
		Duel.RegisterFlagEffect(tp,id+o*2,RESET_PHASE+PHASE_END,0,1)
	end
	-- 设置连锁操作信息：从对方手牌除外卡片
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,1-tp,LOCATION_HAND)
end
-- 效果处理：随机确认对方1张手牌，若为宣言种类则获得对应效果破坏免疫并将该手牌表侧除外至结束阶段
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方的所有手牌
	local g=Duel.GetFieldGroup(ep,LOCATION_HAND,0)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(ep,1)
	-- 向己方确认随机选中的1张对方手牌
	Duel.ConfirmCards(tp,sg)
	if sg:GetFirst():IsType(e:GetLabel()) then
		if c:IsRelateToChain() then
			-- ●这个回合，这张卡不会被宣言种类的卡的效果破坏。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetRange(LOCATION_MZONE)
			e1:SetLabel(e:GetLabel())
			e1:SetValue(s.efilter)
			c:RegisterEffect(e1)
			-- 连接效果块（分隔获得抗性与除外手牌操作）
			Duel.BreakEffect()
		end
		-- 将选中的对方手牌表侧表示除外，若成功除外则注册结束阶段回归手牌处理
		if Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)~=0 then
			local tc=sg:GetFirst()
			local fid=c:GetFieldID()
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
			-- ●确认的卡直到结束阶段以表侧除外。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetLabel(fid)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetLabelObject(tc)
			e1:SetCondition(s.retcon)
			e1:SetOperation(s.retop)
			-- 注册延迟至结束阶段生效的卡片回归手牌全局效果
			Duel.RegisterEffect(e1,tp)
		end
	end
	-- 洗切对方手牌
	Duel.ShuffleHand(1-tp)
end
-- 破坏免疫过滤条件：效果来源卡片的种类与宣言种类相同
function s.efilter(e,re)
	return re:GetOwner():IsType(e:GetLabel())
end
-- 结束阶段回归手牌条件：被除外的卡片标记与注册时一致
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
-- 结束阶段回归手牌处理：把除外的卡加回对方手牌
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将表侧除外的卡加回对方手牌
	Duel.SendtoHand(tc,1-tp,REASON_EFFECT)
end
