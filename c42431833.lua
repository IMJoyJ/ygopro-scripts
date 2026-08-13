--スプライト・ガンマ・バースト
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：场上的全部2星·2阶·连接2的怪兽的攻击力·守备力直到回合结束时上升1400。
-- ②：自己主要阶段把墓地的这张卡除外，以自己场上1只2星·2阶·连接2的怪兽为对象才能发动。那只怪兽的攻击力直到对方回合结束时上升1400。
function c42431833.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：场上的全部2星·2阶·连接2的怪兽的攻击力·守备力直到回合结束时上升1400。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,42431833)
	-- 设置①效果的发动条件为aux.dscon：在伤害步骤内只允许伤害计算前发动，非伤害步骤不受限制。
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
	-- 设置②效果的发动COST为把墓地中的这张卡除外（由aux.bfgcost实现），发动前需先支付这一代价。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c42431833.atktg)
	e2:SetOperation(c42431833.atkop)
	c:RegisterEffect(e2)
end
-- 定义通用过滤条件：怪兽须表侧表示，且等级为2、阶级为2或连接标记为2，用于①效果中选定全场符合条件的怪兽。
function c42431833.filter(c)
	return (c:IsLevel(2) or c:IsRank(2) or c:IsLink(2)) and c:IsFaceup()
end
-- target函数用于①效果的发动合法性判定：效果发动前检查双方场上是否存在至少1只满足filter的2星/2阶/连接2表侧表示怪兽，存在才可发动。
function c42431833.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：若双方场上合计存在至少1只满足filter的怪兽，则返回true，允许①效果发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c42431833.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- ①效果处理：取得双方场上所有满足filter的怪兽，逐只赋予攻击力和守备力上升1400，持续到回合结束。
function c42431833.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上所有满足filter（2星/2阶/连接2且表侧表示）的怪兽组，作为本次攻击力·守备力上升的适用对象。
	local g=Duel.GetMatchingGroup(c42431833.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 攻击力·守备力直到回合结束时上升1400（此处实现攻击力上升部分）。
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
-- 定义②效果的对象过滤条件：表侧表示且等级2/阶级2/连接2的怪兽，用于在己方场上选择对象。
function c42431833.atkfilter(c)
	return (c:IsLevel(2) or c:IsRank(2) or c:IsLink(2)) and c:IsFaceup()
end
-- ②效果的target函数：先处理chkc合法性（对象需在自己场上且符合atkfilter），再在发动时检查己方场上是否存在可选对象；随后发送选择提示并指定1只怪兽为对象。
function c42431833.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c42431833.atkfilter(chkc) end
	-- 发动合法性检查：己方场上是否存在至少1只可以成为效果对象的表侧表示2星/2阶/连接2怪兽；若不存在则②效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(c42431833.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向当前玩家写入选择对象的提示信息（HINTMSG_TARGET），使后续Duel.SelectTarget时显示“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让己方从自己场上选择1只符合atkfilter的怪兽作为②效果的对象，并与当前连锁建立对象联系，供处理时取得。
	Duel.SelectTarget(tp,c42431833.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果处理：取得发动时选择的对象，确认其仍与效果相关且表侧表示后，赋予其攻击力上升1400，直到对方回合结束。
function c42431833.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁已选择的首个对象卡，即②效果发动时选中的那只怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力直到对方回合结束时上升1400。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e1)
	end
end
