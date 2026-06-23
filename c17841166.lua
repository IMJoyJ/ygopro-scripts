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
-- 将一个场上的怪兽效果免疫效果注册到全局环境中
function c17841166.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 将一个场上的怪兽效果免疫效果注册到全局环境中
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c17841166.etarget)
	e1:SetValue(c17841166.efilter)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e1注册给玩家tp
	Duel.RegisterEffect(e1,tp)
end
-- 判断目标怪兽是否为机械族或岩石族
function c17841166.etarget(e,c)
	return bit.band(c:GetOriginalRace(),RACE_MACHINE+RACE_ROCK)~=0
end
-- 判断效果是否为怪兽卡效果且来源玩家不是当前效果持有者
function c17841166.efilter(e,te,c)
	return te:IsActiveType(TYPE_MONSTER) and (te:GetOwner()~=c or te:IsActivated() and not c:IsRelateToEffect(te))
		and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
