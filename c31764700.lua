--ユベル－Das Extremer Traurig Drachen
-- 效果：
-- 这张卡不能通常召唤，用「于贝尔-被憎恶的骑士」的效果才能特殊召唤。
-- ①：这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
-- ②：攻击表示的这张卡在和对方怪兽进行战斗的伤害步骤结束时发动。给与对方那只对方怪兽的攻击力数值的伤害，那只怪兽破坏。
function c31764700.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：攻击表示的这张卡在和对方怪兽进行战斗的伤害步骤结束时发动。给与对方那只对方怪兽的攻击力数值的伤害，那只怪兽破坏。
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
	-- 判断效果是否满足发动条件，即该怪兽是否参与了战斗或被战斗破坏。
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
-- 记录战斗中对方怪兽的攻击力值，用于后续伤害计算。
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
-- 设置连锁操作信息，包括造成伤害和破坏对方怪兽。
function c31764700.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject():GetLabelObject()
	if chk==0 then return bc end
	-- 设置将对对方玩家造成伤害的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabelObject():GetLabel())
	if bc:IsRelateToBattle() then
		-- 设置将对方怪兽破坏的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
	end
end
-- 执行效果操作，对对方玩家造成伤害并破坏对方怪兽。
function c31764700.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因对对方玩家造成指定数值的伤害。
	Duel.Damage(1-tp,e:GetLabelObject():GetLabel(),REASON_EFFECT)
	local bc=e:GetLabelObject():GetLabelObject()
	if bc:IsRelateToBattle() then
		-- 以效果原因破坏目标怪兽。
		Duel.Destroy(bc,REASON_EFFECT)
	end
end
