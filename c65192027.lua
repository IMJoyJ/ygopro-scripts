--ダーク・アームド・ドラゴン
-- 效果：
-- 这张卡不能通常召唤。自己墓地的暗属性怪兽是3只的场合才能特殊召唤。
-- ①：从自己墓地把1只暗属性怪兽除外，以场上1张卡为对象才能发动。那张卡破坏。
function c65192027.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为不能特殊召唤（限制只能通过自身规则特殊召唤）
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 自己墓地的暗属性怪兽是3只的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(65192027,1))  --"墓地暗属性三张时才能特殊召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c65192027.spcon)
	c:RegisterEffect(e2)
	-- ①：从自己墓地把1只暗属性怪兽除外，以场上1张卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(65192027,2))  --"破坏场上一张卡"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c65192027.cost)
	e3:SetTarget(c65192027.target)
	e3:SetOperation(c65192027.activate)
	c:RegisterEffect(e3)
end
-- 特殊召唤规则的条件判定函数（检查怪兽区域空位以及墓地暗属性怪兽数量是否刚好为3只）
function c65192027.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查自己墓地的暗属性怪兽数量是否刚好等于3只
		Duel.GetMatchingGroupCount(Card.IsAttribute,c:GetControler(),LOCATION_GRAVE,0,nil,ATTRIBUTE_DARK)==3
end
-- 过滤自己墓地中可以作为发动Cost除外的暗属性怪兽
function c65192027.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
end
-- 效果发动的Cost（费用）处理函数：从自己墓地把1只暗属性怪兽除外
function c65192027.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己墓地是否存在至少1只可以作为Cost除外的暗属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c65192027.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家发送提示信息，提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只满足条件的暗属性怪兽
	local g=Duel.SelectMatchingCard(tp,c65192027.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的怪兽表侧表示除外，作为发动的Cost
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果的目标选择与发动准备函数（选择场上1张卡作为破坏对象）
function c65192027.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 在发动阶段检查场上是否存在至少1张可以作为对象的目标卡片
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 给玩家发送提示信息，提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁的操作信息，表明此效果的处理包含破坏1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果的处理函数：破坏作为对象的卡
function c65192027.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 因效果将该对象卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
