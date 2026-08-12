--龍骨鬼
-- 效果：
-- 和这张卡进行战斗的怪兽是战士族·魔法师族的场合，伤害步骤结束时把那只怪兽破坏。
function c57281778.initial_effect(c)
	-- 和这张卡进行战斗的怪兽是战士族·魔法师族的场合，伤害步骤结束时把那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57281778,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetCondition(c57281778.descon)
	e1:SetTarget(c57281778.destg)
	e1:SetOperation(c57281778.desop)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件函数，获取与自身战斗的怪兽并将其保存为标签对象，用于后续判断和处理
function c57281778.descon(e,tp,eg,ep,ev,re,r,rp)
	local t=e:GetHandler():GetBattleTarget()
	e:SetLabelObject(t)
	-- 检查自身是否满足伤害步骤结束时的战斗关联条件，且战斗对象存在、属于战士族或魔法师族，并与本次战斗关联
	return aux.dsercon(e,tp,eg,ep,ev,re,r,rp) and t and t:IsRace(RACE_SPELLCASTER+RACE_WARRIOR) and t:IsRelateToBattle()
end
-- 定义效果发动目标函数，作为强制诱发效果直接允许发动，并设置破坏操作的信息
function c57281778.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁的操作信息，表明此效果的处理为破坏1只保存的战斗对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetLabelObject(),1,0,0)
end
-- 定义效果处理函数，获取保存的战斗对象，在其仍与战斗关联时将其破坏
function c57281778.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() then
		-- 将目标怪兽因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
