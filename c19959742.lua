--リチュア・シェルフィッシュ
-- 效果：
-- 这张卡被卡的效果送去墓地时，从自己卡组上面把3张卡确认，确认的3张用喜欢的顺序回到卡组上面或下面。
function c19959742.initial_effect(c)
	-- 这张卡被卡的效果送去墓地时，从自己卡组上面把3张卡确认，确认的3张用喜欢的顺序回到卡组上面或下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19959742,0))  --"卡组确认"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c19959742.condition)
	e1:SetOperation(c19959742.operation)
	c:RegisterEffect(e1)
end
-- 效果作用
function c19959742.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 满足条件：因效果送入墓地且自己卡组至少有3张牌
	return bit.band(r,REASON_EFFECT)~=0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3
end
-- 效果作用
function c19959742.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己卡组少于3张牌则不执行后续操作
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return end
	-- 将自己卡组最上方的3张牌进行排序
	Duel.SortDecktop(tp,tp,3)
	-- 选择将排序后的牌放回卡组顶部或底部
	if Duel.SelectOption(tp,aux.Stringid(19959742,1),aux.Stringid(19959742,2))==1 then  --"回到卡组最上面/回到卡组最下面"
		for i=1,3 do
			-- 获取卡组最上方的1张牌
			local mg=Duel.GetDecktopGroup(tp,1)
			-- 将该牌移动到卡组底部
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end
