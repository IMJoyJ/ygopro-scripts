--E・HERO シャイニング・フレア・ウィングマン
-- 效果：
-- 「元素英雄 火焰翼侠」＋「元素英雄 电光侠」
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：这张卡的攻击力上升自己墓地的「元素英雄」卡数量×300。
-- ②：这张卡战斗破坏怪兽送去墓地的场合发动。给与对方那只怪兽的原本攻击力数值的伤害。
function c25366484.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以「元素英雄 火焰翼侠」（编号35809262）和「元素英雄 电光侠」（编号20721928）作为融合素材，允许使用融合素材代用品。
	aux.AddFusionProcCode2(c,35809262,20721928,true,true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将该特殊召唤限制效果的值设为“仅允许融合召唤”，使此卡只能通过融合召唤特殊召唤。
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏怪兽送去墓地的场合发动。给与对方那只怪兽的原本攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25366484,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置②效果的发动条件：此卡与战斗相关，且战斗对象被战斗破坏送去墓地，并且是怪兽。
	e2:SetCondition(aux.bdgcon)
	e2:SetTarget(c25366484.damtg)
	e2:SetOperation(c25366484.damop)
	c:RegisterEffect(e2)
	-- ①：这张卡的攻击力上升自己墓地的「元素英雄」卡数量×300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(c25366484.atkup)
	c:RegisterEffect(e3)
end
c25366484.material_setcode=0x8
-- 定义②效果的Target函数：效果发动时，无条件允许发动；将被战斗破坏的怪兽设为对象，将对方设为承受伤害的玩家，并记录该怪兽的攻击力（若为负则视为0）作为伤害值，同时声明伤害操作信息。
function c25366484.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetHandler():GetBattleTarget()
	-- 将被战斗破坏的那只怪兽登记为当前连锁的对象，供后续效果处理时引用。
	Duel.SetTargetCard(bc)
	local dam=bc:GetAttack()
	if dam<0 then dam=0 end
	-- 将效果的对象玩家设置为对方（tp为发动者，1-tp为对手），即伤害的承受者。
	Duel.SetTargetPlayer(1-tp)
	-- 将伤害数值保存为效果的对象参数，供后续取用。
	Duel.SetTargetParam(dam)
	-- 设置当前连锁的操作信息：声明本效果将向对方玩家造成dam点伤害，以便其他卡片进行对应。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 定义②效果的Operation函数：效果处理时，取得对象怪兽；若该怪兽仍与效果关联，则读取对象玩家，按该怪兽的攻击力（若为负则视为0）对对方造成效果伤害。
function c25366484.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得Target阶段设定的对象卡（即被战斗破坏的怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 从当前连锁信息中取得对象玩家，即本次伤害的承受者。
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		local dam=tc:GetAttack()
		if dam<0 then dam=0 end
		-- 以效果原因向玩家p造成dam点伤害。
		Duel.Damage(p,dam,REASON_EFFECT)
	end
end
-- 定义①效果的攻击力上升值计算函数：查看控制者墓地中「元素英雄」卡的数量并乘以300，作为永续攻击力加成。
function c25366484.atkup(e,c)
	-- 统计控制者墓地中满足「元素英雄」字段（setcode 0x3008）的卡的数量，乘以300作为攻击力增加值。
	return Duel.GetMatchingGroupCount(Card.IsSetCard,c:GetControler(),LOCATION_GRAVE,0,nil,0x3008)*300
end
