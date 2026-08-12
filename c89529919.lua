--戦士ラーズ
-- 效果：
-- 这张卡召唤·特殊召唤成功时，从自己卡组选择「战士 拉兹」以外的1只4星以下的战士族怪兽在卡组最上面放置。
function c89529919.initial_effect(c)
	-- 这张卡召唤·特殊召唤成功时，从自己卡组选择「战士 拉兹」以外的1只4星以下的战士族怪兽在卡组最上面放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89529919,0))  --"检索"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c89529919.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤卡组中等级4以下、战士族且卡名不是「战士 拉兹」的怪兽
function c89529919.filter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_WARRIOR) and not c:IsCode(89529919)
end
-- 效果处理：洗切卡组，并将从卡组选择的1只4星以下战士族怪兽放置在卡组最上面
function c89529919.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示消息，要求选择要在卡组最上面放置的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(89529919,1))  --"请选择要在卡组最上面放置的卡"
	-- 从卡组中选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c89529919.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 洗切玩家的卡组
		Duel.ShuffleDeck(tp)
		-- 将选中的怪兽移动到卡组最上面
		Duel.MoveSequence(tc,SEQ_DECKTOP)
		-- 确认玩家卡组最上面的一张卡
		Duel.ConfirmDecktop(tp,1)
	end
end
