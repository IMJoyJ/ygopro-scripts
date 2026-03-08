--トラミッド・クルーザー
-- 效果：
-- 「三形金字塔·巡航机」的③的效果1回合只能使用1次。
-- ①：只要这张卡在场地区域存在，每次岩石族怪兽召唤，自己回复500基本分。
-- ②：场上有「三形金字塔」怪兽召唤的场合才能发动。自己从卡组抽1张，那之后选1张手卡丢弃。
-- ③：场地区域的表侧表示的这张卡被送去墓地的场合才能发动。从卡组把1只「三形金字塔」怪兽加入手卡。
function c45383307.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在场地区域存在，每次岩石族怪兽召唤，自己回复500基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45383307,0))  --"回复基本分"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTarget(c45383307.lptg)
	e2:SetOperation(c45383307.lpop)
	c:RegisterEffect(e2)
	-- ②：场上有「三形金字塔」怪兽召唤的场合才能发动。自己从卡组抽1张，那之后选1张手卡丢弃。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(45383307,1))
	e3:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTarget(c45383307.drtg)
	e3:SetOperation(c45383307.drop)
	c:RegisterEffect(e3)
	-- ③：场地区域的表侧表示的这张卡被送去墓地的场合才能发动。从卡组把1只「三形金字塔」怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetDescription(aux.Stringid(45383307,2))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,45383307)
	e4:SetCondition(c45383307.thcon)
	e4:SetTarget(c45383307.thtg)
	e4:SetOperation(c45383307.thop)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于判断怪兽是否为岩石族
function c45383307.lpfilter(c)
	return c:IsRace(RACE_ROCK)
end
-- 判断是否有岩石族怪兽被召唤
function c45383307.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c45383307.lpfilter,1,nil) end
end
-- 使玩家回复500基本分
function c45383307.lpop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送卡片发动的动画提示
	Duel.Hint(HINT_CARD,0,e:GetHandler():GetCode())
	-- 使玩家回复500基本分
	Duel.Recover(tp,500,REASON_EFFECT)
end
-- 过滤函数，用于判断是否为「三形金字塔」怪兽
function c45383307.drfilter(c)
	return c:IsSetCard(0xe2) and c:IsType(TYPE_MONSTER)
end
-- 判断是否有「三形金字塔」怪兽被召唤且玩家可以抽卡
function c45383307.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c45383307.drfilter,1,nil)
		-- 判断玩家是否可以抽卡
		and Duel.IsPlayerCanDraw(tp,1) end
	-- 设置操作信息：丢弃手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	-- 设置操作信息：抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 处理抽卡并丢弃手牌的效果
function c45383307.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功抽卡
	if Duel.Draw(tp,1,REASON_EFFECT)~=0 then
		-- 洗切玩家手牌
		Duel.ShuffleHand(tp)
		-- 中断当前效果
		Duel.BreakEffect()
		-- 丢弃玩家1张手牌
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
-- 过滤函数，用于判断是否为「三形金字塔」怪兽且可以加入手牌
function c45383307.thfilter(c)
	return c:IsSetCard(0xe2) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 判断此卡是否从场地区域表侧表示被送去墓地
function c45383307.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_FZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 设置操作信息：从卡组检索「三形金字塔」怪兽加入手牌
function c45383307.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在满足条件的「三形金字塔」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c45383307.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组检索「三形金字塔」怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理从卡组检索「三形金字塔」怪兽加入手牌的效果
function c45383307.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「三形金字塔」怪兽
	local g=Duel.SelectMatchingCard(tp,c45383307.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
