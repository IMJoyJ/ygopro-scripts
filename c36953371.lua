--超重神鬼シュテンドウ－G
-- 效果：
-- 机械族调整1只＋调整以外的「超重武者」怪兽1只以上
-- 这张卡在规则上也当作「超重武者」卡使用。
-- ①：这张卡可以用表侧守备表示的状态作出攻击。那个场合，这张卡用守备力当作攻击力使用进行伤害计算。
-- ②：自己墓地没有魔法·陷阱卡存在，这张卡同调召唤成功时才能发动。对方场上的魔法·陷阱卡全部破坏。
function c36953371.initial_effect(c)
	-- 设定同调召唤手续：机械族调整1只＋调整以外的「超重武者」怪兽1只以上，其中调整须为机械族，非调整须为「超重武者」系列（0x9a）怪兽且数量至少1只。
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
-- 效果发动条件检查：判定这张卡是否为同调召唤成功，并且自己墓地没有魔法·陷阱卡存在，两者同时满足才可发动。
function c36953371.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
		-- 检查自己墓地是否存在魔法·陷阱卡；若不存在（not ...）则条件成立。
		and not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL+TYPE_TRAP)
end
-- 定义筛选函数：判断卡片是否为魔法卡或陷阱卡（即对方场上的魔法·陷阱卡）。
function c36953371.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 发动时选择目标：验证对方场上有魔法·陷阱卡存在，并取得对方场上所有魔法·陷阱卡，将破坏这些卡的信息登记到连锁处理中。
function c36953371.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时（chk==0）检查对方场上是否存在至少1张可被破坏的魔法·陷阱卡，作为发动合法性条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c36953371.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有魔法·陷阱卡，构成一个卡组对象，用于后续破坏。
	local g=Duel.GetMatchingGroup(c36953371.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 登记这次效果将破坏的对象和数量到连锁操作信息，分类为破坏效果。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时：再次取得对方场上所有魔法·陷阱卡，并将其全部破坏。
function c36953371.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前对方场上存在的所有魔法·陷阱卡（不取对象）。
	local g=Duel.GetMatchingGroup(c36953371.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 将所有符合条件的卡片以效果破坏送入墓地。
	Duel.Destroy(g,REASON_EFFECT)
end
