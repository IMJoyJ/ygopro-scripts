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
	-- 这个卡名的②的效果1回合只能使用1次。②：自己·对方的主要阶段才能发动。从手卡把1张「火山」卡送去墓地，自己抽1张。
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
	-- 为这张卡注册在魔法与陷阱区域时卡名当作「烈焰加农炮-三叉戟式」使用的效果，对应①效果。
	aux.EnableChangeCode(c,21420702)
	-- ③：自己·对方的主要阶段，把墓地的这张卡除外才能发动。从卡组把1张「火山」卡送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(52198054,1))  --"送去墓地"
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCondition(c52198054.condition)
	-- 设置效果③的发动代价：将墓地中的这张卡除外，对应“把墓地的这张卡除外才能发动”。
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(c52198054.tgtg)
	e4:SetOperation(c52198054.tgop)
	e4:SetHintTiming(0,TIMING_MAIN_END)
	c:RegisterEffect(e4)
end
-- 效果②③共同的发动条件：当前阶段必须为主要阶段1或主要阶段2，满足“自己·对方的主要阶段才能发动”的时点要求。
function c52198054.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1或主要阶段2，以确定处于双方主要阶段。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 效果②发动时的目标函数：检查自己能否抽卡且手牌有「火山」卡可送墓，满足则允许发动。
function c52198054.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0时的合法性检查：确认自己可以进行抽卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 并确认手牌中存在至少1张「火山」系列卡，以供从手卡送去墓地。
		and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_HAND,0,1,nil,0x32) end
	-- 登记效果处理时将1张手牌送去墓地的操作信息（具体卡片在效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
	-- 登记效果处理时自己抽1张卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果②处理时的实际执行：从手牌选择1张「火山」卡送去墓地，然后自己抽1张。
function c52198054.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出“请选择要送去墓地的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手牌中选择1张「火山」系列的卡（0x32），用于送去墓地。
	local g=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_HAND,0,1,1,nil,0x32)
	-- 确认成功选择且该卡已因效果被送去墓地后，才继续执行抽卡，避免送墓失败仍抽卡。
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 自己抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 效果③的卡组筛选条件：卡是「火山」系列且可以送去墓地。
function c52198054.tgfilter(c)
	return c:IsSetCard(0x32) and c:IsAbleToGrave()
end
-- 效果③发动时的目标函数：确认卡组中有符合条件的「火山」卡，并登记从卡组送墓的操作信息。
function c52198054.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0时的合法性检查：确认卡组中存在至少1张符合条件的「火山」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c52198054.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记效果处理时将卡组中1张卡送去墓地的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果③处理时的实际执行：从卡组选择1张「火山」卡送去墓地。
function c52198054.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出“请选择要送去墓地的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1张符合过滤条件（「火山」系列且可送墓）的卡。
	local g=Duel.SelectMatchingCard(tp,c52198054.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的「火山」卡以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
