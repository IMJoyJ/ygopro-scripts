--アシスト★ヤミー！
-- 效果：
-- 这个卡名的②③的效果1回合只能有1次使用其中任意1个。
-- ①：自己·对方的准备阶段才能发动1次。自己回复100基本分，对方支付100基本分。
-- ②：自己·对方的主要阶段以及对方战斗阶段，把包含这张卡的自己场上2张表侧表示的「味美喵」卡送去墓地才能发动。自己或对方的场上·墓地1张卡回到手卡。
-- ③：把墓地的这张卡除外才能发动。从卡组把「协助摆位★味美喵！」以外的1张「味美喵」卡送去墓地。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（准备阶段回复/支付LP）、②效果（主要/对方战斗阶段送墓回手）、③效果（墓地除外送墓卡组「味美喵」）。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己·对方的准备阶段才能发动1次。自己回复100基本分，对方支付100基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"基本分"
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1)
	e2:SetTarget(s.lptg)
	e2:SetOperation(s.lpop)
	c:RegisterEffect(e2)
	-- ②：自己·对方的主要阶段以及对方战斗阶段，把包含这张卡的自己场上2张表侧表示的「味美喵」卡送去墓地才能发动。自己或对方的场上·墓地1张卡回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.thcon)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	-- ③：把墓地的这张卡除外才能发动。从卡组把「协助摆位★味美喵！」以外的1张「味美喵」卡送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"送去墓地"
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetHintTiming(TIMING_END_PHASE)
	e4:SetCountLimit(1,id)
	-- 设置效果③的发动代价为将墓地的这张卡除外。
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(s.tgtg)
	e4:SetOperation(s.tgop)
	c:RegisterEffect(e4)
end
-- 效果①（准备阶段回复/支付LP）的发动检测与效果分类注册。
function s.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方的基本分是否在100以上（确保对方能够支付100基本分）。
	if chk==0 then return Duel.GetLP(1-tp)>=100 end
	-- 注册连锁处理中的效果分类为回复LP，回复数值为100。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,100)
end
-- 效果①（准备阶段回复/支付LP）的效果处理函数。
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	-- 成功使自己回复100基本分，且对方基本分在100以上时。
	if Duel.Recover(tp,100,REASON_EFFECT)~=0 and Duel.GetLP(1-tp)>=100 then
		-- 让对方玩家支付100基本分。
		Duel.PayLPCost(1-tp,100)
	end
end
-- 效果②（送墓回手）的发动条件判断：必须在双方的主要阶段或对方的战斗阶段，且此卡在场上表侧表示存在。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为双方的主要阶段，或者是对方的回合且处于战斗阶段。
	return (Duel.IsMainPhase() or Duel.GetTurnPlayer()~=tp and Duel.IsBattlePhase())
		and e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- 过滤除此卡外，自己场上表侧表示的「味美喵」卡，且该卡送墓后场上或墓地仍有至少1张可回到手牌的卡。
function s.cfilter(c,ec,tp)
	return c:IsFaceup() and c:IsSetCard(0x1ca) and c:IsAbleToGraveAsCost()
		-- 检查在排除作为cost送去墓地的两张卡（此卡与另一张卡）后，双方场上或墓地是否存在至少1张可以回到手牌的卡。
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_ONFIELD,LOCATION_GRAVE+LOCATION_ONFIELD,1,Group.FromCards(c,ec))
end
-- 效果②（送墓回手）的发动代价检测与处理。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsFaceup()
		-- 检查自己场上是否存在除此卡以外的、满足送墓条件的另一张「味美喵」卡。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,c,c,tp) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择自己场上除此卡以外的1张表侧表示的「味美喵」卡。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler(),c,tp)
	g:AddCard(c)
	-- 将选中的卡（连同此卡）作为发动代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤可以回到手牌的卡片。
function s.thfilter(c)
	return c:IsAbleToHand()
end
-- 效果②（送墓回手）的发动检测与效果分类注册。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方场上或墓地是否存在至少1张可以回到手牌的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_ONFIELD,LOCATION_GRAVE+LOCATION_ONFIELD,1,nil) end
	-- 注册连锁处理中的效果分类为回到手牌，数量为1张，范围为双方的场上或墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_ONFIELD)
end
-- 效果②（送墓回手）的效果处理函数。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家从双方场上或墓地（受王家之谷影响）选择1张可以回到手牌的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_ONFIELD,LOCATION_GRAVE+LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 选中卡片并向双方玩家展示。
		Duel.HintSelection(g)
		-- 将选中的卡送回持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 过滤卡组中除「协助摆位★味美喵！」以外的「味美喵」卡，且该卡能送去墓地。
function s.tgfilter(c)
	return c:IsSetCard(0x1ca) and not c:IsCode(id) and c:IsAbleToGrave()
end
-- 效果③（墓地除外送墓卡组「味美喵」）的发动检测与效果分类注册。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「味美喵」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 注册连锁处理中的效果分类为送去墓地，数量为1张，范围为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果③（墓地除外送墓卡组「味美喵」）的效果处理函数。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足条件的「味美喵」卡。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
