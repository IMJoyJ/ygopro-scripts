--カラクリ小町 弐弐四
-- 效果：
-- 这张卡可以攻击的场合必须作出攻击。场上表侧表示存在的这张卡被选择作为攻击对象时，这张卡的表示形式变更。只要这张卡在场上表侧表示存在，自己的主要阶段时只有1次，自己在通常召唤外加上可以把1只名字带有「机巧」的怪兽召唤。
function c24621460.initial_effect(c)
	-- 这张卡可以攻击的场合必须作出攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MUST_ATTACK)
	c:RegisterEffect(e1)
	-- 场上表侧表示存在的这张卡被选择作为攻击对象时，这张卡的表示形式变更。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(24621460,0))  --"表示形式变更"
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetOperation(c24621460.posop)
	c:RegisterEffect(e3)
	-- 只要这张卡在场上表侧表示存在，自己的主要阶段时只有1次，自己在通常召唤外加上可以把1只名字带有「机巧」的怪兽召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(24621460,1))  --"使用「机巧小町 二二四」的效果召唤"
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e4:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 设置额外召唤次数的适用对象：只有卡名含有「机巧」（0x11）的怪兽才能使用这次追加的通常召唤。
	e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x11))
	c:RegisterEffect(e4)
end
-- 效果处理：当这张卡被选择为攻击对象时，若其仍为表侧表示且与该效果关联，则强制变更其表示形式（表侧攻击表示与表侧守备表示互换）。
function c24621460.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 变更这张卡的表示形式：若当前为表侧攻击表示则变为表侧守备表示，若当前为表侧守备表示则变为表侧攻击表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end
