--サクリファイス・スパイダー
-- 效果：
-- 自己墓地昆虫族怪兽有4只以上存在的场合，把这张卡解放发动。对方场上表侧守备表示存在的怪兽全部破坏。
function c54248491.initial_effect(c)
	-- 自己墓地昆虫族怪兽有4只以上存在的场合，把这张卡解放发动。对方场上表侧守备表示存在的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54248491,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c54248491.condition)
	e1:SetCost(c54248491.cost)
	e1:SetTarget(c54248491.target)
	e1:SetOperation(c54248491.operation)
	c:RegisterEffect(e1)
end
-- 定义效果的发动条件函数
function c54248491.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在4只或以上的昆虫族怪兽
	return Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_GRAVE,0,4,nil,RACE_INSECT)
end
-- 定义效果的发动代价函数
function c54248491.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤出表侧守备表示怪兽的辅助函数
function c54248491.filter(c)
	return c:IsPosition(POS_FACEUP_DEFENSE)
end
-- 定义效果的发动目标确认与操作信息设置函数
function c54248491.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查对方场上是否存在至少1只表侧守备表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c54248491.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有表侧守备表示的怪兽组
	local g=Duel.GetMatchingGroup(c54248491.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置效果处理的操作信息为破坏这些怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 定义效果的处理逻辑函数
function c54248491.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，重新获取对方场上所有表侧守备表示的怪兽组
	local g=Duel.GetMatchingGroup(c54248491.filter,tp,0,LOCATION_MZONE,nil)
	-- 破坏获取到的所有表侧守备表示怪兽
	Duel.Destroy(g,REASON_EFFECT)
end
