--狂植物の氾濫
-- 效果：
-- 自己场上表侧表示存在的植物族怪兽的攻击力直到这个回合的结束阶段时上升自己墓地存在的植物族怪兽数量×300的数值。这个回合的结束阶段时，自己场上表侧表示存在的植物族怪兽全部破坏。
function c95507060.initial_effect(c)
	-- 自己场上表侧表示存在的植物族怪兽的攻击力直到这个回合的结束阶段时上升自己墓地存在的植物族怪兽数量×300的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果发动条件为不在伤害计算后（限制在伤害步骤中仅能在伤害计算前发动）
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c95507060.target)
	e1:SetOperation(c95507060.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的植物族怪兽
function c95507060.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
end
-- 效果发动的目标选择与可行性检查（要求场上有植物族怪兽且墓地有植物族怪兽）
function c95507060.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在表侧表示的植物族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c95507060.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己墓地是否存在植物族怪兽
		and Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_GRAVE,0,1,nil,RACE_PLANT) end
end
-- 效果处理：使场上的植物族怪兽攻击力上升，并注册在结束阶段将它们破坏的效果
function c95507060.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的植物族怪兽
	local g=Duel.GetMatchingGroup(c95507060.filter,tp,LOCATION_MZONE,0,nil)
	-- 计算自己墓地的植物族怪兽数量乘以300的攻击力上升值
	local atk=Duel.GetMatchingGroupCount(Card.IsRace,tp,LOCATION_GRAVE,0,nil,RACE_PLANT)*300
	local c=e:GetHandler()
	local tc=g:GetFirst()
	while tc do
		-- 攻击力直到这个回合的结束阶段时上升自己墓地存在的植物族怪兽数量×300的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(atk)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
	-- 这个回合的结束阶段时，自己场上表侧表示存在的植物族怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(c95507060.descon)
	e2:SetOperation(c95507060.desop)
	-- 向全局环境注册该回合结束阶段触发的效果
	Duel.RegisterEffect(e2,tp)
end
-- 判定结束阶段时自己场上是否存在需要破坏的植物族怪兽
function c95507060.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的植物族怪兽
	return Duel.IsExistingMatchingCard(c95507060.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 执行结束阶段的破坏操作
function c95507060.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前自己场上表侧表示的植物族怪兽
	local g=Duel.GetMatchingGroup(c95507060.filter,tp,LOCATION_MZONE,0,nil)
	-- 因效果将这些怪兽全部破坏
	Duel.Destroy(g,REASON_EFFECT)
end
