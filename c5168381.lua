--悪魔の技
-- 效果：
-- ①：自己场上有恶魔族怪兽存在的场合，以场上1张卡为对象才能发动。那张卡破坏。那之后，可以从卡组把1只恶魔族怪兽送去墓地。
function c5168381.initial_effect(c)
	-- ①：自己场上有恶魔族怪兽存在的场合，以场上1张卡为对象才能发动。那张卡破坏。那之后，可以从卡组把1只恶魔族怪兽送去墓地。
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
-- 过滤器：判断怪兽是否为表侧表示的恶魔族。
function c5168381.cfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsFaceup()
end
-- 效果的发动条件：检查自己场上是否存在至少1只表侧表示的恶魔族怪兽。
function c5168381.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的恶魔族怪兽。
	return Duel.IsExistingMatchingCard(c5168381.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 发动时的目标选择处理：从场上选择1张除发动卡以外的卡作为对象，并设置破坏的操作信息。
function c5168381.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
	-- 发动确认：场上是否存在除自身以外的可选对象。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为效果对象（不能选择自身），并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置本次连锁的破坏操作信息，用于后续效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 过滤器：判断卡组中的怪兽是否为恶魔族且可以被送去墓地。
function c5168381.tgfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsAbleToGrave()
end
-- 效果处理：破坏对象卡，若破坏成功且卡组存在可送墓的恶魔族，则询问是否将1只恶魔族怪兽送去墓地。
function c5168381.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 获取卡组中所有满足条件的恶魔族怪兽。
	local g=Duel.GetMatchingGroup(c5168381.tgfilter,tp,LOCATION_DECK,0,nil)
	-- 判断对象卡仍与效果关联且被效果破坏成功，且卡组中有可送墓的恶魔族怪兽。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 and g:GetCount()>0
		-- 询问玩家是否从卡组把1只恶魔族怪兽送去墓地。
		and Duel.SelectYesNo(tp,aux.Stringid(5168381,0)) then  --"是否从卡组把1只恶魔族怪兽送去墓地？"
		-- 中断当前效果处理，使后续操作视为不同时处理，避免错时点。
		Duel.BreakEffect()
		-- 提示玩家选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择的卡送去墓地。
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
