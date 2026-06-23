--百獣大行進
-- 效果：
-- 自己场上表侧表示的兽族怪兽的攻击力，在结束阶段前提升自己场上兽族怪兽数目×200的数值。
function c1689516.initial_effect(c)
	-- 自己场上表侧表示的兽族怪兽的攻击力，在结束阶段前提升自己场上兽族怪兽数目×200的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前的时机发动或适用
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c1689516.target)
	e1:SetOperation(c1689516.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选场上表侧表示的兽族怪兽
function c1689516.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST)
end
-- 效果的发动条件，检查自己场上是否存在至少1只表侧表示的兽族怪兽
function c1689516.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示的兽族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c1689516.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 将满足条件的兽族怪兽攻击力提升其数量×200的数值
function c1689516.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检索满足条件的场上兽族怪兽组
	local g=Duel.GetMatchingGroup(c1689516.filter,tp,LOCATION_MZONE,0,nil)
	local atk=g:GetCount()*200
	local c=e:GetHandler()
	local tc=g:GetFirst()
	while tc do
		-- 将攻击力提升效果应用到目标怪兽上
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
