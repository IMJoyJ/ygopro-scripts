--ジェルエンデュオ
-- 效果：
-- ①：天使族·光属性怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
-- ②：这张卡不会被战斗破坏。
-- ③：自己因战斗·效果受到伤害的场合发动。场上的表侧表示的这张卡破坏。
function c11662742.initial_effect(c)
	-- ②：这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：天使族·光属性怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e2:SetValue(c11662742.dtcon)
	c:RegisterEffect(e2)
	-- ③：自己因战斗·效果受到伤害的场合发动。场上的表侧表示的这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_DAMAGE)
	e3:SetOperation(c11662742.dmop)
	c:RegisterEffect(e3)
	-- ③：自己因战斗·效果受到伤害的场合发动。场上的表侧表示的这张卡破坏。
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
	-- ③：自己因战斗·效果受到伤害的场合发动。场上的表侧表示的这张卡破坏。
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
	-- ③：自己因战斗·效果受到伤害的场合发动。场上的表侧表示的这张卡破坏。
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
-- 双祭品条件：用于光属性·天使族怪兽的上级召唤
function c11662742.dtcon(e,c)
	local ec=e:GetHandler()
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FAIRY) and (ec:IsFaceup() or c:GetControler()==ec:GetControler())
end
-- 伤害处理：自身控制者受到战斗伤害或伤害步骤中的效果伤害时注册标记
function c11662742.dmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-ep) then return end
	if bit.band(r,REASON_BATTLE)~=0 then
		c:RegisterFlagEffect(11662742,RESET_PHASE+PHASE_DAMAGE,0,1)
	-- 检查当前是否处于伤害步骤且尚未进行伤害计算
	elseif Duel.GetCurrentPhase()==PHASE_DAMAGE and not Duel.IsDamageCalculated() then
		c:RegisterFlagEffect(11662743,RESET_PHASE+PHASE_DAMAGE,0,1)
	end
end
-- 触发条件：检查自身是否存在受到战斗伤害的标记
function c11662742.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(11662742)>0
end
-- 触发条件：检查自身是否存在伤害计算前受到效果伤害的标记
function c11662742.descon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(11662743)>0
end
-- 触发条件：受到效果伤害且不在伤害计算前（伤害步骤外或伤害计算后）
function c11662742.descon3(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and e:GetHandler():GetControler()==ep
		-- 检查当前不在伤害步骤中，或者已完成伤害计算
		and (Duel.GetCurrentPhase()~=PHASE_DAMAGE or Duel.IsDamageCalculated())
end
-- 目标检查：设置破坏自身的操作信息
function c11662742.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理的操作信息：破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 效果处理：破坏场上的这张卡
function c11662742.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身破坏
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
