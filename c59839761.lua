--デルタ・クロウ－アンチ・リバース
-- 效果：
-- 自己场上的「黑羽」怪兽只有3只的场合，这张卡的发动从手卡也能用。
-- ①：自己场上有「黑羽」怪兽存在的场合才能发动。对方场上盖放的魔法·陷阱卡全部破坏。
function c59839761.initial_effect(c)
	-- ①：自己场上有「黑羽」怪兽存在的场合才能发动。对方场上盖放的魔法·陷阱卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(c59839761.condition)
	e1:SetTarget(c59839761.target)
	e1:SetOperation(c59839761.activate)
	c:RegisterEffect(e1)
	-- 自己场上的「黑羽」怪兽只有3只的场合，这张卡的发动从手卡也能用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59839761,0))  --"适用「三角乌鸦阵-反埋伏」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(c59839761.handcon)
	c:RegisterEffect(e2)
end
-- 定义手卡发动的条件函数
function c59839761.handcon(e)
	-- 检查自己场上的「黑羽」怪兽数量是否刚好为3只
	return Duel.GetMatchingGroupCount(c59839761.cfilter,e:GetHandler():GetControler(),LOCATION_MZONE,0,nil)==3
end
-- 过滤条件：表侧表示且卡名含有「黑羽」的怪兽
function c59839761.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x33)
end
-- 定义卡片发动的条件函数
function c59839761.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的「黑羽」怪兽
	return Duel.IsExistingMatchingCard(c59839761.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：里侧表示（盖放）的卡
function c59839761.filter(c)
	return c:IsFacedown()
end
-- 定义卡片发动的目标处理函数
function c59839761.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查对方魔陷区是否存在至少1张盖放的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c59839761.filter,tp,0,LOCATION_SZONE,1,nil) end
	-- 获取对方魔陷区所有盖放的卡片组
	local g=Duel.GetMatchingGroup(c59839761.filter,tp,0,LOCATION_SZONE,nil)
	-- 设置破坏效果的操作信息，指定目标卡片组及数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 定义卡片发动的效果处理函数
function c59839761.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，获取对方魔陷区所有盖放的卡片组
	local g=Duel.GetMatchingGroup(c59839761.filter,tp,0,LOCATION_SZONE,nil)
	-- 因效果破坏获取到的所有卡片
	Duel.Destroy(g,REASON_EFFECT)
end
