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
-- 效果的发动代价：将场上的这张卡解放。
function c52860176.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身作为代价解放送去墓地。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤筛选对方场上表侧表示、等级3以下且控制权可以改变的怪兽。
function c52860176.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(3) and c:IsControlerCanBeChanged(true)
end
-- 效果的Target逻辑：检查对方场上是否存在符合条件的3星以下怪兽且自己怪兽区有足够的空位放控制权转移的怪兽。
function c52860176.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上所有表侧表示且等级3以下的怪兽卡组。
	local g=Duel.GetMatchingGroup(c52860176.filter,tp,0,LOCATION_MZONE,nil)
	-- 计算解放自身后自己场上空余的怪兽区空格数。
	local ft=Duel.GetMZoneCount(tp,e:GetHandler())
	if chk==0 then return ft>=g:GetCount() and g:GetCount()>0 end
	-- 设置连锁的操作信息为获得符合条件的所有怪兽的控制权。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,g:GetCount(),0,0)
end
-- 效果的处理函数：获取对方场上所有表侧表示3星以下的怪兽并转移控制权给自己。
function c52860176.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 重新获取对方场上所有表侧表示且等级3以下的怪兽卡组。
	local g=Duel.GetMatchingGroup(c52860176.filter,tp,0,LOCATION_MZONE,nil)
	-- 获得目标怪兽卡组中所有怪兽的控制权。
	Duel.GetControl(g,tp)
end
