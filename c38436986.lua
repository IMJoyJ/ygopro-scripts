--壱世壊に軋む爪音
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上有「珠泪哀歌族」怪兽或者「维萨斯-斯塔弗罗斯特」存在的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。那之后，从卡组把1只「珠泪哀歌族」怪兽送去墓地。
-- ②：这张卡被效果送去墓地的场合，以自己墓地1只「珠泪哀歌族」怪兽为对象才能发动。那只怪兽加入手卡。
function c38436986.initial_effect(c)
	-- 注册此卡与「维萨斯-斯塔弗罗斯特」（56099748）的关联，用于效果判定
	aux.AddCodeList(c,56099748)
	-- ①：自己场上有「珠泪哀歌族」怪兽或者「维萨斯-斯塔弗罗斯特」存在的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。那之后，从卡组把1只「珠泪哀歌族」怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_TOGRAVE+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,38436986)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c38436986.condition)
	e1:SetTarget(c38436986.target)
	e1:SetOperation(c38436986.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果送去墓地的场合，以自己墓地1只「珠泪哀歌族」怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,38436986)
	e2:SetCondition(c38436986.thcon)
	e2:SetTarget(c38436986.thtg)
	e2:SetOperation(c38436986.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断场上是否存在「珠泪哀歌族」怪兽或「维萨斯-斯塔弗罗斯特」且处于表侧表示
function c38436986.actcfilter(c)
	return ((c:IsSetCard(0x181) and c:IsLocation(LOCATION_MZONE)) or c:IsCode(56099748)) and c:IsFaceup()
end
-- 条件函数：判断自己场上是否存在满足actcfilter条件的怪兽
function c38436986.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张满足actcfilter条件的卡
	return Duel.IsExistingMatchingCard(c38436986.actcfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤函数：判断目标怪兽是否为表侧表示且可以变为里侧守备表示
function c38436986.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 过滤函数：判断卡是否为「珠泪哀歌族」怪兽且可以送去墓地
function c38436986.tgfilter(c)
	return c:IsSetCard(0x181) and c:IsAbleToGrave() and c:IsType(TYPE_MONSTER)
end
-- 目标函数：选择对方场上1只表侧表示怪兽作为对象，并确认卡组中存在可送去墓地的「珠泪哀歌族」怪兽
function c38436986.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c38436986.posfilter(chkc) end
	-- 检查对方场上是否存在至少1只满足posfilter条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c38436986.posfilter,tp,0,LOCATION_MZONE,1,nil)
		-- 检查自己卡组中是否存在至少1张满足tgfilter条件的怪兽
		and Duel.IsExistingMatchingCard(c38436986.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示怪兽作为对象
	local g=Duel.SelectTarget(tp,c38436986.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：将目标怪兽变为里侧守备表示
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	-- 设置操作信息：从卡组送去1张「珠泪哀歌族」怪兽至墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 发动函数：将目标怪兽变为里侧守备表示，并从卡组送去1张「珠泪哀歌族」怪兽至墓地
function c38436986.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且处于表侧表示，然后将其变为里侧守备表示
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)>0 then
		-- 提示玩家选择要送去墓地的「珠泪哀歌族」怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从卡组中选择1张「珠泪哀歌族」怪兽
		local g=Duel.SelectMatchingCard(tp,c38436986.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			-- 中断当前效果处理，使后续处理视为不同时处理
			Duel.BreakEffect()
			-- 将选择的怪兽送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
-- 条件函数：判断此卡是否因效果而送去墓地
function c38436986.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤函数：判断墓地中的怪兽是否为「珠泪哀歌族」怪兽且可以加入手牌
function c38436986.thfilter(c)
	return c:IsSetCard(0x181) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 目标函数：选择自己墓地中1只「珠泪哀歌族」怪兽作为对象
function c38436986.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c38436986.thfilter(chkc) end
	-- 检查自己墓地中是否存在至少1只满足thfilter条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c38436986.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地中1只「珠泪哀歌族」怪兽作为对象
	local g=Duel.SelectTarget(tp,c38436986.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 发动函数：将目标怪兽加入手牌
function c38436986.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
