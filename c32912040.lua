--トラミッド・マスター
-- 效果：
-- ①：1回合1次，把自己场上1张表侧表示的「三形金字塔」卡送去墓地，以场上盖放的1张卡为对象才能发动。那张卡破坏。
-- ②：对方回合1次，以自己场上1张「三形金字塔」场地魔法卡为对象才能发动。那张卡送去墓地，从卡组把和那张卡卡名不同的1张「三形金字塔」场地魔法卡发动。
function c32912040.initial_effect(c)
	-- ①：1回合1次，把自己场上1张表侧表示的「三形金字塔」卡送去墓地，以场上盖放的1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32912040,0))  --"场上盖放的1张卡破坏"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c32912040.descost)
	e1:SetTarget(c32912040.destg)
	e1:SetOperation(c32912040.desop)
	c:RegisterEffect(e1)
	-- ②：对方回合1次，以自己场上1张「三形金字塔」场地魔法卡为对象才能发动。那张卡送去墓地，从卡组把和那张卡卡名不同的1张「三形金字塔」场地魔法卡发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32912040,1))  --"场地魔法卡发动"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCondition(c32912040.condition)
	e2:SetTarget(c32912040.target)
	e2:SetOperation(c32912040.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否满足条件的「三形金字塔」卡
function c32912040.costfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe2) and c:IsAbleToGraveAsCost()
end
-- 效果处理时的费用支付阶段，检查场上是否存在满足条件的卡并选择将其送去墓地
function c32912040.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c32912040.costfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c32912040.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选中的卡送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤函数，用于判断是否为盖放的卡
function c32912040.desfilter(c)
	return c:IsFacedown()
end
-- 效果处理时的目标选择阶段，检查场上是否存在满足条件的卡并选择
function c32912040.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c32912040.desfilter(chkc) end
	-- 检查场上是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingTarget(c32912040.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的卡作为目标
	local g=Duel.SelectTarget(tp,c32912040.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，确定要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理阶段，对目标卡进行破坏
function c32912040.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 对目标卡进行破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤函数，用于判断卡是否为「三形金字塔」场地魔法卡且可发动
function c32912040.filter(c,tp,code)
	return c:IsType(TYPE_FIELD) and c:IsSetCard(0xe2) and c:GetActivateEffect():IsActivatable(tp,true,true) and not c:IsCode(code)
end
-- 效果处理时的发动条件判断，判断是否为对方回合
function c32912040.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为发动者
	return Duel.GetTurnPlayer()~=tp
end
-- 效果处理时的目标选择阶段，检查场上是否存在满足条件的场地魔法卡并选择
function c32912040.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取玩家场上区域的卡
	local tc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	if chkc then return false end
	if chk==0 then return tc and tc:IsFaceup() and tc:IsSetCard(0xe2) and tc:IsAbleToGrave() and tc:IsCanBeEffectTarget(e)
		-- 检查卡组中是否存在满足条件的卡
		and Duel.IsExistingMatchingCard(c32912040.filter,tp,LOCATION_DECK,0,1,nil,tp,tc:GetCode()) end
	-- 设置当前效果的目标卡
	Duel.SetTargetCard(tc)
	-- 设置操作信息，确定要送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,tc,1,0,0)
end
-- 效果处理阶段，将目标卡送去墓地并从卡组选择一张卡发动
function c32912040.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效且已送去墓地
	if tc:IsRelateToEffect(e) and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 then
		-- 提示玩家选择要放置到场上的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 从卡组中选择满足条件的卡
		local g=Duel.SelectMatchingCard(tp,c32912040.filter,tp,LOCATION_DECK,0,1,1,nil,tp,tc:GetCode())
		if g:GetCount()>0 then
			local tc=g:GetFirst()
			-- 将选中的卡放置到场地区域
			Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
			local te=tc:GetActivateEffect()
			te:UseCountLimit(tp,1,true)
			local tep=tc:GetControler()
			local cost=te:GetCost()
			if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
			-- 触发卡的发动时点事件
			Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
		end
	end
end
