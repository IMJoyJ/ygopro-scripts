--アマゾネス・スカウト
-- 效果：
-- 把这张卡解放发动。自己场上表侧表示存在的名字带有「亚马逊」的怪兽在这个回合不会成为效果怪兽的效果的对象，不会被魔法·陷阱·效果怪兽的效果破坏。这个效果在对方回合也能发动。
function c71209500.initial_effect(c)
	-- 把这张卡解放发动。自己场上表侧表示存在的名字带有「亚马逊」的怪兽在这个回合不会成为效果怪兽的效果的对象，不会被魔法·陷阱·效果怪兽的效果破坏。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71209500,0))  --"耐性"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCost(c71209500.efcost)
	e1:SetTarget(c71209500.eftg)
	e1:SetOperation(c71209500.efop)
	c:RegisterEffect(e1)
end
-- 定义发动代价：检查自身是否可以解放，并将其解放
function c71209500.efcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：自己场上表侧表示的名字带有「亚马逊」的怪兽
function c71209500.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x4)
end
-- 定义效果的目标：检查自己场上是否存在符合条件的「亚马逊」怪兽
function c71209500.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只除自身以外的表侧表示「亚马逊」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c71209500.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
end
-- 定义效果的处理：使自己场上所有表侧表示的「亚马逊」怪兽在本回合获得对象和破坏抗性
function c71209500.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上当前所有表侧表示的「亚马逊」怪兽
	local g=Duel.GetMatchingGroup(c71209500.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 不会成为效果怪兽的效果的对象
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetValue(c71209500.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 不会被魔法·陷阱·效果怪兽的效果破坏
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
-- 过滤效果类型，限定为怪兽的效果
function c71209500.efilter(e,re,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
