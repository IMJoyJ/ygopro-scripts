--マスター・ジーグ
-- 效果：
-- 支付1000基本分发动。把自己场上表侧表示存在的念动力族怪兽数量的对方场上存在的怪兽破坏。这个效果1回合只能使用1次。
function c16191953.initial_effect(c)
	-- 创建效果，设置效果描述为“破坏”，分类为破坏，类型为起动效果，适用区域为主怪兽区，限制每回合只能发动1次，设置费用函数为cost，目标函数为target，效果处理函数为operation
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16191953,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c16191953.cost)
	e1:SetTarget(c16191953.target)
	e1:SetOperation(c16191953.operation)
	c:RegisterEffect(e1)
end
-- 费用函数，检查玩家是否能支付1000基本分，若能则支付1000基本分
function c16191953.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 过滤函数，判断怪兽是否为表侧表示且属于念动力族
function c16191953.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO)
end
-- 目标函数，检查是否满足发动条件，计算己方表侧表示的念动力族怪兽数量，并设置操作信息为破坏对方怪兽
function c16191953.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断己方表侧表示的念动力族怪兽数量是否小于等于对方怪兽数量
	if chk==0 then return Duel.GetMatchingGroupCount(c16191953.filter,tp,LOCATION_MZONE,0,nil)<=Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_MZONE,nil) end
	-- 计算己方表侧表示的念动力族怪兽数量
	local ct=Duel.GetMatchingGroupCount(c16191953.filter,tp,LOCATION_MZONE,0,nil)
	-- 获取对方场上所有怪兽的集合
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息，指定要破坏的怪兽集合和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,ct,0,0)
end
-- 效果处理函数，计算己方表侧表示的念动力族怪兽数量，选择对方相应数量的怪兽进行破坏
function c16191953.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 计算己方表侧表示的念动力族怪兽数量
	local ct=Duel.GetMatchingGroupCount(c16191953.filter,tp,LOCATION_MZONE,0,nil)
	-- 获取对方场上所有怪兽的集合
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	if ct>g:GetCount() then return end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local dg=g:Select(tp,ct,ct,nil)
	-- 显示被选为对象的怪兽动画效果
	Duel.HintSelection(dg)
	-- 以效果原因破坏选中的怪兽
	Duel.Destroy(dg,REASON_EFFECT)
end
