--E-HERO ヘル・スナイパー
-- 效果：
-- 「元素英雄 黏土侠」＋「元素英雄 爆热女郎」
-- 这张卡用「暗黑融合」的效果才能特殊召唤。
-- ①：这张卡只要在怪兽区域存在，不会被魔法卡的效果破坏。
-- ②：自己准备阶段发动。给与对方1000伤害。这个效果在这张卡在怪兽区域表侧守备表示存在的场合进行发动和处理。
function c50282757.initial_effect(c)
	-- 记录此卡可以通过「暗黑融合」进行特殊召唤
	aux.AddCodeList(c,94820406)
	c:EnableReviveLimit()
	-- 设置融合召唤所需的两只融合素材怪兽为「元素英雄 黏土侠」和「元素英雄 爆热女郎」
	aux.AddFusionProcCode2(c,84327329,58932615,true,true)
	-- ①：这张卡只要在怪兽区域存在，不会被魔法卡的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为必须通过「暗黑融合」或「暗黑神召」进行
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
-- 判断是否满足效果发动条件：此卡必须为表侧守备表示且当前为自己的准备阶段
function c50282757.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 此卡必须为表侧守备表示且当前为自己的准备阶段
	return e:GetHandler():IsPosition(POS_FACEUP_DEFENSE) and Duel.GetTurnPlayer()==tp
end
-- 设置效果处理时的目标和参数信息
function c50282757.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设定伤害对象为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设定伤害值为1000
	Duel.SetTargetParam(1000)
	-- 设置连锁操作信息，指定将造成1000点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,1-tp,1000)
end
-- 执行伤害效果处理流程
function c50282757.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or e:GetHandler():IsFacedown() then return end
	-- 获取连锁中设定的目标玩家和参数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定数值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 判断是否为魔法卡的效果，若是则此卡不会被该效果破坏
function c50282757.indesval(e,re)
	return re:IsActiveType(TYPE_SPELL)
end
