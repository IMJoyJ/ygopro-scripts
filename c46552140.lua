--アダマシア・ラピュタイト
-- 效果：
-- ①：自己场上的岩石族怪兽的攻击力·守备力上升500。
-- ②：1回合1次，自己主要阶段才能发动。从卡组选最多5张「魔救」卡用喜欢的顺序在卡组最上面放置。
function c46552140.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的岩石族怪兽的攻击力·守备力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 筛选满足条件的卡片组，即场上岩石族怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_ROCK))
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：1回合1次，自己主要阶段才能发动。从卡组选最多5张「魔救」卡用喜欢的顺序在卡组最上面放置。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(46552140,0))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c46552140.sorttg)
	e4:SetOperation(c46552140.sortop)
	c:RegisterEffect(e4)
end
-- 判断是否可以发动效果，检查卡组中是否存在至少一张「魔救」卡
function c46552140.sorttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测卡组中是否存在满足条件的「魔救」卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_DECK,0,1,nil,0x140) end
end
-- 处理效果发动后的操作，包括提示选择、选取卡片、确认卡片、洗切卡组并排序
function c46552140.sortop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，提示其选择要放置到卡组最上面的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(46552140,1))  --"请选择要放置卡组最上面的卡"
	-- 从卡组中选择最多5张「魔救」卡
	local g=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_DECK,0,1,5,nil,0x140)
	if g:GetCount()>0 then
		-- 确认对方玩家看到所选的卡
		Duel.ConfirmCards(1-tp,g)
		-- 将玩家的卡组进行洗切
		Duel.ShuffleDeck(tp)
		local tc=g:GetFirst()
		while tc do
			-- 将选定的卡移动到卡组最上方
			Duel.MoveSequence(tc,SEQ_DECKTOP)
			tc=g:GetNext()
		end
		-- 对玩家卡组最上方的卡进行排序
		Duel.SortDecktop(tp,tp,g:GetCount())
	end
end
