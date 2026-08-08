--憑依するブラッド・ソウル
-- 效果：
-- 这张卡做祭品。得到对方场上的全部3星以下的怪兽的控制权。
function c52860176.initial_effect(c)
	-- 处理卡片效果的发动条件、目标选择及效果操作
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52860176,0))  --"得到控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c52860176.cost)
	e1:SetTarget(c52860176.target)
	e1:SetOperation(c52860176.operation)
	c:RegisterEffect(e1)
end
-- 执行对应的效果条件检查或辅助函数处理
function c52860176.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 执行对应的效果条件检查或辅助函数处理
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 执行对应的效果条件检查或辅助函数处理
function c52860176.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(3) and c:IsControlerCanBeChanged(true)
end
-- 执行对应的效果条件检查或辅助函数处理
function c52860176.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 执行对应的效果条件检查或辅助函数处理
	local g=Duel.GetMatchingGroup(c52860176.filter,tp,0,LOCATION_MZONE,nil)
	-- 执行对应的效果条件检查或辅助函数处理
	local ft=Duel.GetMZoneCount(tp,e:GetHandler())
	if chk==0 then return ft>=g:GetCount() and g:GetCount()>0 end
	-- 执行对应的效果条件检查或辅助函数处理
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,g:GetCount(),0,0)
end
-- 执行对应的效果条件检查或辅助函数处理
function c52860176.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 执行对应的效果条件检查或辅助函数处理
	local g=Duel.GetMatchingGroup(c52860176.filter,tp,0,LOCATION_MZONE,nil)
	-- 执行对应的效果条件检查或辅助函数处理
	Duel.GetControl(g,tp)
end
