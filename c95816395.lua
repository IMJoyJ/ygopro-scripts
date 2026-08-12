--どぐう
-- 效果：
-- 「土偶」的效果1回合只能使用1次。
-- ①：这张卡被对方的效果送去墓地的回合的结束阶段才能发动。不在自己的场上·墓地存在的等级的1只怪兽从卡组加入手卡。
function c95816395.initial_effect(c)
	-- ①：这张卡被对方的效果送去墓地的回合的结束阶段才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetOperation(c95816395.regop)
	c:RegisterEffect(e1)
end
-- 在送去墓地时，若满足被对方效果送墓的条件，则注册一个在回合结束阶段可以发动的效果
function c95816395.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if rp==1-tp and c:IsReason(REASON_EFFECT) then
		-- 不在自己的场上·墓地存在的等级的1只怪兽从卡组加入手卡。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(95816395,0))  --"卡组检索"
		e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1,95816395)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetTarget(c95816395.thtg)
		e1:SetOperation(c95816395.thop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 过滤卡组中可以加入手牌，且其等级不存在于自己场上或自己墓地的怪兽
function c95816395.filter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		-- 过滤条件：在自己的场上（怪兽区）或墓地不存在与该卡相同等级的卡
		and not Duel.IsExistingMatchingCard(c95816395.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,c:GetLevel())
end
-- 过滤自己场上表侧表示或自己墓地中，等级与指定等级相同的卡
function c95816395.cfilter(c,lv)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsLevel(lv)
end
-- 效果发动的目标过滤与操作信息设置
function c95816395.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c95816395.filter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 设置操作信息为：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只满足条件的怪兽加入手牌，并给对方确认
function c95816395.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c95816395.filter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
