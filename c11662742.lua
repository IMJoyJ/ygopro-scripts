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
	-- ③：自己因战斗·效果受到伤害的场合发动。场上的表侧表示的这张卡破坏。（此段为伤害事件监听，为③的发动标记伤害类型）
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_DAMAGE)
	e3:SetOperation(c11662742.dmop)
	c:RegisterEffect(e3)
	-- ③：自己因战斗受到伤害的场合发动。场上的表侧表示的这张卡破坏。（此效果对应战斗伤害导致的发动）
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
	-- ③：自己因效果受到伤害的场合发动。场上的表侧表示的这张卡破坏。（此效果对应伤害步骤内伤害计算前的效果伤害导致的发动）
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
	-- ③：自己因效果受到伤害的场合发动。场上的表侧表示的这张卡破坏。（此效果对应一般效果伤害导致的发动）
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
-- 判定被解放的怪兽是否为光属性·天使族，满足时本卡可作为2只解放用于该怪兽的上级召唤。
function c11662742.dtcon(e,c)
	local ec=e:GetHandler()
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FAIRY) and (ec:IsFaceup() or c:GetControler()==ec:GetControler())
end
-- 在受到伤害时监听伤害类型：若为战斗伤害则注册11662742标记；若为伤害阶段未计算伤害前的效果伤害则注册11662743标记，以供后续破坏效果判定。
function c11662742.dmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-ep) then return end
	if bit.band(r,REASON_BATTLE)~=0 then
		c:RegisterFlagEffect(11662742,RESET_PHASE+PHASE_DAMAGE,0,1)
	-- 当处于伤害步骤且尚未进行伤害计算时受到效果伤害，注册11662743标记，用于e5在EVENT_BATTLED时触发。
	elseif Duel.GetCurrentPhase()==PHASE_DAMAGE and not Duel.IsDamageCalculated() then
		c:RegisterFlagEffect(11662743,RESET_PHASE+PHASE_DAMAGE,0,1)
	end
end
-- e4的发动条件：检查本卡是否拥有11662742标记（即本卡控制者刚受到战斗伤害），是则允许发动自坏效果。
function c11662742.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(11662742)>0
end
-- e5的发动条件：检查本卡是否拥有11662743标记（即伤害计算前受到过效果伤害），是则允许发动自坏效果。
function c11662742.descon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(11662743)>0
end
-- e6的发动条件：伤害来源为效果伤害、受到伤害的玩家是本卡控制者，且当前不是伤害计算前（避免与e5重复）。
function c11662742.descon3(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and e:GetHandler():GetControler()==ep
		-- 进一步限定：当前不是伤害阶段，或虽是伤害阶段但已经完成伤害计算，从而排除伤害计算前的效果伤害。
		and (Duel.GetCurrentPhase()~=PHASE_DAMAGE or Duel.IsDamageCalculated())
end
-- 发动时的目标处理：无对象，确认发动可行性；通过后将本卡登记为破坏对象。
function c11662742.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向系统登记本次操作信息：效果将破坏这张卡（数量1），使其他卡能对应此破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 效果处理：若本卡仍与效果相关，则执行破坏操作。
function c11662742.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡以效果破坏的方式送去墓地。
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
