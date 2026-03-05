--大王目玉
-- 效果：
-- 反转：从自己卡组上面把最多5张卡确认，用喜欢的顺序回到卡组上面。
function c16768387.initial_effect(c)
	-- 反转效果：从自己卡组上面把最多5张卡确认，用喜欢的顺序回到卡组上面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16768387,0))  --"确认卡组"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetOperation(c16768387.operation)
	c:RegisterEffect(e1)
end
-- 效果处理函数
function c16768387.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组顶部最多5张卡的数量
	local ct=math.min(5,Duel.GetFieldGroupCount(tp,LOCATION_DECK,0))
	if ct==0 then return end
	local t={}
	for i=1,ct do
		t[i]=i
	end
	local ac=1
	if ct>1 then
		-- 提示玩家选择要确认的卡的数量
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(16768387,1))  --"请选择要确认的卡的数量"
		-- 让玩家宣言要确认的卡的数量
		ac=Duel.AnnounceNumber(tp,table.unpack(t))
	end
	-- 将选中的卡按指定顺序放回卡组顶部
	Duel.SortDecktop(tp,tp,ac)
end
