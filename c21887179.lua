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
-- 获取这张卡进行战斗的对象并暂存，然后判定伤害步骤结束时相关条件：该对象必须存在、是恶魔族或不死族怪兽且仍与本次战斗相关，以决定效果是否发动。
function c21887179.descon(e,tp,eg,ep,ev,re,r,rp)
	local t=e:GetHandler():GetBattleTarget()
	e:SetLabelObject(t)
	-- 返回条件判定结果：伤害步骤终了时本卡相关，且战斗对象存在、种族为恶魔族或不死族、且仍与本次战斗关联。
	return aux.dsercon(e,tp,eg,ep,ev,re,r,rp) and t and t:IsRace(RACE_FIEND+RACE_ZOMBIE) and t:IsRelateToBattle()
end
-- 效果发动时无额外选择操作（chk==0 直接通过），并指定将暂存的战斗对象作为破坏目标。
function c21887179.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设定本次连锁处理的操作信息：以暂存的战斗怪兽为对象，进行1张卡的破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetLabelObject(),1,0,0)
end
-- 效果处理时取出之前暂存的战斗对象，若其仍与本次战斗相关，则将其破坏。
function c21887179.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() then
		-- 以效果来破坏该战斗对象（送去墓地）。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
