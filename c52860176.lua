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
-- 发动代价：检查自身是否可以被解放，并将自身解放
function c52860176.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自己场上的这张卡解放作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：检查卡片是否为对方场上表侧表示、等级3以下且可以改变控制权的怪兽
function c52860176.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(3) and c:IsControlerCanBeChanged(true)
end
-- 效果的发动与操作信息设置：检查怪兽区剩余空位能否容纳满足条件的怪兽并设置操作信息
function c52860176.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上所有满足条件的3星以下怪兽
	local g=Duel.GetMatchingGroup(c52860176.filter,tp,0,LOCATION_MZONE,nil)
	-- 获取自身离开场上后自己场上空余的怪兽区域数量
	local ft=Duel.GetMZoneCount(tp,e:GetHandler())
	if chk==0 then return ft>=g:GetCount() and g:GetCount()>0 end
	-- 设置操作信息：包含对应数量怪兽的改变控制权分类
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,g:GetCount(),0,0)
end
-- 效果处理：得到对方场上所有符合条件的3星以下怪兽的控制权
function c52860176.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上当前所有满足条件的3星以下怪兽
	local g=Duel.GetMatchingGroup(c52860176.filter,tp,0,LOCATION_MZONE,nil)
	-- 获得目标怪兽组的控制权
	Duel.GetControl(g,tp)
end
