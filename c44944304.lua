--EMラフメイカー
-- 效果：
-- ←5 【灵摆】 5→
-- ①：1回合1次，对方场上有持有比原本攻击力高的攻击力的怪兽存在的场合才能发动。自己回复1000基本分。
-- 【怪兽效果】
-- 「娱乐伙伴 逗乐家」的①②的怪兽效果1回合只能有1次使用其中任意1个。
-- ①：这张卡的攻击宣言时才能发动。这张卡的攻击力直到战斗阶段结束时上升这张卡以及对方场上的怪兽之内持有比原本攻击力高的攻击力的怪兽数量×1000。
-- ②：持有比原本攻击力高的攻击力的这张卡被战斗·效果破坏的场合，以自己墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。
function c44944304.initial_effect(c)
	-- 为灵摆怪兽添加灵摆怪兽属性（灵摆召唤，灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，对方场上有持有比原本攻击力高的攻击力的怪兽存在的场合才能发动。自己回复1000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44944304,0))
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1)
	e1:SetCondition(c44944304.rccon)
	e1:SetTarget(c44944304.rctg)
	e1:SetOperation(c44944304.rcop)
	c:RegisterEffect(e1)
	-- ①：这张卡的攻击宣言时才能发动。这张卡的攻击力直到战斗阶段结束时上升这张卡以及对方场上的怪兽之内持有比原本攻击力高的攻击力的怪兽数量×1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44944304,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCountLimit(1,44944304)
	e2:SetCondition(c44944304.atkcon)
	e2:SetOperation(c44944304.atkop)
	c:RegisterEffect(e2)
	-- ②：持有比原本攻击力高的攻击力的这张卡被战斗·效果破坏的场合，以自己墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(44944304,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,44944304)
	e3:SetCondition(c44944304.spcon)
	e3:SetTarget(c44944304.sptg)
	e3:SetOperation(c44944304.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断怪兽是否满足“场上存在攻击力高于原本攻击力的怪兽”的条件
function c44944304.rcfilter(c)
	return c:IsFaceup() and c:GetAttack()>c:GetBaseAttack()
end
-- 判断对方场上是否存在攻击力高于原本攻击力的怪兽
function c44944304.rccon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否存在至少1张满足条件的怪兽
	return Duel.IsExistingMatchingCard(c44944304.rcfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 设置连锁处理的目标玩家和参数，准备执行回复效果
function c44944304.rctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理的目标玩家为当前处理效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁处理的目标参数为1000
	Duel.SetTargetParam(1000)
	-- 设置连锁操作信息，表示将要进行回复效果的处理
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 执行回复效果，使目标玩家回复指定数值的基本分
function c44944304.rcop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行回复效果，使玩家回复指定数值的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
-- 判断当前卡或对方场上是否存在攻击力高于原本攻击力的怪兽
function c44944304.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前卡或对方场上是否存在攻击力高于原本攻击力的怪兽
	return c44944304.rcfilter(e:GetHandler()) or Duel.IsExistingMatchingCard(c44944304.rcfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 计算满足条件的怪兽数量，并为当前卡增加攻击力
function c44944304.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToBattle() or c:IsFacedown() then return end
	-- 获取对方场上满足条件的怪兽数量
	local ct=Duel.GetMatchingGroupCount(c44944304.rcfilter,tp,0,LOCATION_MZONE,nil)
	if c44944304.rcfilter(c) then ct=ct+1 end
	if ct>0 then
		-- 创建一个攻击力提升效果，提升值为满足条件的怪兽数量乘以1000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000*ct)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		c:RegisterEffect(e1)
	end
end
-- 判断该卡是否因战斗或效果破坏且破坏前攻击力高于原本攻击力
function c44944304.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT+REASON_BATTLE) and c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousAttackOnField()>c:GetBaseAttack()
end
-- 过滤函数，用于判断墓地中的怪兽是否可以被特殊召唤
function c44944304.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的目标选择条件
function c44944304.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp)
		and chkc:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 检查是否满足特殊召唤的条件（场上是否有空位）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否满足特殊召唤的条件（墓地是否存在可特殊召唤的怪兽）
		and Duel.IsExistingTarget(c44944304.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标墓地中的怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c44944304.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，表示将要进行特殊召唤的处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤效果，将目标怪兽特殊召唤到场上
function c44944304.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
