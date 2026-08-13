--ビッグ・シールド・ガードナー
-- 效果：
-- ①：只以里侧表示的这只怪兽1只为对象的魔法卡发动时发动。这张卡变成表侧守备表示，那个发动无效。
-- ②：这张卡被攻击的场合，伤害步骤结束时变成攻击表示。
function c65240384.initial_effect(c)
	-- ②：这张卡被攻击的场合，伤害步骤结束时变成攻击表示。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetOperation(c65240384.posop)
	c:RegisterEffect(e1)
	-- ①：只以里侧表示的这只怪兽1只为对象的魔法卡发动时发动。这张卡变成表侧守备表示，那个发动无效。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_F)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c65240384.negcon)
	e2:SetOperation(c65240384.negop)
	c:RegisterEffect(e2)
end
-- 伤害步骤结束时的处理：这张卡是攻击对象且为守备表示并且仍与本次战斗关联时，将其变成表侧攻击表示。
function c65240384.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡是本次攻击的对象、处于守备表示、且仍与本次战斗关联（未在伤害计算后离场）。
	if c==Duel.GetAttackTarget() and c:IsDefensePos() and c:IsRelateToBattle() then
		-- 将这张卡变成表侧攻击表示。
		Duel.ChangePosition(c,POS_FACEUP_ATTACK)
	end
end
-- ①效果的发动条件：发动的连锁是取对象的魔法卡的发动，且对象只有1张、是这张卡本身、且这张卡处于里侧表示。
function c65240384.negcon(e,tp,eg,ep,ev,re,r,rp)
	if re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		-- 取得当前连锁的效果对象卡片组。
		local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
		return tg:GetCount()==1 and tg:GetFirst()==e:GetHandler() and e:GetHandler():IsFacedown()
	else
		return false
	end
end
-- ①效果的处理：这张卡仍与这个效果关联并成功变成表侧守备表示后，将那次魔法卡的发动无效。
function c65240384.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与这个效果关联，并尝试将其变成表侧守备表示（以实际变更成功为前提继续处理）。
	if c:IsRelateToEffect(e) and Duel.ChangePosition(c,POS_FACEUP_DEFENSE)>0 then
		-- 将当前连锁中那次魔法卡的发动无效。
		Duel.NegateActivation(ev)
	end
end
