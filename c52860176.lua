--憑依するブラッド・ソウル
-- 效果：
-- 这张卡做祭品。得到对方场上的全部3星以下的怪兽的控制权。
function c52860176.initial_effect(c)
	-- 这张卡做祭品。得到对方场上的全部3星以下的怪兽的控制权。
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
-- 发动Cost：检查并解放自身
function c52860176.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动Cost
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 控制权变更过滤条件：对方场上表侧表示、3星以下且控制权可变更的怪兽
function c52860176.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(3) and c:IsControlerCanBeChanged(true)
end
-- 发动准备：检查场上符合条件的怪兽与空余怪兽区域并设置操作信息
function c52860176.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上所有满足条件的3星以下怪兽
	local g=Duel.GetMatchingGroup(c52860176.filter,tp,0,LOCATION_MZONE,nil)
	-- 计算解放自身后自己场上空余的怪兽区域数量
	local ft=Duel.GetMZoneCount(tp,e:GetHandler())
	if chk==0 then return ft>=g:GetCount() and g:GetCount()>0 end
	-- 设置连锁操作信息：获得对方场上满足条件的所有3星以下怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,g:GetCount(),0,0)
end
-- 效果处理：得到对方场上全部满足条件的3星以下怪兽的控制权
function c52860176.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有满足条件的3星以下怪兽
	local g=Duel.GetMatchingGroup(c52860176.filter,tp,0,LOCATION_MZONE,nil)
	-- 得到目标怪兽的控制权
	Duel.GetControl(g,tp)
end
