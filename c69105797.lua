--捕食植物スキッド・ドロセーラ
-- 效果：
-- ①：把这张卡从手卡送去墓地，以自己场上1只表侧表示怪兽为对象才能发动。这个回合，那只怪兽可以向有捕食指示物放置的对方怪兽全部各作1次攻击。
-- ②：表侧表示的这张卡从场上离开的场合发动。给对方场上的特殊召唤的怪兽全部各放置1个捕食指示物。有捕食指示物放置的2星以上的怪兽的等级变成1星。
function c69105797.initial_effect(c)
	-- ①：把这张卡从手卡送去墓地，以自己场上1只表侧表示怪兽为对象才能发动。这个回合，那只怪兽可以向有捕食指示物放置的对方怪兽全部各作1次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69105797,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c69105797.condition)
	e1:SetCost(c69105797.cost)
	e1:SetTarget(c69105797.target)
	e1:SetOperation(c69105797.operation)
	c:RegisterEffect(e1)
	-- ②：表侧表示的这张卡从场地离开的场合发动。给对方场上的特殊召唤的怪兽全部各放置1个捕食指示物。有捕食指示物放置的2星以上的怪兽的等级变成1星。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c69105797.ccon)
	e2:SetOperation(c69105797.cop)
	c:RegisterEffect(e2)
end
c69105797.mentioned_counter={
	[0x1041]=true,
}
-- ①效果发动条件：自己可以进入战斗阶段
function c69105797.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家当前是否具备进入战斗阶段的条件
	return Duel.IsAbleToEnterBP()
end
-- ①效果发动Cost：把手卡的此卡送去墓地
function c69105797.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将手卡的此卡作为Cost送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- ①效果发动准备：选择自己场上1只表侧表示怪兽为对象
function c69105797.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 发动条件检查：自己场上是否存在表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择1只表侧表示怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ①效果处理：赋予对象怪兽可向所有带捕食指示物的对方怪兽各攻击1次的效果
function c69105797.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，那只怪兽可以向有捕食指示物放置的对方怪兽全部各作1次攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ATTACK_ALL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(c69105797.atkfilter)
		tc:RegisterEffect(e1)
	end
end
-- 连续攻击目标过滤条件：持有捕食指示物的怪兽
function c69105797.atkfilter(e,c)
	return c:GetCounter(0x1041)>0
end
-- ②效果发动条件：此卡从场地离开前为表侧表示
function c69105797.ccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP)
end
-- 放置指示物目标过滤条件：表侧表示且是特殊召唤的怪兽，并且能放置捕食指示物
function c69105797.cfilter(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsCanAddCounter(0x1041,1)
end
-- ②效果处理：给对方场上所有特殊召唤的怪兽各放置1个捕食指示物，并对其中2星以上的怪兽变成1星
function c69105797.cop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上所有特殊召唤且可放置捕食指示物的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c69105797.cfilter,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x1041,1)
		if tc:IsLevelAbove(2) then
			-- 有捕食指示物放置的2星以上的怪兽的等级变成1星。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetCondition(c69105797.lvcon)
			e1:SetValue(1)
			tc:RegisterEffect(e1)
		end
		tc=g:GetNext()
	end
end
-- 变成1星效果的持续条件：该怪兽身上存在捕食指示物
function c69105797.lvcon(e)
	return e:GetHandler():GetCounter(0x1041)>0
end
