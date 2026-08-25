--ウィッチクラフト・シード
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，若自己场上有「魔女术工匠·种子女巫」以外的「魔女术」怪兽或「圣月之皇太子 雷古勒斯」存在，以场上1张表侧表示卡为对象才能发动。那张卡回到手卡。
-- ②：把墓地的这张卡除外才能发动。包含魔法卡的手卡的卡任意数量给对方观看，回到卡组。那之后，自己抽出回去的数量。
local s,id,o=GetID()
-- 初始化卡片效果：注册召唤/特殊召唤弹卡效果与墓地除外洗手抽卡效果
function s.initial_effect(c)
	-- 注册卡名列表中记载的「圣月之皇太子 雷古勒斯」
	aux.AddCodeList(c,96228804)
	-- ①：这张卡召唤·特殊召唤的场合，若自己场上有「魔女术工匠·种子女巫」以外的「魔女术」怪兽或「圣月之皇太子 雷古勒斯」存在，以场上1张表侧表示卡为对象才能发动。那张卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回到手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡除外才能发动。包含魔法卡的手卡的卡任意数量给对方观看，回到卡组。那之后，自己抽出回去的数量。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"抽卡效果"
	e3:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCountLimit(1,id+o)
	-- 发动代价：把墓地的这张卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
end
-- 过滤场上表侧表示且可以回到手卡的卡
function s.thfilter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- 过滤自身以外表侧表示的「魔女术」怪兽或「圣月之皇太子 雷古勒斯」
function s.cfilter(c)
	return not c:IsCode(id) and c:IsFaceup()
		and (c:IsSetCard(0x128) and c:IsType(TYPE_MONSTER) or c:IsCode(96228804))
end
-- 设置效果目标：选择场上1张表侧表示的卡为对象
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.thfilter(chkc) end
	-- 检查场上是否存在自身以外的「魔女术」怪兽或「圣月之皇太子 雷古勒斯」
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查场上是否存在可以回到手卡的表侧表示卡
		and Duel.IsExistingTarget(s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上1张表侧表示的卡作为对象
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：目标卡回到手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：将目标卡送回手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将目标卡送回手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤手卡中非公开且可以返回卡组的卡
function s.tdfilter(c)
	return not c:IsPublic() and c:IsAbleToDeck()
end
-- 过滤手卡中非公开且可以返回卡组的魔法卡
function s.ctdfilter(c)
	return not c:IsPublic() and c:IsAbleToDeck() and c:IsType(TYPE_SPELL)
end
-- 设置效果目标：检查是否可以抽卡并确认手卡中是否有魔法卡
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		-- 检查手卡中是否存在可以返回卡组的魔法卡
		and Duel.IsExistingMatchingCard(s.ctdfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置当前玩家为效果目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置操作信息：手卡返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 检查所选卡片组中是否至少包含1张魔法卡
function s.gcheck(g)
	return g:IsExists(s.ctdfilter,1,nil)
end
-- 效果处理：公开手卡中包含魔法卡的任意数量卡片洗回卡组并抽出相同数量
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取手卡中所有非公开且可返回卡组的卡
	local g=Duel.GetMatchingGroup(s.tdfilter,p,LOCATION_HAND,0,nil)
	-- 提示选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:SelectSubGroup(p,s.gcheck,false,1,g:GetCount())
	if not sg then return end
	-- 向对方玩家展示选择的卡
	Duel.ConfirmCards(1-p,sg)
	-- 将选择的卡洗回卡组
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 洗切卡组
	Duel.ShuffleDeck(p)
	local ct=sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct>0 then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 抽返回卡组数量的卡
		Duel.Draw(p,ct,REASON_EFFECT)
	end
end
