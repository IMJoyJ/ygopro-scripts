--翡翠の蟲笛
-- 效果：
-- 对方从卡组中选择1张昆虫族怪兽卡，那张卡放在卡组最上面。
function c95214051.initial_effect(c)
	-- 对方从卡组中选择1张昆虫族怪兽卡，那张卡放在卡组最上面。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c95214051.target)
	e1:SetOperation(c95214051.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的可行性检测函数
function c95214051.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方卡组中是否存在卡片
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 end
end
-- 效果通过时的处理函数
function c95214051.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向对方玩家发送选择卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(95214051,0))  --"请选择要放置到卡组最上方的卡"
	-- 让对方玩家从其卡组中选择1张昆虫族怪兽卡
	local g=Duel.SelectMatchingCard(1-tp,Card.IsRace,1-tp,LOCATION_DECK,0,1,1,nil,RACE_INSECT)
	local tc=g:GetFirst()
	if tc then
		-- 洗切对方玩家的卡组
		Duel.ShuffleDeck(1-tp)
		-- 将选中的卡片移动到对方卡组的最上方
		Duel.MoveSequence(tc,SEQ_DECKTOP)
		-- 确认对方卡组最上方的一张卡
		Duel.ConfirmDecktop(1-tp,1)
	end
end
