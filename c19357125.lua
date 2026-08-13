--ダーク・アサシン
-- 效果：
-- 自己墓地存在的暗属性怪兽数量让这张卡得到以下效果。
-- ●1张以下：这张卡的攻击力下降400。
-- ●2至4张：这张卡的攻击力上升400。
-- ●5张以上：可以把这张卡送去墓地，对方场上里侧表示存在的怪兽全部破坏。
function c19357125.initial_effect(c)
	-- 自己墓地存在的暗属性怪兽数量让这张卡得到以下效果。●1张以下：这张卡的攻击力下降400。●2至4张：这张卡的攻击力上升400。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c19357125.atkval)
	c:RegisterEffect(e1)
	-- ●5张以上：可以把这张卡送去墓地，对方场上里侧表示存在的怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19357125,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c19357125.condition)
	e2:SetCost(c19357125.cost)
	e2:SetTarget(c19357125.target)
	e2:SetOperation(c19357125.operation)
	c:RegisterEffect(e2)
end
-- 根据自己墓地暗属性怪兽数量计算攻击力变化值：1张以下下降400，2至4张上升400，5张以上不增减。
function c19357125.atkval(e,c)
	-- 统计该卡控制者墓地中暗属性怪兽的数量。
	local ct=Duel.GetMatchingGroupCount(Card.IsAttribute,c:GetControler(),LOCATION_GRAVE,0,nil,ATTRIBUTE_DARK)
	if ct<=1 then return -400
	elseif ct<=4 then return 400
	else return 0 end
end
-- 该起动效果的发动条件判定：自身未被无效，且自己墓地存在5张以上暗属性怪兽。
function c19357125.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检测效果发动者未被无效，且自己墓地至少有5张暗属性怪兽。
	return not e:GetHandler():IsDisabled() and Duel.IsExistingMatchingCard(Card.IsAttribute,tp,LOCATION_GRAVE,0,5,nil,ATTRIBUTE_DARK)
end
-- 发动代价：检查自身是否可解放，并将自身解放作为发动代价。
function c19357125.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 以代价解放该效果发动者自身。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 里侧表示怪兽的过滤函数，用于选出对方场上里侧表示的怪兽。
function c19357125.filter(c)
	return c:IsFacedown()
end
-- 发动时进行合法性检查并登记破坏信息：若对方场上有里侧表示怪兽，则获取全部此类怪兽并设置破坏操作信息。
function c19357125.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只里侧表示怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c19357125.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有里侧表示怪兽的集合，用于登记破坏数量。
	local g=Duel.GetMatchingGroup(c19357125.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：登记破坏上述所有里侧表示怪兽的数量与破坏分类，供后续处理及其他卡响应。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：获取对方场上所有里侧表示怪兽并全部破坏。
function c19357125.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有里侧表示怪兽（处理时再次取得）。
	local g=Duel.GetMatchingGroup(c19357125.filter,tp,0,LOCATION_MZONE,nil)
	-- 以效果原因破坏这些里侧表示怪兽。
	Duel.Destroy(g,REASON_EFFECT)
end
