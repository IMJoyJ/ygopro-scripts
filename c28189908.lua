--TG－ブレイクリミッター
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：丢弃1张手卡才能发动。从卡组把2只「科技属」怪兽加入手卡（同名卡最多1张）。
-- ②：把墓地的这张卡除外，以自己墓地1只「科技属」怪兽为对象才能发动。那只怪兽回到卡组。自己场上有机械族「科技属」怪兽存在的场合，也能不回到卡组加入手卡。
local s,id,o=GetID()
-- 注册两个效果：①丢弃手卡检索2只科技属怪兽；②墓地除外自身将1只墓地科技属怪兽回到卡组或加入手牌
function s.initial_effect(c)
	-- ①：丢弃1张手卡才能发动。从卡组把2只「科技属」怪兽加入手卡（同名卡最多1张）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1只「科技属」怪兽为对象才能发动。那只怪兽回到卡组。自己场上有机械族「科技属」怪兽存在的场合，也能不回到卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 效果②的发动需要将此卡除外作为代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.rttg)
	e2:SetOperation(s.rtop)
	c:RegisterEffect(e2)
end
-- 效果①的发动需要丢弃1张手卡作为代价
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足效果①发动的条件：手牌中是否存在可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行效果①的丢弃手卡操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 检索过滤函数：筛选卡名属于科技属且为怪兽卡且能加入手牌的卡
function s.filter(c)
	return c:IsSetCard(0x27) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的发动准备阶段：判断是否满足检索条件（卡组中存在至少2种不同卡名的科技属怪兽）
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足效果①发动的条件：卡组中是否存在至少2种不同卡名的科技属怪兽
	if chk==0 then return Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil):GetClassCount(Card.GetCode)>1 end
	-- 设置效果①的处理信息：准备从卡组检索2张科技属怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 效果①的处理函数：选择并检索2张不同卡名的科技属怪兽加入手牌
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择2张不同卡名的科技属怪兽
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil):SelectSubGroup(tp,aux.dncheck,false,2,2)
	if g then
		-- 将选中的2张卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 场上的机械族科技属怪兽过滤函数
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsSetCard(0x27)
end
-- 效果②的目标过滤函数：筛选墓地中的科技属怪兽，且可回到卡组或加入手牌
function s.rfilter(c,chk)
	return c:IsSetCard(0x27) and c:IsType(TYPE_MONSTER) and (c:IsAbleToDeck() or chk and c:IsAbleToHand())
end
-- 效果②的发动准备阶段：判断是否满足发动条件并选择目标
function s.rttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断场上是否存在机械族科技属怪兽
	local check=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.rfilter(chkc,check) end
	-- 判断是否满足效果②发动的条件：墓地是否存在符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(s.rfilter,tp,LOCATION_GRAVE,0,1,nil,check) end
	-- 提示玩家选择效果②的目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择效果②的目标怪兽
	local g=Duel.SelectTarget(tp,s.rfilter,tp,LOCATION_GRAVE,0,1,1,nil,check)
	-- 设置效果②的处理信息：准备将目标怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果②的处理函数：将目标怪兽送回卡组或加入手牌
function s.rtop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 判断是否满足效果②的特殊处理条件：场上有机械族科技属怪兽且目标怪兽可加入手牌
	local check=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) and tc:IsAbleToHand()
	-- 询问玩家选择处理方式：送回卡组或加入手牌
	if check and Duel.SelectOption(tp,1190,1193)==0 then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,tc)
	-- 将目标怪兽送回卡组
	else Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) end
end
