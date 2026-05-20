--闇の取引
-- 效果：
-- 对方的通常魔法发动时支付1000基本分才能发动。那个时候对方发动的通常魔法的效果变成「对方随机把手卡丢弃1张」。
function c65824822.initial_effect(c)
	-- 对方的通常魔法发动时支付1000基本分才能发动。那个时候对方发动的通常魔法的效果变成「对方随机把手卡丢弃1张」。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c65824822.condition)
	e1:SetCost(c65824822.cost)
	e1:SetOperation(c65824822.activate)
	c:RegisterEffect(e1)
end
-- 变更后的效果处理：使本卡发动者（即对方的对手）随机丢弃1张手牌
function c65824822.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本卡发动者的手牌
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()>0 then
		local sg=g:RandomSelect(1-tp,1)
		-- 将选中的卡片因效果丢弃送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
	end
end
-- 发动条件：对方发动通常魔法卡，且本卡发动者的手牌数量不为0
function c65824822.condition(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return ep~=tp and rc:GetType()==TYPE_SPELL and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		-- 检查本卡发动者的手牌数量是否不为0（确保变更后的效果有卡可丢）
		and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)~=0
end
-- 发动代价：支付1000基本分
function c65824822.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查玩家是否能够支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 效果处理：清空该连锁的对象，并将该连锁的效果处理变更为指定的丢弃手牌效果
function c65824822.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	-- 将被影响的连锁的对象变更为一个空卡组（清空原效果的对象）
	Duel.ChangeTargetCard(ev,g)
	-- 将被影响的连锁的效果处理函数替换为「对方随机把手卡丢弃1张」的处理函数
	Duel.ChangeChainOperation(ev,c65824822.repop)
end
