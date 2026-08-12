--超重神鬼シュテンドウ－G
-- 效果：
-- 机械族调整1只＋调整以外的「超重武者」怪兽1只以上
-- 这张卡在规则上也当作「超重武者」卡使用。
-- ①：这张卡可以用表侧守备表示的状态作出攻击。那个场合，这张卡用守备力当作攻击力使用进行伤害计算。
-- ②：自己墓地没有魔法·陷阱卡存在，这张卡同调召唤成功时才能发动。对方场上的魔法·陷阱卡全部破坏。
function c36953371.initial_effect(c)
	-- 添加同调召唤手续，要求1只机械族调整和至少1只调整以外的「超重武者」怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),aux.NonTuner(Card.IsSetCard,0x9a),1)
	c:EnableReviveLimit()
	-- ①：这张卡可以用表侧守备表示的状态作出攻击。那个场合，这张卡用守备力当作攻击力使用进行伤害计算。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DEFENSE_ATTACK)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：自己墓地没有魔法·陷阱卡存在，这张卡同调召唤成功时才能发动。对方场上的魔法·陷阱卡全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c36953371.descon)
	e2:SetTarget(c36953371.destg)
	e2:SetOperation(c36953371.desop)
	c:RegisterEffect(e2)
end
-- 判断是否为同调召唤且自己墓地没有魔法·陷阱卡
function c36953371.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
		-- 检查自己墓地是否存在魔法·陷阱卡
		and not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL+TYPE_TRAP)
end
-- 过滤函数，用于筛选魔法·陷阱卡
function c36953371.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置效果目标，检查对方场上是否存在魔法·陷阱卡并设置破坏操作信息
function c36953371.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c36953371.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有魔法·陷阱卡组成的组
	local g=Duel.GetMatchingGroup(c36953371.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息，指定将要破坏的卡组和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行效果操作，破坏对方场上的所有魔法·陷阱卡
function c36953371.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有魔法·陷阱卡组成的组
	local g=Duel.GetMatchingGroup(c36953371.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 将指定的魔法·陷阱卡以效果原因破坏
	Duel.Destroy(g,REASON_EFFECT)
end
