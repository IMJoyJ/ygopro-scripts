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
	-- 设置攻击力上升效果的适用对象：我方怪兽区域中种族为岩石族的怪兽。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_ROCK))
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：1回合1次，自己主要阶段才能发动。从卡组选最多5张『魔救』卡用喜欢的顺序在卡组最上面放置。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(46552140,0))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c46552140.sorttg)
	e4:SetOperation(c46552140.sortop)
	c:RegisterEffect(e4)
end
-- 效果发动条件检测：确认我方卡组中存在至少1张『魔救』字段（0x140）的卡，否则不能发动。
function c46552140.sorttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时的合法性检查：若chk==0，检查我方卡组是否存在1张以上『魔救』字段的卡，存在才允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_DECK,0,1,nil,0x140) end
end
-- 效果处理：从卡组选1～5张『魔救』卡，向对方展示，洗切卡组，将所选卡依次放到卡组最上方，最后由自己决定这些卡在顶部的排列顺序。
function c46552140.sortop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家发送选择提示消息：请选择要放置卡组最上面的卡。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(46552140,1))  --"请选择要放置卡组最上面的卡"
	-- 让玩家从自己卡组中选择1～5张『魔救』字段（0x140）的卡作为要放置到卡组顶部的卡。
	local g=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_DECK,0,1,5,nil,0x140)
	if g:GetCount()>0 then
		-- 将本次选择的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		-- 洗切自己的卡组（选卡后使卡组其余部分随机化）。
		Duel.ShuffleDeck(tp)
		local tc=g:GetFirst()
		while tc do
			-- 把当前这张选中的卡移动到卡组最顶端（SEQ_DECKTOP）。
			Duel.MoveSequence(tc,SEQ_DECKTOP)
			tc=g:GetNext()
		end
		-- 让操作玩家对自己卡组最上方g:GetCount()张卡进行排序，决定它们在卡组顶部的最终顺序。
		Duel.SortDecktop(tp,tp,g:GetCount())
	end
end
