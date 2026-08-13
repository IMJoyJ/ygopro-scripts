--E-HERO インフェルノ・ウィング
-- 效果：
-- 「元素英雄 羽翼侠」＋「元素英雄 爆热女郎」
-- 这张卡用「暗黑融合」的效果才能特殊召唤。
-- ①：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ②：这张卡战斗破坏怪兽送去墓地的场合发动。给与对方那只怪兽的原本攻击力和原本守备力之内较高方数值的伤害。
function c22160245.initial_effect(c)
	-- 将卡号94820406「暗黑融合」登记为这张卡上记载的卡名，用于相关效果判定。
	aux.AddCodeList(c,94820406)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：素材为「元素英雄 羽翼侠」与「元素英雄 爆热女郎」，并启用融合素材代用及特定融合流程设定（sub/insf均为true）。
	aux.AddFusionProcCode2(c,58932615,21844576,true,true)
	-- 这张卡用「暗黑融合」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为暗黑融合专用限制，只能通过「暗黑融合」的效果或以暗黑融合类型的融合召唤才能特殊召唤。
	e1:SetValue(aux.DarkFusionLimit)
	c:RegisterEffect(e1)
	-- 这张卡战斗破坏怪兽送去墓地的场合发动。给与对方那只怪兽的原本攻击力和原本守备力之内较高方数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22160245,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置该效果的发动条件：这张卡进行战斗并战斗破坏对方怪兽送去墓地。
	e2:SetCondition(aux.bdgcon)
	e2:SetTarget(c22160245.damtg)
	e2:SetOperation(c22160245.damop)
	c:RegisterEffect(e2)
	-- 这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e3)
end
c22160245.material_setcode=0x8
c22160245.dark_calling=true
-- 伤害效果的目标处理：选择对方玩家为伤害对象，取被战斗破坏怪兽的攻击力与守备力中较高值作为伤害值（负值按0计算），并登记到连锁信息。
function c22160245.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local dam=bc:GetAttack()
	if bc:GetAttack() < bc:GetDefense() then dam=bc:GetDefense() end
	if dam<0 then dam=0 end
	-- 将伤害对象玩家设为对方玩家（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 将计算出的伤害数值作为连锁参数保存，供后续处理使用。
	Duel.SetTargetParam(dam)
	-- 登记操作信息：这是一个对对方玩家造成dam点伤害的效果，不指定对象卡。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 伤害效果的结算：从连锁信息中取出目标玩家和伤害数值，并实际给予伤害。
function c22160245.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中保存的目标玩家和伤害数值，分别赋给p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害的形式给予玩家p数值为d的伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
