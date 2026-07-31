--ウィッチクラフト・シード
local s,id,o=GetID()
-- 初始化卡片效果：注册关联卡号96228804（骨塔）、①通召·特召成功弹场上卡弹手效果、②墓地除外自身洗手卡魔法滤牌效果
function s.initial_effect(c)
	-- 注册此卡效果记述的特定卡名「骨塔」（96228804）
	aux.AddCodeList(c,96228804)
	-- ①：这张卡召唤·特殊召唤成功的场合，以场上1张卡为对象才能发动。那张卡回到手卡。这个效果在自己场上有「魔妖」怪兽或者「骨塔」存在的场合才能发动和处理。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
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
	-- ②：把墓地的这张卡除外才能发动。从手卡选任意数量的卡在卡组洗牌（包含1张以上的魔法卡）。那之后，自己抽出洗牌的数量。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCountLimit(1,id+o)
	-- ②效果发动Cost：把墓地的这张卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
end
-- 弹手过滤条件：场上表侧表示且可回到手卡的卡
function s.thfilter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- 条件过滤：场上存在除自身以外的表侧表示「魔妖」怪兽或「骨塔」
function s.cfilter(c)
	return not c:IsCode(id) and c:IsFaceup()
		and (c:IsSetCard(0x128) and c:IsType(TYPE_MONSTER) or c:IsCode(96228804))
end
-- ①效果发动准备：检查场上是否有合规怪兽并取场上1张卡为对象
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.thfilter(chkc) end
	-- 发动条件检查：场上是否存在除自身外的表侧表示「魔妖」怪兽或「骨塔」
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查场上是否存在可作为弹手对象的卡
		and Duel.IsExistingTarget(s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上1张卡作为弹手对象
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息：将选中的卡回到手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果处理：将选中的目标卡回到手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将目标卡通过效果送回手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 洗卡过滤条件：手卡中未公开且可回到卡组的卡
function s.tdfilter(c)
	return not c:IsPublic() and c:IsAbleToDeck()
end
-- 必含卡过滤条件：手卡中未公开且可回到卡组的魔法卡
function s.ctdfilter(c)
	return not c:IsPublic() and c:IsAbleToDeck() and c:IsType(TYPE_SPELL)
end
-- ②效果发动准备：检查玩家是否能抽卡且手卡是否有可洗回的魔法卡
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：玩家是否具有抽卡资格
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		-- 检查手卡中是否存在可回到卡组的魔法卡
		and Duel.IsExistingMatchingCard(s.ctdfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置抽卡效果的目标玩家为己方
	Duel.SetTargetPlayer(tp)
	-- 设置连锁操作信息：从手卡将卡片回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 选卡组校验条件：选中的卡片组合中必须至少包含1张魔法卡
function s.gcheck(g)
	return g:IsExists(s.ctdfilter,1,nil)
end
-- ②效果处理：从手卡选择包含至少1张魔法卡的卡洗回卡组，并抽出相同数量的卡
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取手卡中所有可洗回卡组的未公开卡
	local g=Duel.GetMatchingGroup(s.tdfilter,p,LOCATION_HAND,0,nil)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:SelectSubGroup(p,s.gcheck,false,1,g:GetCount())
	if sg:GetCount()==0 then return end
	-- 向对方玩家确认选中的卡
	Duel.ConfirmCards(1-p,sg)
	-- 将选中的卡洗回卡组
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 洗切卡组
	Duel.ShuffleDeck(p)
	local ct=sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct>0 then
		-- 连接连续效果动作（洗卡与抽卡之间）
		Duel.BreakEffect()
		-- 抽取与洗回卡片数量相等的卡
		Duel.Draw(p,ct,REASON_EFFECT)
	end
end
