--ヘルフレイムエンペラー
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：这张卡上级召唤时，从自己墓地把最多5只炎属性怪兽除外才能发动。把除外数量的场上的魔法·陷阱卡破坏。
function c19847532.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：这张卡上级召唤时，从自己墓地把最多5只炎属性怪兽除外才能发动。把除外数量的场上的魔法·陷阱卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19847532,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCondition(c19847532.condition)
	e2:SetTarget(c19847532.target)
	e2:SetOperation(c19847532.operation)
	c:RegisterEffect(e2)
end
-- 效果作用：判断是否为上级召唤
function c19847532.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 效果作用：过滤魔法·陷阱卡
function c19847532.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果作用：过滤炎属性怪兽
function c19847532.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToRemoveAsCost()
end
-- 效果作用：检查是否满足发动条件
function c19847532.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查场上是否存在魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c19847532.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		-- 效果作用：检查墓地是否存在炎属性怪兽
		and Duel.IsExistingMatchingCard(c19847532.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 效果作用：获取场上的魔法·陷阱卡
	local dg=Duel.GetMatchingGroup(c19847532.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local ct=dg:GetCount()
	if ct>5 then ct=5 end
	-- 效果作用：提示选择除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 效果作用：选择除外的炎属性怪兽
	local rg=Duel.SelectMatchingCard(tp,c19847532.cfilter,tp,LOCATION_GRAVE,0,1,ct,nil)
	-- 效果作用：将选中的怪兽除外
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	-- 效果作用：设置操作参数为除外的怪兽数量
	Duel.SetTargetParam(rg:GetCount())
	-- 效果作用：设置连锁操作信息为破坏指定数量的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,rg:GetCount(),0,0)
end
-- 效果作用：处理破坏效果
function c19847532.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取操作参数中的除外数量
	local ct=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 效果作用：提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 效果作用：选择要破坏的魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c19847532.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,ct,nil)
	-- 效果作用：显示选中的卡被选为对象
	Duel.HintSelection(g)
	-- 效果作用：破坏选中的魔法·陷阱卡
	Duel.Destroy(g,REASON_EFFECT)
end
