--ブラック・イリュージョン
-- 效果：
-- ①：自己场上的攻击力2000以上的魔法师族·暗属性怪兽直到回合结束时不会被战斗破坏，效果无效化，不受对方的效果影响。
function c32754886.initial_effect(c)
	-- ①：自己场上的攻击力2000以上的魔法师族·暗属性怪兽直到回合结束时不会被战斗破坏，效果无效化，不受对方的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c32754886.target)
	e1:SetOperation(c32754886.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选表侧表示的魔法师族·暗属性怪兽且攻击力2000以上的怪兽
function c32754886.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAttackAbove(2000)
end
-- 判断是否满足条件，检查自己场上是否存在至少1只满足filter条件的怪兽
function c32754886.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只满足filter条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c32754886.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果发动时，检索满足条件的怪兽组并为每只怪兽添加效果
function c32754886.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检索满足filter条件的怪兽组
	local g=Duel.GetMatchingGroup(c32754886.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 使与目标怪兽相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 直到回合结束时不会被战斗破坏
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 直到回合结束时不会被对方的效果影响
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
		-- 不受对方的效果影响
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_IMMUNE_EFFECT)
		e4:SetValue(c32754886.efilter)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e4:SetOwnerPlayer(tp)
		tc:RegisterEffect(e4)
		tc=g:GetNext()
	end
end
-- 效果过滤函数，用于判断是否为对方的效果
function c32754886.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
