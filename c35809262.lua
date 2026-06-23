--E・HERO フレイム・ウィングマン
-- 效果：
-- 「元素英雄 羽翼侠」＋「元素英雄 爆热女郎」
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：这张卡战斗破坏怪兽送去墓地的场合发动。给与对方那只怪兽的原本攻击力数值的伤害。
function c35809262.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为21844576和58932615的2只怪兽为融合素材
	aux.AddFusionProcCode2(c,21844576,58932615,true,true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该效果为融合召唤的特殊召唤条件
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
-- 判断战斗中攻击的怪兽是否在场且被破坏送入墓地且为怪兽卡
function c35809262.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
-- 设置连锁处理时的目标卡片、目标玩家和伤害值
function c35809262.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetHandler():GetBattleTarget()
	-- 设置当前连锁处理的目标卡片为战斗破坏的怪兽
	Duel.SetTargetCard(bc)
	local dam=bc:GetAttack()
	if dam<0 then dam=0 end
	-- 设置当前连锁处理的目标玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁处理的目标参数为伤害值
	Duel.SetTargetParam(dam)
	-- 设置当前连锁的操作信息为伤害效果，目标玩家为对方，伤害值为破坏怪兽的攻击力
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 执行伤害效果，对目标玩家造成对应伤害
function c35809262.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 获取当前连锁处理的目标玩家
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		local dam=tc:GetAttack()
		if dam<0 then dam=0 end
		-- 以效果原因对目标玩家造成对应伤害值
		Duel.Damage(p,dam,REASON_EFFECT)
	end
end
