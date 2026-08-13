--融合再生機構
-- 效果：
-- ①：1回合1次，丢弃1张手卡才能发动。从自己的卡组·墓地选1张「融合」加入手卡。
-- ②：自己·对方的结束阶段，以这个回合融合召唤使用过的自己墓地1只融合素材怪兽为对象才能发动。那只怪兽加入手卡。
function c22829942.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，丢弃1张手卡才能发动。从自己的卡组·墓地选1张「融合」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22829942,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c22829942.thcost)
	e2:SetTarget(c22829942.thtg)
	e2:SetOperation(c22829942.thop)
	c:RegisterEffect(e2)
	-- ②：自己·对方的结束阶段，以这个回合融合召唤使用过的自己墓地1只融合素材怪兽为对象才能发动。那只怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(22829942,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c22829942.thtg2)
	e3:SetOperation(c22829942.thop2)
	c:RegisterEffect(e3)
end
-- 效果①的代价处理函数：发动前检查手牌是否有可丢弃的卡，发动时丢弃1张手卡作为代价。
function c22829942.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：确认自己手牌中是否存在至少1张可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行代价：从手牌选择1张可以丢弃的卡，以代价+丢弃的理由送入墓地。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 检索过滤器：卡名必须为「融合」（卡号24094653），且能够加入手卡。
function c22829942.thfilter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- 效果①的发动目标函数：检查卡组·墓地中是否存在符合条件的「融合」，并设置效果处理时将那张卡加入手卡的操作信息。
function c22829942.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：确认自己卡组·墓地中是否存在至少1张符合条件的「融合」。
	if chk==0 then return Duel.IsExistingMatchingCard(c22829942.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设定操作信息：本次效果将把1张「融合」从自己卡组·墓地加入手卡（具体卡在效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果①的处理函数：从自己的卡组·墓地选1张符合条件的「融合」加入手卡，并让对方确认。
function c22829942.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组·墓地中选出1张符合条件的「融合」（自动过滤因王家长眠之谷等效果不能移动的卡）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c22829942.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「融合」加入持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方确认加入手卡的卡片，以符合游戏规则中的公开确认要求。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 墓地检索过滤器：该怪兽必须是在本回合作为融合素材使用而送入墓地的怪兽，并且能够加入手卡。
function c22829942.thfilter2(c,id)
	return c:GetReason()&(REASON_FUSION+REASON_MATERIAL)==(REASON_FUSION+REASON_MATERIAL) and c:IsType(TYPE_MONSTER) and c:GetTurnID()==id and c:IsAbleToHand()
end
-- 效果②的发动目标函数：在结束阶段，从自己墓地选择1只本回合作为融合素材使用过的怪兽作为对象，并设置加入手卡的操作信息。
function c22829942.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前回合编号，用于判断怪兽是否在本回合进入墓地。
	local tid=Duel.GetTurnCount()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c22829942.thfilter2(chkc,tid) end
	-- 发动条件检测：确认自己墓地存在至少1只符合条件的融合素材怪兽。
	if chk==0 then return Duel.IsExistingTarget(c22829942.thfilter2,tp,LOCATION_GRAVE,0,1,nil,tid) end
	-- 弹出选择提示，提示玩家选择要加入手卡的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选择1只本回合用作融合素材的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c22829942.thfilter2,tp,LOCATION_GRAVE,0,1,1,nil,tid)
	-- 设定操作信息：将选中的目标怪兽加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的处理函数：将效果对象怪兽加入手卡。
function c22829942.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取出效果发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该目标怪兽加入其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
