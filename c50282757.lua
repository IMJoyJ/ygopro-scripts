--E-HERO ヘル・スナイパー
-- 效果：
-- 「元素英雄 黏土侠」＋「元素英雄 爆热女郎」
-- 这张卡用「暗黑融合」的效果才能特殊召唤。
-- ①：这张卡只要在怪兽区域存在，不会被魔法卡的效果破坏。
-- ②：自己准备阶段发动。给与对方1000伤害。这个效果在这张卡在怪兽区域表侧守备表示存在的场合进行发动和处理。
function c50282757.initial_effect(c)
	-- 将「暗黑融合」（卡号94820406）登记为这张卡上记载的卡名，用于暗黑融合相关规则识别。
	aux.AddCodeList(c,94820406)
	c:EnableReviveLimit()
	-- 为该卡添加融合召唤手续：素材为「元素英雄 黏土侠」和「元素英雄 爆热女郎」，并允许使用融合素材代用品。
	aux.AddFusionProcCode2(c,84327329,58932615,true,true)
	-- 这张卡用「暗黑融合」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件判定函数为DarkFusionLimit：仅当通过「暗黑融合」的效果、暗黑融合特召类型，或受「超融合」等特定效果影响且为融合召唤时，才允许此卡特殊召唤。
	e1:SetValue(aux.DarkFusionLimit)
	c:RegisterEffect(e1)
	-- ②：自己准备阶段发动。给与对方1000伤害。这个效果在这张卡在怪兽区域表侧守备表示存在的场合进行发动和处理。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50282757,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCondition(c50282757.condition)
	e2:SetTarget(c50282757.target)
	e2:SetOperation(c50282757.operation)
	c:RegisterEffect(e2)
	-- ①：这张卡只要在怪兽区域存在，不会被魔法卡的效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(c50282757.indesval)
	c:RegisterEffect(e3)
end
c50282757.material_setcode=0x8
c50282757.dark_calling=true
-- ②效果的发动条件：在自己准备阶段，若此卡在怪兽区域表侧守备表示，则效果满足条件并发动。
function c50282757.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断此卡当前是否处于表侧守备表示，且当前回合玩家是否是其控制者，用于保证②效果只在自己准备阶段且此卡表侧守备表示时发动和处理。
	return e:GetHandler():IsPosition(POS_FACEUP_DEFENSE) and Duel.GetTurnPlayer()==tp
end
-- ②效果的发动目标处理：不选择卡片，发动时将对方玩家设为伤害对象，伤害数值设为1000，并登记伤害操作信息。
function c50282757.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将连锁的对象玩家设为对方玩家（1-tp），作为“给与对方1000伤害”的伤害对象。
	Duel.SetTargetPlayer(1-tp)
	-- 将连锁的对象参数设为1000，表示要造成的伤害数值。
	Duel.SetTargetParam(1000)
	-- 登记操作信息：本连锁将造成CATEGORY_DAMAGE（效果伤害），对象玩家为对方，数值为1000，供其他卡进行连锁判定或无效时参考。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,1-tp,1000)
end
-- ②效果的处理：若此卡仍在场上且未变成里侧表示，则从连锁信息中取出对象玩家和伤害数值，给对方造成1000点效果伤害；否则效果不处理。
function c50282757.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or e:GetHandler():IsFacedown() then return end
	-- 读取当前连锁中设置的对象玩家（CHAININFO_TARGET_PLAYER）和对象参数（CHAININFO_TARGET_PARAM），分别赋给p和d，用于伤害处理。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以“效果”为伤害原因（REASON_EFFECT），对玩家p造成d点（1000）伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 用于①效果的抗性判定：若试图破坏此卡的效果是魔法卡效果（re:IsActiveType(TYPE_SPELL)为真），则返回true，使该魔法卡效果不能将此卡破坏。
function c50282757.indesval(e,re)
	return re:IsActiveType(TYPE_SPELL)
end
