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
-- 伤害步骤结束时，若这张卡是被攻击的守备表示怪兽且未离场，则将其变为表侧攻击表示
function c65240384.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡是否是被攻击的守备表示怪兽，且在伤害步骤结束时仍与战斗相关联
	if c==Duel.GetAttackTarget() and c:IsDefensePos() and c:IsRelateToBattle() then
		-- 将这张卡改变为表侧攻击表示
		Duel.ChangePosition(c,POS_FACEUP_ATTACK)
	end
end
-- 判断发动的效果是否为仅以里侧表示的这张卡为对象的魔法卡的发动
function c65240384.negcon(e,tp,eg,ep,ev,re,r,rp)
	if re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		-- 获取当前连锁中该效果的对象卡片组
		local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
		return tg:GetCount()==1 and tg:GetFirst()==e:GetHandler() and e:GetHandler():IsFacedown()
	else
		return false
	end
end
-- 将这张卡变为表侧守备表示，并使该魔法卡的发动无效
function c65240384.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡仍受效果影响，则将其转为表侧守备表示
	if c:IsRelateToEffect(e) and Duel.ChangePosition(c,POS_FACEUP_DEFENSE) then
		-- 使该连锁的发动无效
		Duel.NegateActivation(ev)
	end
end
