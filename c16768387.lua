--大王目玉
-- 效果：
-- 反转：从自己卡组上面把最多5张卡确认，用喜欢的顺序回到卡组上面。
function c16768387.initial_effect(c)
	-- 反转：从自己卡组上面把最多5张卡确认，用喜欢的顺序回到卡组上面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16768387,0))  --"确认卡组"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetOperation(c16768387.operation)
	c:RegisterEffect(e1)
end
-- 执行反转效果：计算自己卡组上方最多5张卡作为可确认范围；若卡组有卡，则让玩家选择要确认的卡数，并将该数量的卡组顶卡按玩家喜欢的顺序放回卡组上面。
function c16768387.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组上方的卡数，并以5为上限计算本次可确认的卡片数量。
	local ct=math.min(5,Duel.GetFieldGroupCount(tp,LOCATION_DECK,0))
	if ct==0 then return end
	local t={}
	for i=1,ct do
		t[i]=i
	end
	local ac=1
	if ct>1 then
		-- 向操作玩家发出选择提示，显示“请选择要确认的卡的数量”。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(16768387,1))  --"请选择要确认的卡的数量"
		-- 让玩家从1到可确认上限之间宣言一个数字，作为实际要确认并排序的卡牌数量。
		ac=Duel.AnnounceNumber(tp,table.unpack(t))
	end
	-- 让玩家对自己卡组最上方ac张卡进行排序，按喜欢的顺序放回卡组上面。
	Duel.SortDecktop(tp,tp,ac)
end
