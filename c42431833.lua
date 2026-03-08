--スプライト・ガンマ・バースト
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：场上的全部2星·2阶·连接2的怪兽的攻击力·守备力直到回合结束时上升1400。
-- ②：自己主要阶段把墓地的这张卡除外，以自己场上1只2星·2阶·连接2的怪兽为对象才能发动。那只怪兽的攻击力直到对方回合结束时上升1400。
function c42431833.initial_effect(c)
	-- ①：场上的全部2星·2阶·连接2的怪兽的攻击力·守备力直到回合结束时上升1400。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,42431833)
	-- 限制效果只能在伤害计算前的时机发动或适用
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c42431833.target)
	e1:SetOperation(c42431833.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以自己场上1只2星·2阶·连接2的怪兽为对象才能发动。那只怪兽的攻击力直到对方回合结束时上升1400。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,42431833)
	-- 把这张卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c42431833.atktg)
	e2:SetOperation(c42431833.atkop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选2星·2阶·连接2且表侧表示的怪兽
function c42431833.filter(c)
	return (c:IsLevel(2) or c:IsRank(2) or c:IsLink(2)) and c:IsFaceup()
end
-- 判断是否满足效果发动条件，即场上是否存在满足条件的怪兽
function c42431833.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足效果发动条件，即场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c42431833.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- 检索满足条件的怪兽组并为它们增加攻击力和守备力
function c42431833.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检索满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c42431833.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 为对象怪兽增加攻击力
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
-- 过滤函数，用于筛选2星·2阶·连接2且表侧表示的怪兽
function c42431833.atkfilter(c)
	return (c:IsLevel(2) or c:IsRank(2) or c:IsLink(2)) and c:IsFaceup()
end
-- 设置效果目标选择函数，用于选择满足条件的怪兽
function c42431833.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c42431833.atkfilter(chkc) end
	-- 判断是否满足效果发动条件，即场上是否存在满足条件的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c42431833.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c42431833.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 处理效果的发动，为对象怪兽增加攻击力
function c42431833.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 为对象怪兽增加攻击力
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e1)
	end
end
