--ウィッチクラフト・シード
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，若自己场上有「魔女术工匠·种子女巫」以外的「魔女术」怪兽或「圣月之皇太子 雷古勒斯」存在，以场上1张表侧表示卡为对象才能发动。那张卡回到手卡。
-- ②：把墓地的这张卡除外才能发动。包含魔法卡的手卡的卡任意数量给对方观看，回到卡组。那之后，自己抽出回去的数量。
local s,id,o=GetID()
-- 注册这张卡的全部效果：记载「圣月之皇太子 雷古勒斯」卡名；注册①效果（召唤·特殊召唤成功时取场上表侧表示卡为对象使其回手，1回合1次）及其特殊召唤触发版本；注册②效果（墓地的起动效果，除外这张卡作为代价，1回合1次）。
function s.initial_effect(c)
	-- 记录这张卡上记载着「圣月之皇太子 雷古勒斯」（卡号96228804）的卡名。
	aux.AddCodeList(c,96228804)
	-- ①：这张卡召唤·特殊召唤的场合，以场上1张表侧表示卡为对象才能发动。那张卡回到手卡。这个卡名的①的效果1回合只能使用1次。
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
	-- ②：把墓地的这张卡除外才能发动。包含魔法卡的手卡的卡任意数量给对方观看，回到卡组。那之后，自己抽出回去的数量。这个卡名的②的效果1回合只能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"抽卡效果"
	e3:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCountLimit(1,id+o)
	-- 设定发动代价为把墓地的这张卡除外。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
end
-- ①效果的对象过滤条件：表侧表示且可以回到手卡的卡。
function s.thfilter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- ①效果发动条件的过滤条件：这张卡以外的表侧表示的「魔女术」怪兽或「圣月之皇太子 雷古勒斯」。
function s.cfilter(c)
	return not c:IsCode(id) and c:IsFaceup()
		and (c:IsSetCard(0x128) and c:IsType(TYPE_MONSTER) or c:IsCode(96228804))
end
-- ①效果的对象选择与发动条件判定：检查自己场上是否存在这张卡以外的「魔女术」怪兽或「圣月之皇太子 雷古勒斯」，且场上存在可以作为对象回到手卡的表侧表示卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.thfilter(chkc) end
	-- 发动条件判定：检查自己场上是否存在这张卡以外的「魔女术」怪兽或「圣月之皇太子 雷古勒斯」。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 发动条件判定：检查双方场上是否存在至少1张可以成为对象的表侧表示且能回到手卡的卡。
		and Duel.IsExistingTarget(s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家显示「请选择要返回手牌的卡」的选卡提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择场上1张表侧表示且能回到手卡的卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁的操作信息：确定要将1张卡回到手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果的处理：取得作为对象的卡，若该卡仍与这条连锁相关联，则以效果将其送回持有者的手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 以效果原因将对象卡送回持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ②效果可选择的卡的过滤条件：未公开且可以回到卡组的手卡的卡。
function s.tdfilter(c)
	return not c:IsPublic() and c:IsAbleToDeck()
end
-- ②效果必须包含的魔法卡的过滤条件：未公开且可以回到卡组的魔法卡。
function s.ctdfilter(c)
	return not c:IsPublic() and c:IsAbleToDeck() and c:IsType(TYPE_SPELL)
end
-- ②效果的发动条件判定：自己可以抽卡，且手卡中存在至少1张未公开且可以回到卡组的魔法卡。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：检查自己是否可以抽卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		-- 发动条件判定：检查手卡中是否存在至少1张未公开且可以回到卡组的魔法卡。
		and Duel.IsExistingMatchingCard(s.ctdfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 把当前连锁的对象玩家设置为自己。
	Duel.SetTargetPlayer(tp)
	-- 设置连锁的操作信息：预计将自己的手卡1张卡送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 选择子组的校验条件：所选卡组中必须包含至少1张未公开且可以回到卡组的魔法卡。
function s.gcheck(g)
	return g:IsExists(s.ctdfilter,1,nil)
end
-- ②效果的处理：取得对象玩家，从其手卡选出任意数量（至少1张且必须包含魔法卡）的未公开卡，给对方观看后送回卡组并洗牌，之后抽出实际回去的卡的数量。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象玩家（自己）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 取得自己手卡中全部未公开且可以回到卡组的卡。
	local g=Duel.GetMatchingGroup(s.tdfilter,p,LOCATION_HAND,0,nil)
	-- 向玩家显示「请选择要返回卡组的卡」的选卡提示。
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:SelectSubGroup(p,s.gcheck,false,1,g:GetCount())
	if not sg then return end
	Duel.ConfirmCards(1-p,sg)
	-- 以效果原因将选出的卡送回卡组并洗切。
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 手动洗切自己的卡组。
	Duel.ShuffleDeck(p)
	local ct=sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct>0 then
		-- 中断当前效果处理，使之后的抽卡与回卡组不同时处理（对应「那之后」）。
		Duel.BreakEffect()
		-- 以效果原因让自己抽出实际回到卡组的卡的数量。
		Duel.Draw(p,ct,REASON_EFFECT)
	end
end
