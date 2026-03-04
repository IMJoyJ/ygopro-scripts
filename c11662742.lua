--ジェルエンデュオ
-- 效果：
-- ①：天使族·光属性怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
-- ②：这张卡不会被战斗破坏。
-- ③：自己因战斗·效果受到伤害的场合发动。场上的表侧表示的这张卡破坏。
function c11662742.initial_effect(c)
	-- 效果原文：②：这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 效果原文：①：天使族·光属性怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e2:SetValue(c11662742.dtcon)
	c:RegisterEffect(e2)
	-- 效果原文：③：自己因战斗·效果受到伤害的场合发动。场上的表侧表示的这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_DAMAGE)
	e3:SetOperation(c11662742.dmop)
	c:RegisterEffect(e3)
	-- 效果原文：③：自己因战斗·效果受到伤害的场合发动。场上的表侧表示的这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(11662742,0))  --"自坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLED)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c11662742.descon)
	e4:SetTarget(c11662742.destg)
	e4:SetOperation(c11662742.desop)
	c:RegisterEffect(e4)
	-- 效果原文：③：自己因战斗·效果受到伤害的场合发动。场上的表侧表示的这张卡破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(11662742,0))  --"自坏"
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_BATTLED)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(c11662742.descon2)
	e5:SetTarget(c11662742.destg)
	e5:SetOperation(c11662742.desop)
	c:RegisterEffect(e5)
	-- 效果原文：③：自己因战斗·效果受到伤害的场合发动。场上的表侧表示的这张卡破坏。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(11662742,0))  --"自坏"
	e6:SetCategory(CATEGORY_DESTROY)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EVENT_DAMAGE)
	e6:SetCondition(c11662742.descon3)
	e6:SetTarget(c11662742.destg)
	e6:SetOperation(c11662742.desop)
	c:RegisterEffect(e6)
end
-- 判断是否为光属性天使族怪兽，用于效果①的条件判断
function c11662742.dtcon(e,c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FAIRY)
end
-- 处理伤害阶段的战斗伤害记录，用于标记是否触发效果③
function c11662742.dmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-ep) then return end
	if bit.band(r,REASON_BATTLE)~=0 then
		c:RegisterFlagEffect(11662742,RESET_PHASE+PHASE_DAMAGE,0,1)
	-- 判断当前处于伤害步骤且尚未计算伤害，用于效果③的触发条件
	elseif Duel.GetCurrentPhase()==PHASE_DAMAGE and not Duel.IsDamageCalculated() then
		c:RegisterFlagEffect(11662743,RESET_PHASE+PHASE_DAMAGE,0,1)
	end
end
-- 判断是否为战斗伤害触发的效果③
function c11662742.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(11662742)>0
end
-- 判断是否为非战斗伤害触发的效果③
function c11662742.descon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(11662743)>0
end
-- 判断是否为效果伤害且伤害来源为己方，用于效果③的触发条件
function c11662742.descon3(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and e:GetHandler():GetControler()==ep
		-- 确保伤害阶段已结束或伤害已计算，防止重复触发
		and (Duel.GetCurrentPhase()~=PHASE_DAMAGE or Duel.IsDamageCalculated())
end
-- 设置连锁操作信息，指定破坏目标为自身
function c11662742.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将要破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 执行破坏效果，将自身破坏
function c11662742.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 实际执行破坏操作，以效果原因破坏自身
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
