--魔の取引
-- 效果：
-- 对方的魔法卡发动时支付1000基本分才能发动。对方随机丢弃1张手卡。
function c69724380.initial_effect(c)
	-- 对方的魔法卡发动时支付1000基本分才能发动。对方随机丢弃1张手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES_OPPO)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c69724380.condition)
	e1:SetCost(c69724380.cost)
	e1:SetTarget(c69724380.target)
	e1:SetOperation(c69724380.activate)
	c:RegisterEffect(e1)
end
-- 检查发动条件：对方发动了魔法卡（卡片的发动）
function c69724380.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 支付1000基本分的发动代价
function c69724380.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 检查对方手卡数量并设置丢弃手卡的操作信息
function c69724380.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查对方手卡数量是否大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	Duel.SetOperationInfo(0,CATEGORY_HANDES_OPPO,nil,0,1-tp,1)
end
-- 效果处理：对方随机丢弃1张手卡
function c69724380.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方的所有手卡
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()>0 then
		local sg=g:RandomSelect(1-tp,1)
		-- 将随机选出的1张手卡以效果丢弃的形式送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
	end
end
