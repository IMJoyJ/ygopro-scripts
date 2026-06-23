--月風魔
-- 效果：
-- 与这张卡进行战斗的恶魔族·不死族怪兽在伤害步骤终了时被破坏。
function c21887179.initial_effect(c)
	-- 与这张卡进行战斗的恶魔族·不死族怪兽在伤害步骤终了时被破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21887179,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetCondition(c21887179.descon)
	e1:SetTarget(c21887179.destg)
	e1:SetOperation(c21887179.desop)
	c:RegisterEffect(e1)
end
-- 判断效果发动条件，检查是否与恶魔族或不死族怪兽战斗且该怪兽仍与战斗关联
function c21887179.descon(e,tp,eg,ep,ev,re,r,rp)
	local t=e:GetHandler():GetBattleTarget()
	e:SetLabelObject(t)
	-- 效果发动条件：满足伤害步骤结束时的战斗状态、战斗对象存在、种族为恶魔族或不死族、且与战斗相关
	return aux.dsercon(e,tp,eg,ep,ev,re,r,rp) and t and t:IsRace(RACE_FIEND+RACE_ZOMBIE) and t:IsRelateToBattle()
end
-- 设置效果目标，将战斗中被破坏的怪兽作为目标
function c21887179.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，指定破坏效果的目标为战斗中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetLabelObject(),1,0,0)
end
-- 执行效果操作，若战斗对象仍与战斗相关则将其破坏
function c21887179.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() then
		-- 将目标怪兽因效果而破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
