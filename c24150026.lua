--カラクリ無双 八壱八
-- 效果：
-- 这张卡可以攻击的场合必须作出攻击。场上表侧攻击表示存在的这张卡被选择作为攻击对象时，这张卡的表示形式变成守备表示。这张卡攻击的场合，战斗阶段结束时变成守备表示。
function c24150026.initial_effect(c)
	-- 这张卡可以攻击的场合必须作出攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MUST_ATTACK)
	c:RegisterEffect(e1)
	-- 场上表侧攻击表示存在的这张卡被选择作为攻击对象时，这张卡的表示形式变成守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(24150026,0))  --"变成守备表示"
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetCondition(c24150026.poscon)
	e3:SetOperation(c24150026.posop)
	c:RegisterEffect(e3)
	-- 这张卡攻击的场合，战斗阶段结束时变成守备表示。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c24150026.bpcon)
	e4:SetOperation(c24150026.bpop)
	c:RegisterEffect(e4)
end
-- 作为被选择为攻击对象时的诱发效果的发动条件：判断这张卡当前是否为表侧攻击表示，只有满足时才执行变守备。
function c24150026.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsAttackPos()
end
-- 处理被选择为攻击对象时的强制效果：若这张卡在效果处理时仍表侧表示且与该效果关联，则将其变为表侧守备表示。
function c24150026.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 将这张卡的表示形式变为表侧守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 作为战斗阶段结束时的诱发条件：判断这张卡在本回合是否进行过攻击（攻击次数大于0），满足时才执行变守备。
function c24150026.bpcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttackedCount()>0
end
-- 战斗阶段结束时，若这张卡仍为攻击表示，则强制将其变为表侧守备表示。
function c24150026.bpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 将这张卡的表示形式变为表侧守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
