--E・HERO フレイム・ウィングマン
-- 效果：
-- 「元素英雄 羽翼侠」＋「元素英雄 爆热女郎」
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：这张卡战斗破坏怪兽送去墓地的场合发动。给与对方那只怪兽的原本攻击力数值的伤害。
function c35809262.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续，以「元素英雄 羽翼侠」（21844576）和「元素英雄 爆热女郎」（58932615）作为融合素材，并允许使用融合素材代用品等条件。
	aux.AddFusionProcCode2(c,21844576,58932615,true,true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件判定函数为aux.fuslimit，使该卡只允许通过融合召唤方式特殊召唤。
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ①：这张卡战斗破坏怪兽送去墓地的场合发动。给与对方那只怪兽的原本攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35809262,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c35809262.damcon)
	e2:SetTarget(c35809262.damtg)
	e2:SetOperation(c35809262.damop)
	c:RegisterEffect(e2)
end
c35809262.material_setcode=0x8
-- 伤害效果的发动条件判定：此卡与战斗对象怪兽进行战斗并破坏该怪兽、将其作为怪兽卡送入墓地，且此卡仍与本次战斗关联时才满足发动条件。
function c35809262.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
-- 伤害效果的目标设定：将战斗破坏的怪兽设置为效果对象，并记录对方玩家与应造成的伤害数值（取该怪兽的攻击力，若为负数则按0计算）。
function c35809262.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetHandler():GetBattleTarget()
	-- 将战斗破坏的那只怪兽设为当前连锁的效果对象，供后续效果处理时获取。
	Duel.SetTargetCard(bc)
	local dam=bc:GetAttack()
	if dam<0 then dam=0 end
	-- 将效果的对象玩家设为对方玩家（1-tp），表示伤害给予的对象。
	Duel.SetTargetPlayer(1-tp)
	-- 将效果的对象参数设为伤害数值dam，存储本次待造成的伤害值。
	Duel.SetTargetParam(dam)
	-- 设置操作信息，声明本次连锁包含对对方造成dam点伤害的效果，用于连锁判定和相关卡片的响应。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 伤害效果处理：从效果对象中取出被战斗破坏的那只怪兽，确认其仍与效果关联后，向对方玩家造成该怪兽攻击力数值的伤害，若攻击力为负数则按0计算。
function c35809262.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁记录的第一个效果对象卡片，即被战斗破坏的那只怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 获取当前连锁中记录的目标玩家，即本次伤害要给予的对方玩家。
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		local dam=tc:GetAttack()
		if dam<0 then dam=0 end
		-- 以效果原因（REASON_EFFECT）向玩家p造成dam点伤害，完成效果结算。
		Duel.Damage(p,dam,REASON_EFFECT)
	end
end
