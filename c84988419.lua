--幻奏の華歌聖ブルーム・ディーヴァ
-- 效果：
-- 「幻奏的音姬」怪兽＋「幻奏」怪兽
-- ①：这张卡不会被战斗·效果破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
-- ②：这张卡和特殊召唤的怪兽进行战斗的伤害计算后才能发动。给与对方那只对方怪兽和这张卡的原本攻击力差的数值的伤害，那只对方怪兽破坏。
function c84988419.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合素材为「幻奏的音姬」怪兽和「幻奏」怪兽，并允许用作替代素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x109b),aux.FilterBoolFunction(Card.IsFusionSetCard,0x9b),true)
	-- ①：这张卡不会被战斗·效果破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	c:RegisterEffect(e3)
	-- ②：这张卡和特殊召唤的怪兽进行战斗的伤害计算后才能发动。给与对方那只对方怪兽和这张卡的原本攻击力差的数值的伤害，那只对方怪兽破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLED)
	e4:SetCondition(c84988419.condition)
	e4:SetTarget(c84988419.target)
	e4:SetOperation(c84988419.operation)
	c:RegisterEffect(e4)
end
-- 效果②的发动条件：这张卡与特殊召唤的怪兽进行战斗，且双方原本攻击力不相等
function c84988419.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsSummonType(SUMMON_TYPE_SPECIAL) and c:GetBaseAttack()~=bc:GetBaseAttack()
end
-- 效果②的发动准备：确认战斗对象是否仍在场，计算原本攻击力差值，将战斗对象设为效果目标，并注册伤害和破坏的操作信息
function c84988419.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return bc:IsRelateToBattle() end
	local atk=math.abs(e:GetHandler():GetBaseAttack()-bc:GetBaseAttack())
	-- 将进行战斗的对方怪兽设为效果处理的对象
	Duel.SetTargetCard(bc)
	-- 设置给与对方原本攻击力差值数值伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
	-- 设置破坏该对方怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
-- 效果②的效果处理：获取目标怪兽并计算原本攻击力差值，若目标怪兽仍在场且表侧表示，则给与对方该差值的伤害，伤害成功后将其破坏
function c84988419.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时设为效果目标的对方怪兽
	local bc=Duel.GetFirstTarget()
	local atk=math.abs(e:GetHandler():GetBaseAttack()-bc:GetBaseAttack())
	-- 确认目标怪兽是否仍受此效果影响且表侧表示，并给与对方原本攻击力差值的伤害，若伤害成功则继续执行
	if bc:IsRelateToEffect(e) and bc:IsFaceup() and Duel.Damage(1-tp,atk,REASON_EFFECT)~=0 then
		-- 用效果破坏该对方怪兽
		Duel.Destroy(bc,REASON_EFFECT)
	end
end
