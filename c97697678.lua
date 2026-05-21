--円盤ムスキー
-- 效果：
-- 只要这张卡在场上表侧表示存在，可以代替自己的抽卡阶段通常的抽卡，从卡组选择1张名字带有「外星」的卡加入手卡。
function c97697678.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，可以代替自己的抽卡阶段通常的抽卡，从卡组选择1张名字带有「外星」的卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97697678,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c97697678.condition)
	e1:SetTarget(c97697678.target)
	e1:SetOperation(c97697678.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件函数
function c97697678.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return tp==Duel.GetTurnPlayer()
end
-- 过滤卡组中名字带有「外星」且能加入手牌的卡片
function c97697678.filter(c)
	return c:IsSetCard(0xc) and c:IsAbleToHand()
end
-- 定义效果发动时的检测与操作信息设置函数
function c97697678.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，判断玩家是否能进行通常抽卡且卡组中存在可检索的「外星」卡片
	if chk==0 then return aux.IsPlayerCanNormalDraw(tp) and Duel.IsExistingMatchingCard(c97697678.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义效果处理函数
function c97697678.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，再次确认玩家是否能进行通常抽卡，若不能则不处理
	if not aux.IsPlayerCanNormalDraw(tp) then return end
	-- 使玩家放弃本回合抽卡阶段的通常抽卡
	aux.GiveUpNormalDraw(e,tp)
	if not e:GetHandler():IsRelateToEffect(e) or e:GetHandler():IsFacedown()then return end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「外星」卡片
	local g=Duel.SelectMatchingCard(tp,c97697678.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示加入手牌的卡片进行确认
		Duel.ConfirmCards(1-tp,g)
	end
end
