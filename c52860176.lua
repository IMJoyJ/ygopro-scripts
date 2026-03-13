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
-- 定义代价函数，检查自身是否可解放并执行解放操作
function c52860176.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将发动效果的怪兽卡作为代价进行解放
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义筛选函数，过滤对方场上表侧表示且等级 3 以下且控制权可改变的怪兽
function c52860176.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(3) and c:IsControlerCanBeChanged(true)
end
-- 定义效果处理目标函数，获取符合条件的怪兽组并设置操作信息
function c52860176.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上满足筛选条件的怪兽集合
	local g=Duel.GetMatchingGroup(c52860176.filter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return g:GetCount()>0 end
	-- 设置效果处理信息，指定改变控制权的目标及数量
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,g:GetCount(),0,0)
end
-- 定义效果处理函数，获取符合条件的怪兽并执行控制权转移
function c52860176.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 再次获取对方场上满足筛选条件的怪兽集合
	local g=Duel.GetMatchingGroup(c52860176.filter,tp,0,LOCATION_MZONE,nil)
	-- 将符合条件的怪兽的控制权转移给发动效果的玩家
	Duel.GetControl(g,tp)
end
