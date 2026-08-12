--トラスト・ガーディアン
-- 效果：
-- 把这张卡作为同调素材的场合，不是7星以上的同调怪兽的同调召唤不能使用。这张卡为同调素材的同调怪兽1回合只有1次不会被战斗破坏。这个效果适用的伤害步骤结束时，那只同调怪兽的攻击力·守备力下降400。
function c87319876.initial_effect(c)
	-- 把这张卡作为同调素材的场合，不是7星以上的同调怪兽的同调召唤不能使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(c87319876.synlimit)
	c:RegisterEffect(e1)
	-- 这张卡为同调素材的同调怪兽1回合只有1次不会被战斗破坏。这个效果适用的伤害步骤结束时，那只同调怪兽的攻击力·守备力下降400。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCondition(c87319876.ccon)
	e2:SetOperation(c87319876.cop)
	c:RegisterEffect(e2)
end
-- 判断同调怪兽的等级是否在6星以下，限制不能作为其同调素材
function c87319876.synlimit(e,c)
	if not c then return false end
	return c:IsLevelBelow(6)
end
-- 检查该卡是否是作为同调召唤的素材
function c87319876.ccon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO
end
-- 为作为素材召唤出的同调怪兽注册战斗破坏抗性以及降低攻防的效果
function c87319876.cop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 这张卡为同调素材的同调怪兽1回合只有1次不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetCountLimit(1)
	e1:SetValue(c87319876.valcon)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	-- 这个效果适用的伤害步骤结束时，那只同调怪兽的攻击力·守备力下降400。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetCondition(c87319876.adcon)
	e2:SetOperation(c87319876.adop)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e2,true)
end
-- 判断是否为战斗破坏，若是则注册适用标记并防止破坏
function c87319876.valcon(e,re,r,rp)
	if bit.band(r,REASON_BATTLE)~=0 then
		e:GetHandler():RegisterFlagEffect(87319876,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE,0,1)
		return true
	else return false end
end
-- 检查该怪兽是否适用了不会被战斗破坏的效果（是否存在标记）
function c87319876.adcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(87319876)~=0
end
-- 在伤害步骤结束时，使该怪兽的攻击力和守备力永久下降400
function c87319876.adop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 那只同调怪兽的攻击力·守备力下降400。
	local e1=Effect.CreateEffect(e:GetOwner())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-400)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
end
