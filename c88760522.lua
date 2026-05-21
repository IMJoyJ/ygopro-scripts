--多様進化
-- 效果：
-- 从卡组把1只名字带有「进化虫」或者「进化龙」的怪兽加入手卡。「多样进化」在1回合只能发动1张。
function c88760522.initial_effect(c)
	-- 从卡组把1只名字带有「进化虫」或者「进化龙」的怪兽加入手卡。「多样进化」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,88760522+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c88760522.target)
	e1:SetOperation(c88760522.activate)
	c:RegisterEffect(e1)
end
-- 过滤卡组中名字带有「进化虫」或「进化龙」且可以加入手牌的怪兽卡
function c88760522.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x304e,0x604e) and c:IsAbleToHand()
end
-- 效果发动的目标检测与操作信息设置
function c88760522.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检测卡组中是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c88760522.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示该效果会将卡组的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数，将选中的怪兽加入手牌并确认
function c88760522.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在客户端显示提示信息，提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c88760522.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
