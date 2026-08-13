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
-- 定义①效果的cost筛选函数：要求卡为表侧表示、是「三形金字塔」卡且可作为代价送去墓地。
function c32912040.costfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe2) and c:IsAbleToGraveAsCost()
end
-- ①效果的cost处理：检测并选择1张满足costfilter的卡，将其作为代价送去墓地。
function c32912040.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在1张表侧表示且可作为cost送去墓地的「三形金字塔」卡，以决定cost是否满足。
	if chk==0 then return Duel.IsExistingMatchingCard(c32912040.costfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 给玩家显示“请选择要送去墓地的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择1张满足costfilter的卡，作为发动①效果的代价。
	local g=Duel.SelectMatchingCard(tp,c32912040.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选择的那张卡以代价（REASON_COST）送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义①效果的取对象筛选函数：对象必须是里侧表示的卡。
function c32912040.desfilter(c)
	return c:IsFacedown()
end
-- ①效果的目标处理：选择场上1张里侧表示的卡作为对象，并设置将破坏该卡的操作信息。
function c32912040.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c32912040.desfilter(chkc) end
	-- 检查场上是否存在1张里侧表示的卡可以作为①效果的对象。
	if chk==0 then return Duel.IsExistingTarget(c32912040.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 给玩家显示“请选择要破坏的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择1张场上里侧表示的卡，并设定为效果对象。
	local g=Duel.SelectTarget(tp,c32912040.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，表示本次效果将破坏1张卡（CATEGORY_DESTROY）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①效果处理：取得对象卡，若仍与效果关联则将其破坏。
function c32912040.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时锁定的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 用效果（REASON_EFFECT）破坏对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 定义②效果的卡组筛选函数：要求是「三形金字塔」场地魔法卡、卡名与对象不同、且其场地魔法卡发动效果当前可以被发动。
function c32912040.filter(c,tp,code)
	return c:IsType(TYPE_FIELD) and c:IsSetCard(0xe2) and c:GetActivateEffect():IsActivatable(tp,true,true) and not c:IsCode(code)
end
-- ②效果的发动条件：仅在对方回合才能发动。
function c32912040.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家不是自己，即满足“对方回合”的条件。
	return Duel.GetTurnPlayer()~=tp
end
-- ②效果的目标处理：取自己场上1张表侧表示的「三形金字塔」场地魔法卡为对象，同时确认卡组中存在可发动的不同卡名场地魔法卡。
function c32912040.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己场地区域（LOCATION_FZONE）中的场地魔法卡。
	local tc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	if chkc then return false end
	if chk==0 then return tc and tc:IsFaceup() and tc:IsSetCard(0xe2) and tc:IsAbleToGrave() and tc:IsCanBeEffectTarget(e)
		-- 检查卡组中是否存在1张满足filter条件（不同卡名且可发动）的「三形金字塔」场地魔法卡。
		and Duel.IsExistingMatchingCard(c32912040.filter,tp,LOCATION_DECK,0,1,nil,tp,tc:GetCode()) end
	-- 将选中的场地魔法卡设置为当前连锁的对象（取对象）。
	Duel.SetTargetCard(tc)
	-- 设置操作信息，表示将把对象卡送去墓地（CATEGORY_TOGRAVE）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,tc,1,0,0)
end
-- ②效果处理：将对象场地魔法卡送去墓地，若成功则从卡组选1张不同卡名的「三形金字塔」场地魔法卡发动到场上。
function c32912040.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时锁定的对象卡（那张场地魔法卡）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与效果关联，并且将其送去墓地成功，才继续后续处理。
	if tc:IsRelateToEffect(e) and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 then
		-- 给玩家显示“请选择要放置到场上的卡”的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 从卡组选择1张满足filter条件的「三形金字塔」场地魔法卡。
		local g=Duel.SelectMatchingCard(tp,c32912040.filter,tp,LOCATION_DECK,0,1,1,nil,tp,tc:GetCode())
		if g:GetCount()>0 then
			local tc=g:GetFirst()
			-- 将选中的卡以表侧表示放置到自己的场地区域，并使其效果适用。
			Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
			local te=tc:GetActivateEffect()
			te:UseCountLimit(tp,1,true)
			local tep=tc:GetControler()
			local cost=te:GetCost()
			if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
			-- 触发该卡的发动时点（EVENT_CHAINING），完成场地魔法卡的发动处理。
			Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
		end
	end
end
