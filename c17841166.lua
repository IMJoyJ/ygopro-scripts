--マグネット・フォース
-- 效果：
-- ①：这个回合，原本种族是机械族或者岩石族的场上的怪兽不受自身以外的对方怪兽的效果影响。
function c17841166.initial_effect(c)
	-- ①：这个回合，原本种族是机械族或者岩石族的场上的怪兽不受自身以外的对方怪兽的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c17841166.activate)
	c:RegisterEffect(e1)
end
-- 发动后在场地上创建一个影响双方怪兽区域的持续领域效果，使原本种族为机械族或岩石族的怪兽在本回合内免疫对方怪兽的效果影响，并在结束阶段重置。
function c17841166.activate(e,tp,eg,ep,ev,re,r,rp)
	-- ①：这个回合，原本种族是机械族或者岩石族的场上的怪兽不受自身以外的对方怪兽的效果影响。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c17841166.etarget)
	e1:SetValue(c17841166.efilter)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将新生成的免疫效果注册到当前回合玩家tp的场上，使该效果开始实际适用（持续到结束阶段时重置）。
	Duel.RegisterEffect(e1,tp)
end
-- 筛选免疫效果的适用对象：匹配场上原本种族为机械族或岩石族的怪兽。
function c17841166.etarget(e,c)
	return bit.band(c:GetOriginalRace(),RACE_MACHINE+RACE_ROCK)~=0
end
-- 判断某个效果是否应被免疫：该效果须为对方玩家的怪兽效果，且不是被保护怪兽自身的效果（自身效果仍可影响自己）。
function c17841166.efilter(e,te,c)
	return te:IsActiveType(TYPE_MONSTER) and (te:GetOwner()~=c or te:IsActivated() and not c:IsRelateToEffect(te))
		and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
