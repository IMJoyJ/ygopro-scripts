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
-- 筛选自己场上表侧表示、魔法师族、暗属性、攻击力2000以上的怪兽。
function c32754886.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAttackAbove(2000)
end
-- 效果发动时的合法性判定：检查自己场上是否存在至少1只满足条件的怪兽。
function c32754886.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若chk==0（发动前检查），则自己场上存在至少1只满足条件的怪兽时才允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c32754886.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果处理时，选取自己场上所有满足条件的怪兽，对每只怪兽分别附加“不会被战斗破坏”“效果无效化”“不受对方效果影响”的效果，并持续到回合结束。
function c32754886.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上所有满足条件的表侧表示怪兽的集合。
	local g=Duel.GetMatchingGroup(c32754886.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 使与该怪兽相关的连锁都无效化，并在怪兽变里侧表示时重置。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 不会被战斗破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 效果无效化。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
		-- 不受对方的效果影响。
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
-- 免疫效果的判定条件：若某个效果的持有者与本效果的持有者不同（即来自对方），则该效果对此怪兽无效。
function c32754886.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
