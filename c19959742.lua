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
-- 效果发动条件判断：该卡因卡的效果送去墓地（r含REASON_EFFECT）且自己卡组至少3张，才可发动。
function c19959742.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查诱发原因是否为卡的效果（REASON_EFFECT），并确认自己卡组剩余数量不少于3张，满足发动前提。
	return bit.band(r,REASON_EFFECT)~=0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3
end
-- 效果处理：若自己卡组不足3张则直接结束；否则让玩家确认并排序卡组最上方3张，再选择放回最上面或最下面；若选择最下面，则依次将这3张移到卡组底部。
function c19959742.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己卡组至少还有3张卡，若不满足则效果处理不执行（空发）。
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return end
	-- 让该玩家自由排列自己卡组最上方3张卡片的顺序，决定它们从上到下的先后关系。
	Duel.SortDecktop(tp,tp,3)
	-- 弹出选项让玩家选择确认的3张卡放回卡组最上面还是最下面；选择“回到卡组最下面”（索引1）时执行放回最下面的处理。
	if Duel.SelectOption(tp,aux.Stringid(19959742,1),aux.Stringid(19959742,2))==1 then  --"回到卡组最上面/回到卡组最下面"
		for i=1,3 do
			-- 取得当前卡组最上方的一张卡，作为接下来要移动的对象（每轮循环取一张）。
			local mg=Duel.GetDecktopGroup(tp,1)
			-- 把这张卡移动到卡组最底端；循环3次后，确认过的3张卡便全部按顺序被放到卡组最下面。
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end
