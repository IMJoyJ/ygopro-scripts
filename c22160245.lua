--E-HERO インフェルノ・ウィング
-- 效果：
-- 「元素英雄 羽翼侠」＋「元素英雄 爆热女郎」
-- 这张卡用「暗黑融合」的效果才能特殊召唤。
-- ①：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ②：这张卡战斗破坏怪兽送去墓地的场合发动。给与对方那只怪兽的原本攻击力和原本守备力之内较高方数值的伤害。
function c22160245.initial_effect(c)
	-- 记录此卡可以通过「暗黑融合」特殊召唤
	aux.AddCodeList(c,94820406)
	c:EnableReviveLimit()
	-- 设置此卡融合召唤所需的2只融合素材卡号
	aux.AddFusionProcCode2(c,58932615,21844576,true,true)
	-- ①：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为只能通过「暗黑融合」或「暗黑神召」
	e1:SetValue(aux.DarkFusionLimit)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏怪兽送去墓地的场合发动。给与对方那只怪兽的原本攻击力和原本守备力之内较高方数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22160245,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置效果触发条件为战斗破坏对方怪兽送去墓地
	e2:SetCondition(aux.bdgcon)
	e2:SetTarget(c22160245.damtg)
	e2:SetOperation(c22160245.damop)
	c:RegisterEffect(e2)
	-- 此卡具有贯穿伤害效果
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e3)
end
c22160245.material_setcode=0x8
c22160245.dark_calling=true
-- 计算战斗破坏怪兽的攻击力与守备力中的较高值作为伤害数值
function c22160245.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local dam=bc:GetAttack()
	if bc:GetAttack() < bc:GetDefense() then dam=bc:GetDefense() end
	if dam<0 then dam=0 end
	-- 设置伤害对象为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害数值
	Duel.SetTargetParam(dam)
	-- 设置连锁操作信息为造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 执行伤害效果，对指定玩家造成对应数值的伤害
function c22160245.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定数值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
