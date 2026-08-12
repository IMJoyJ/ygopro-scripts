--滅びの爆裂疾風弾
-- 效果：
-- 这张卡发动的回合，自己不能用「青眼白龙」攻击。
-- ①：自己场上有「青眼白龙」存在的场合才能发动。对方场上的怪兽全部破坏。
function c17655904.initial_effect(c)
	-- 记录此卡具有「青眼白龙」的卡片密码
	aux.AddCodeList(c,89631139)
	-- ①：自己场上有「青眼白龙」存在的场合才能发动。对方场上的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c17655904.condition)
	e1:SetCost(c17655904.cost)
	e1:SetTarget(c17655904.target)
	e1:SetOperation(c17655904.activate)
	c:RegisterEffect(e1)
	-- 设置一个计数器，用于记录玩家在该回合是否使用过「青眼白龙」攻击
	Duel.AddCustomActivityCounter(17655904,ACTIVITY_ATTACK,c17655904.counterfilter)
end
-- 计数器过滤函数，若卡片不是「青眼白龙」则计数器增加1
function c17655904.counterfilter(c)
	return not c:IsCode(89631139)
end
-- 过滤函数，用于判断场上是否存在表侧表示的「青眼白龙」
function c17655904.cfilter(c)
	return c:IsFaceup() and c:IsCode(89631139)
end
-- 条件函数，判断自己场上是否存在「青眼白龙」
function c17655904.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在「青眼白龙」
	return Duel.IsExistingMatchingCard(c17655904.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 费用函数，检查该回合是否已使用过「青眼白龙」攻击，若未使用则设置不能攻击效果
function c17655904.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查该回合是否已使用过「青眼白龙」攻击
	if chk==0 then return Duel.GetCustomActivityCount(17655904,tp,ACTIVITY_ATTACK)==0 end
	-- 创建一个影响全场的不能攻击效果，针对「青眼白龙」
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_IGNORE_IMMUNE)
	-- 设置该效果的目标为「青眼白龙」
	e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,89631139))
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 目标函数，检查对方场上是否存在怪兽
function c17655904.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上的所有怪兽作为目标组
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息，指定将要破坏的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 发动函数，将对方场上的所有怪兽破坏
function c17655904.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有怪兽作为目标组
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 将目标怪兽全部破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
