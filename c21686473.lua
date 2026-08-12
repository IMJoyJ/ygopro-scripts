--DDD運命王ゼロ・ラプラス
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。从自己的额外卡组选「DDD 命运王 零·拉普拉斯」以外的1只表侧表示的「DDD」灵摆怪兽加入手卡。
-- 【怪兽效果】
-- ①：这张卡可以把自己场上1只「DDD」怪兽解放从手卡特殊召唤。
-- ②：这张卡和对方怪兽进行战斗的伤害计算前才能发动。这张卡的攻击力直到伤害步骤结束时变成那只对方怪兽的原本攻击力的2倍。
-- ③：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ④：这张卡1回合只有1次不会被战斗破坏。那个时候，自己受到的战斗伤害变成0。
function c21686473.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，允许灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：自己主要阶段才能发动。从自己的额外卡组选「DDD 命运王 零·拉普拉斯」以外的1只表侧表示的「DDD」灵摆怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21686473,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,21686473)
	e1:SetTarget(c21686473.thtg)
	e1:SetOperation(c21686473.thop)
	c:RegisterEffect(e1)
	-- ①：这张卡可以把自己场上1只「DDD」怪兽解放从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c21686473.hspcon)
	e2:SetTarget(c21686473.hsptg)
	e2:SetOperation(c21686473.hspop)
	c:RegisterEffect(e2)
	-- ②：这张卡和对方怪兽进行战斗的伤害计算前才能发动。这张卡的攻击力直到伤害步骤结束时变成那只对方怪兽的原本攻击力的2倍。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(21686473,0))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_CONFIRM)
	e3:SetCondition(c21686473.atkcon)
	e3:SetOperation(c21686473.atkop)
	c:RegisterEffect(e3)
	-- ③：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e4)
	-- ④：这张卡1回合只有1次不会被战斗破坏。那个时候，自己受到的战斗伤害变成0。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e5:SetCountLimit(1)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(c21686473.valcon)
	c:RegisterEffect(e5)
	-- ④：这张卡1回合只有1次不会被战斗破坏。那个时候，自己受到的战斗伤害变成0。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e6:SetValue(c21686473.damlimit)
	c:RegisterEffect(e6)
end
-- 定义灵摆效果中用于筛选额外卡组中符合条件的「DDD」灵摆怪兽的过滤函数
function c21686473.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10af) and c:IsType(TYPE_PENDULUM) and not c:IsCode(21686473) and c:IsAbleToHand()
end
-- 设置灵摆效果的目标为从额外卡组选择一张符合条件的怪兽加入手牌
function c21686473.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足灵摆效果发动条件，即在额外卡组中是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c21686473.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁操作信息，表示该效果将把一张卡从额外卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 执行灵摆效果的操作，选择并把符合条件的怪兽加入手牌
function c21686473.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从额外卡组中选择一张符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c21686473.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义特殊召唤效果中用于筛选可解放的「DDD」怪兽的过滤函数
function c21686473.hspfilter(c,tp)
	return c:IsSetCard(0x10af)
		-- 检查所选怪兽是否满足特殊召唤的解放条件，包括是否在自己场上或表侧表示
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 判断特殊召唤效果是否满足发动条件，即是否有可解放的「DDD」怪兽
function c21686473.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查场上是否存在满足特殊召唤条件的怪兽
	return Duel.CheckReleaseGroupEx(tp,c21686473.hspfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 设置特殊召唤效果的目标选择操作，选择要解放的怪兽
function c21686473.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取可解放的怪兽组并筛选出符合条件的怪兽
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c21686473.hspfilter,nil,tp)
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤效果的操作，解放选中的怪兽
function c21686473.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽解放
	Duel.Release(g,REASON_SPSUMMON)
end
-- 判断战斗伤害计算前效果是否满足发动条件
function c21686473.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc and bc:IsFaceup() and bc:IsRelateToBattle() and bc:GetBaseAttack()*2~=c:GetAttack()
end
-- 执行战斗伤害计算前的效果，将攻击力设置为对方怪兽原本攻击力的2倍
function c21686473.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if c:IsFaceup() and c:IsRelateToBattle() and bc:IsFaceup() and bc:IsRelateToBattle() then
		-- 设置攻击力变为对方怪兽原本攻击力的2倍的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(bc:GetBaseAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_DAMAGE)
		c:RegisterEffect(e1)
	end
end
-- 判断该卡是否在战斗中被破坏，用于控制一回合一次的不被破坏效果
function c21686473.valcon(e,re,r,rp)
	if bit.band(r,REASON_BATTLE)~=0 then
		e:GetHandler():RegisterFlagEffect(21686473,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		return true
	else return false end
end
-- 判断是否触发避免战斗伤害的效果，即是否为第一次受到战斗伤害
function c21686473.damlimit(e,c)
	if e:GetHandler():GetFlagEffect(21686473)==0 then
		return 1
	else return 0 end
end
