--穿孔虫
-- 效果：
-- 这张卡给与对方战斗伤害的时候，从自己的卡组取出1张「寄生虫 帕拉赛德」，之后在卡组洗切后放在卡组最上面。
function c88733579.initial_effect(c)
	-- 这张卡给与对方战斗伤害的时候，从自己的卡组取出1张「寄生虫 帕拉赛德」，之后在卡组洗切后放在卡组最上面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88733579,0))  --"检索"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c88733579.condition)
	e1:SetTarget(c88733579.target)
	e1:SetOperation(c88733579.operation)
	c:RegisterEffect(e1)
end
-- 检查造成战斗伤害的玩家是否为对方
function c88733579.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp
end
-- 效果发动的可行性检查：卡组中存在「寄生虫 帕拉赛德」且卡组卡片数量大于1
function c88733579.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在「寄生虫 帕拉赛德」
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_DECK,0,1,nil,27911549)
		-- 检查自己卡组的卡片数量是否大于1张
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1 end
end
-- 效果处理：从卡组选择「寄生虫 帕拉赛德」，洗切卡组后将其放置在卡组最上面并确认
function c88733579.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 设置选择卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(88733579,1))  --"请选择要放置在卡组最上面的卡"
	-- 从自己卡组选择1张「寄生虫 帕拉赛德」
	local g=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_DECK,0,1,1,nil,27911549)
	local tc=g:GetFirst()
	if tc then
		-- 洗切自己的卡组
		Duel.ShuffleDeck(tp)
		-- 将选择的卡移动到卡组最上方
		Duel.MoveSequence(tc,SEQ_DECKTOP)
		-- 确认自己卡组最上方的一张卡
		Duel.ConfirmDecktop(tp,1)
	end
end
