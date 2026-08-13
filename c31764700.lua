--ユベル－Das Extremer Traurig Drachen
-- 效果：
-- 这张卡不能通常召唤，用「于贝尔-被憎恶的骑士」的效果才能特殊召唤。
-- ①：这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
-- ②：攻击表示的这张卡在和对方怪兽进行战斗的伤害步骤结束时发动。给与对方那只对方怪兽的攻击力数值的伤害，那只怪兽破坏。
function c31764700.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡的战斗发生的对自己的战斗伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：这张卡不会被战斗破坏，
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 攻击表示的这张卡在和对方怪兽进行战斗的
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_BATTLED)
	e3:SetOperation(c31764700.batop)
	c:RegisterEffect(e3)
	-- ②：攻击表示的这张卡在和对方怪兽进行战斗的伤害步骤结束时发动。给与对方那只对方怪兽的攻击力数值的伤害，那只怪兽破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(31764700,0))  --"伤害并破坏"
	e4:SetCategory(CATEGORY_DAMAGE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	-- 设定②效果的发动条件：仅在伤害步骤结束时，本卡仍与这次战斗相关（未离场或处于被战斗破坏状态）才能发动。
	e4:SetCondition(aux.dsercon)
	e4:SetTarget(c31764700.damtg)
	e4:SetOperation(c31764700.damop)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
	-- 这张卡不能通常召唤，用「于贝尔-被憎恶的骑士」的效果才能特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e5)
end
-- 伤害计算后记录与这张卡战斗的对方怪兽及其攻击力：若存在战斗对象且本卡为攻击表示，则保存该怪兽和其攻击力到效果e3中；否则清空记录，供②效果在伤害步骤结束时使用。
function c31764700.batop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc and c:IsAttackPos() then
		e:SetLabel(bc:GetAttack())
		e:SetLabelObject(bc)
	else
		e:SetLabelObject(nil)
	end
end
-- 确认②效果可处理的目标：读取e3记录的对方战斗怪兽，若其仍存在，则将其作为伤害/破坏的对象，并设置对应的伤害与破坏操作信息。
function c31764700.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject():GetLabelObject()
	if chk==0 then return bc end
	-- 设置操作信息：本连锁将对对方（1-tp）造成等于记录攻击力数值的伤害，因伤害对象不取对象故targets为nil。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabelObject():GetLabel())
	if bc:IsRelateToBattle() then
		-- 若战斗对象仍与本次战斗相关，则设置操作信息：将破坏该战斗对象（bc），数量1。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
	end
end
-- ②效果处理：先给予对方记录攻击力数值的伤害；再确认对方怪兽仍与战斗相关时，将其破坏。
function c31764700.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 给予对方玩家记录的攻击力数值的伤害，伤害来源为效果。
	Duel.Damage(1-tp,e:GetLabelObject():GetLabel(),REASON_EFFECT)
	local bc=e:GetLabelObject():GetLabelObject()
	if bc:IsRelateToBattle() then
		-- 破坏那只对方怪兽，破坏原因为效果。
		Duel.Destroy(bc,REASON_EFFECT)
	end
end
