--ブレイズ・キャノン・マガジン
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在魔法与陷阱区域存在当作「烈焰加农炮-三叉戟式」使用。
-- ②：自己·对方的主要阶段才能发动。从手卡把1张「火山」卡送去墓地，自己抽1张。
-- ③：自己·对方的主要阶段，把墓地的这张卡除外才能发动。从卡组把1张「火山」卡送去墓地。
function c52198054.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	c:RegisterEffect(e1)
	-- ②：自己·对方的主要阶段才能发动。从手卡把1张「火山」卡送去墓地，自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,52198054)
	e2:SetCondition(c52198054.condition)
	e2:SetTarget(c52198054.target)
	e2:SetOperation(c52198054.operation)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	c:RegisterEffect(e2)
	-- 使此卡在魔法与陷阱区域存在时视为「烈焰加农炮-三叉戟式」使用
	aux.EnableChangeCode(c,21420702)
	-- ③：自己·对方的主要阶段，把墓地的这张卡除外才能发动。从卡组把1张「火山」卡送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(52198054,1))  --"送去墓地"
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCondition(c52198054.condition)
	-- 将此卡从墓地除外作为cost
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(c52198054.tgtg)
	e4:SetOperation(c52198054.tgop)
	e4:SetHintTiming(0,TIMING_MAIN_END)
	c:RegisterEffect(e4)
end
-- 判断是否处于主要阶段1或主要阶段2
function c52198054.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否处于主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 检查玩家是否可以抽卡且手牌中是否存在「火山」卡
function c52198054.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查手牌中是否存在「火山」卡
		and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_HAND,0,1,nil,0x32) end
	-- 设置将要送去墓地的卡组信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
	-- 设置将要抽卡的信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 选择并处理手牌中的「火山」卡送去墓地，然后抽一张卡
function c52198054.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手牌中选择一张「火山」卡
	local g=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_HAND,0,1,1,nil,0x32)
	-- 确认所选卡已成功送去墓地且在墓地
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 让玩家抽一张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 过滤函数，用于筛选可送去墓地的「火山」卡
function c52198054.tgfilter(c)
	return c:IsSetCard(0x32) and c:IsAbleToGrave()
end
-- 检查卡组中是否存在「火山」卡
function c52198054.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在「火山」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c52198054.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将要送去墓地的卡组信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 选择并处理卡组中的「火山」卡送去墓地
function c52198054.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择一张「火山」卡
	local g=Duel.SelectMatchingCard(tp,c52198054.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将所选卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
