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
	-- 设置效果发动条件：只能在伤害步骤且尚未进行伤害计算时发动。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c1689516.target)
	e1:SetOperation(c1689516.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤器：筛选自己场上表侧表示的兽族怪兽。
function c1689516.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST)
end
-- 发动时的效果目标判断：检查自己场上是否存在至少1只表侧表示兽族怪兽。
function c1689516.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若在发动合法性检查阶段（chk==0），返回是否存在满足条件的表侧兽族怪兽，作为效果可否发动的依据。
	if chk==0 then return Duel.IsExistingMatchingCard(c1689516.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果处理：获取自己场上所有表侧兽族怪兽，按数量×200计算加成值，为每只怪兽赋予结束阶段前攻击力上升该数值的效果。
function c1689516.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧兽族怪兽的集合。
	local g=Duel.GetMatchingGroup(c1689516.filter,tp,LOCATION_MZONE,0,nil)
	local atk=g:GetCount()*200
	local c=e:GetHandler()
	local tc=g:GetFirst()
	while tc do
		-- 自己场上表侧表示的兽族怪兽的攻击力，在结束阶段前提升自己场上兽族怪兽数目×200的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
