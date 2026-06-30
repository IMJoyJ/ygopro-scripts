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
-- 伤害步骤结束时，将自身变成攻击表示的具体处理逻辑
function c65240384.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否是被攻击对象，且为守备表示并与战斗关联
	if c==Duel.GetAttackTarget() and c:IsDefensePos() and c:IsRelateToBattle() then
		-- 将自身变成表侧攻击表示
		Duel.ChangePosition(c,POS_FACEUP_ATTACK)
	end
end
-- 检查是否只以里侧表示的自身1只为对象的魔法卡发动
function c65240384.negcon(e,tp,eg,ep,ev,re,r,rp)
	if re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		-- 获取当前发动效果的对象卡片组
		local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
		return tg:GetCount()==1 and tg:GetFirst()==e:GetHandler() and e:GetHandler():IsFacedown()
	else
		return false
	end
end
-- 魔法卡发动时，将自身变成表侧守备表示并使该发动无效的具体处理逻辑
function c65240384.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果自身与效果相关，且成功将自身变成表侧守备表示
	if c:IsRelateToEffect(e) and Duel.ChangePosition(c,POS_FACEUP_DEFENSE)>0 then
		-- 使该魔法卡的发动无效
		Duel.NegateActivation(ev)
	end
end
