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
-- 检查是否可以解放此卡作为费用
function c52860176.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将此卡解放作为费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义过滤函数，筛选表侧表示、等级3以下且控制权可改变的怪兽
function c52860176.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(3) and c:IsControlerCanBeChanged(true)
end
-- 设置连锁处理的目标为对方场上满足条件的怪兽
function c52860176.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上满足条件的怪兽数量
	local g=Duel.GetMatchingGroup(c52860176.filter,tp,0,LOCATION_MZONE,nil)
	-- 计算己方可用怪兽区数量
	local ft=Duel.GetMZoneCount(tp,e:GetHandler())
	if chk==0 then return ft>=g:GetCount() and g:GetCount()>0 end
	-- 设置连锁操作信息，表示将改变怪兽控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,g:GetCount(),0,0)
end
-- 执行怪兽控制权转移效果
function c52860176.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 再次获取对方场上满足条件的怪兽数量
	local g=Duel.GetMatchingGroup(c52860176.filter,tp,0,LOCATION_MZONE,nil)
	-- 将指定怪兽的控制权转移给指定玩家
	Duel.GetControl(g,tp)
end
