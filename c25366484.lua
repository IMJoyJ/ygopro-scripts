--E・HERO シャイニング・フレア・ウィングマン
-- 效果：
-- 「元素英雄 火焰翼侠」＋「元素英雄 电光侠」
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：这张卡的攻击力上升自己墓地的「元素英雄」卡数量×300。
-- ②：这张卡战斗破坏怪兽送去墓地的场合发动。给与对方那只怪兽的原本攻击力数值的伤害。
function c25366484.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为35809262和20721928的2只怪兽为融合素材
	aux.AddFusionProcCode2(c,35809262,20721928,true,true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该效果为融合召唤的特殊召唤条件
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏怪兽送去墓地的场合发动。给与对方那只怪兽的原本攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25366484,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置效果触发条件为战斗破坏对方怪兽并送入墓地
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
-- 设置伤害效果的目标卡片为战斗破坏的怪兽
function c25366484.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetHandler():GetBattleTarget()
	-- 将战斗破坏的怪兽设置为连锁处理的对象卡片
	Duel.SetTargetCard(bc)
	local dam=bc:GetAttack()
	if dam<0 then dam=0 end
	-- 将对方玩家设置为连锁处理的对象玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将伤害值设置为连锁处理的对象参数
	Duel.SetTargetParam(dam)
	-- 设置连锁操作信息为伤害效果，对象为对方玩家，伤害值为怪兽攻击力
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 执行伤害效果，对目标玩家造成对应伤害
function c25366484.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁处理的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 从连锁信息中获取目标玩家
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		local dam=tc:GetAttack()
		if dam<0 then dam=0 end
		-- 对目标玩家造成指定数值的伤害
		Duel.Damage(p,dam,REASON_EFFECT)
	end
end
-- 计算墓地「元素英雄」卡数量并乘以300作为攻击力提升值
function c25366484.atkup(e,c)
	-- 统计自己墓地中「元素英雄」卡的数量并乘以300
	return Duel.GetMatchingGroupCount(Card.IsSetCard,c:GetControler(),LOCATION_GRAVE,0,nil,0x3008)*300
end
