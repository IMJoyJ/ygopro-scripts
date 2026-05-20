--レッド・ガードナー
-- 效果：
-- ①：自己场上有「红莲魔」怪兽存在，对方的魔法·陷阱·怪兽的效果发动时，把这张卡从手卡送去墓地才能发动。这个回合，自己场上的怪兽不会被对方的效果破坏。
function c72318602.initial_effect(c)
	-- ①：自己场上有「红莲魔」怪兽存在，对方的魔法·陷阱·怪兽的效果发动时，把这张卡从手卡送去墓地才能发动。这个回合，自己场上的怪兽不会被对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c72318602.condition)
	e1:SetCost(c72318602.cost)
	e1:SetOperation(c72318602.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查卡片是否为表侧表示的「红莲魔」怪兽
function c72318602.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1045)
end
-- 发动条件：对方发动卡的效果，且自己场上存在表侧表示的「红莲魔」怪兽
function c72318602.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查发动效果的玩家是否为对方，且自己场上是否存在至少1张表侧表示的「红莲魔」怪兽
	return ep~=tp and Duel.IsExistingMatchingCard(c72318602.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 发动代价：检查并把这张卡从手卡送去墓地
function c72318602.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡作为发动代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 效果处理：创建一个使自己场上的怪兽不会被对方的效果破坏的全局效果，并注册给玩家
function c72318602.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，自己场上的怪兽不会被对方的效果破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置不会被破坏的效果判定：仅在效果由对方玩家发动时适用
	e1:SetValue(aux.indoval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该效果作为玩家的效果注册给全局环境
	Duel.RegisterEffect(e1,tp)
end
