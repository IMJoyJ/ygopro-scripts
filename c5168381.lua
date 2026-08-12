--悪魔の技
-- 效果：
-- ①：自己场上有恶魔族怪兽存在的场合，以场上1张卡为对象才能发动。那张卡破坏。那之后，可以从卡组把1只恶魔族怪兽送去墓地。
function c5168381.initial_effect(c)
	-- 效果定义：恶魔之技的发动条件和处理流程
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c5168381.condition)
	e1:SetTarget(c5168381.target)
	e1:SetOperation(c5168381.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断怪兽是否为恶魔族且表侧表示
function c5168381.cfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsFaceup()
end
-- 发动条件：检查自己场上是否存在恶魔族怪兽
function c5168381.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张可作为对象的卡
	return Duel.IsExistingMatchingCard(c5168381.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 选择目标：选择场上1张卡作为破坏对象
function c5168381.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
	-- 判断是否满足发动条件：确认场上存在目标卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置操作信息：记录将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 过滤函数：判断卡是否为恶魔族且能送去墓地
function c5168381.tgfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsAbleToGrave()
end
-- 效果处理：执行破坏和从卡组送墓地的操作
function c5168381.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 检索满足条件的恶魔族怪兽
	local g=Duel.GetMatchingGroup(c5168381.tgfilter,tp,LOCATION_DECK,0,nil)
	-- 确认目标卡有效且已成功破坏，且卡组有可用怪兽
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 and g:GetCount()>0
		-- 询问玩家是否将1只恶魔族怪兽送去墓地
		and Duel.SelectYesNo(tp,aux.Stringid(5168381,0)) then  --"是否从卡组把1只恶魔族怪兽送去墓地？"
		-- 中断当前效果处理，使后续处理不同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的恶魔族怪兽送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
