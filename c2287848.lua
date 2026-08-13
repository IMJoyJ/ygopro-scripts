--ヴェンデット・リバース
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：丢弃1张手卡，以自己墓地1只「复仇死者」怪兽和1张仪式魔法卡为对象才能发动。那只怪兽守备表示特殊召唤，那张仪式魔法卡加入手卡。
-- ②：把墓地的这张卡除外，以除外的5只自己的不死族怪兽为对象才能发动。那些怪兽加入卡组洗切。那之后，自己从卡组抽1张。
function c2287848.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：丢弃1张手卡，以自己墓地1只「复仇死者」怪兽和1张仪式魔法卡为对象才能发动。那只怪兽守备表示特殊召唤，那张仪式魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,2287848)
	e1:SetCost(c2287848.cost)
	e1:SetTarget(c2287848.target)
	e1:SetOperation(c2287848.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以除外的5只自己的不死族怪兽为对象才能发动。那些怪兽加入卡组洗切。那之后，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,2287849)
	-- 为②效果设置发动代价：把墓地中的这张卡除外；aux.bfgcost负责检查并执行除外代价。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c2287848.drtg)
	e2:SetOperation(c2287848.drop)
	c:RegisterEffect(e2)
end
-- ①效果的代价函数：先检查手牌中是否有可丢弃的卡，若有则选择1张手牌丢弃作为发动代价。
function c2287848.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段：确认自己手牌中存在至少1张可以丢弃的卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行代价：从自己手牌选择1张卡丢弃，丢弃理由标记为COST（代价）和DISCARD（丢弃）。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 特殊召唤对象筛选：选择自己墓地中属于「复仇死者」字段、且可以被当前效果以表侧守备表示特殊召唤的怪兽。
function c2287848.spfilter(c,e,tp)
	return c:IsSetCard(0x106) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 加入手牌对象筛选：选择自己墓地中类型为仪式魔法卡、且可以被加入手牌的卡。
function c2287848.thfilter(c)
	return c:GetType()==TYPE_SPELL+TYPE_RITUAL and c:IsAbleToHand()
end
-- ①效果发动时的对象选择与合法性检查：需要己方主要怪兽区域有空位，且墓地存在1只符合条件的「复仇死者」怪兽和1张仪式魔法卡，并指定它们为对象。
function c2287848.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 合法性检查：己方主要怪兽区域有空位，且墓地存在至少1只符合条件的「复仇死者」怪兽可成为对象。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(c2287848.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 继续合法性检查：墓地存在至少1张符合条件的仪式魔法卡可成为对象。
		and Duel.IsExistingTarget(c2287848.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示选择提示，要求玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只符合条件的「复仇死者」怪兽作为效果对象，并自动设为当前连锁的对象。
	local g1=Duel.SelectTarget(tp,c2287848.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	e:SetLabelObject(g1:GetFirst())
	-- 显示选择提示，要求玩家选择要加入手牌的仪式魔法卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选择1张符合条件的仪式魔法卡作为效果对象。
	local g2=Duel.SelectTarget(tp,c2287848.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：本连锁后续会特殊召唤g1中的对象怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,1,0,0)
	-- 设置操作信息：本连锁后续会将g2中的对象仪式魔法卡加入手牌，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g2,1,0,0)
end
-- ①效果处理函数：取出两个对象，先确认怪兽对象可特殊召唤并成功表侧守备特殊召唤，且魔法卡对象仍关联时，将魔法卡加入手牌。
function c2287848.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的两个对象卡，按顺序赋给tc1和tc2。
	local tc1,tc2=Duel.GetFirstTarget()
	if tc1~=e:GetLabelObject() then tc1,tc2=tc2,tc1 end
	-- 若tc1仍与效果关联，则将其表侧守备表示特殊召唤；特殊召唤成功且tc2仍与效果关联时，才继续处理加入手牌。
	if tc1:IsRelateToEffect(e) and Duel.SpecialSummon(tc1,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 and tc2:IsRelateToEffect(e) then
		-- 将仪式魔法卡对象加入其持有者的手卡，处理原因为效果。
		Duel.SendtoHand(tc2,nil,REASON_EFFECT)
	end
end
-- ②效果的对象筛选：选择除外状态中表侧表示、种族为不死族、且能够返回卡组的自己的怪兽。
function c2287848.drfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsAbleToDeck()
end
-- ②效果发动时的对象选择与合法性检查：需要自己可以抽1张卡，且除外区存在至少5只符合条件的自己的不死族怪兽，并指定其中5只为对象。
function c2287848.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c2287848.drfilter(chkc) end
	-- 合法性检查：玩家tp可以进行1张卡的抽卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 继续合法性检查：除外区存在至少5只表侧表示、不死族、且可返回卡组的自己的怪兽，可以作为对象。
		and Duel.IsExistingTarget(c2287848.drfilter,tp,LOCATION_REMOVED,0,5,nil) end
	-- 显示选择提示，要求玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己除外状态的符合条件的怪兽中选择5只作为效果对象，并设为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c2287848.drfilter,tp,LOCATION_REMOVED,0,5,5,nil)
	-- 设置操作信息：本连锁后续会将对象5张卡返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,5,0,0)
	-- 设置操作信息：本连锁后续会让玩家tp抽1张卡（目标玩家tp，数量1）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果处理函数：将对象怪兽返回卡组并洗切；若确实有卡返回卡组，则洗牌后再抽1张卡。
function c2287848.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡组（即发动时选择的5只不死族怪兽）。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)<=0 then return end
	-- 将所有对象卡返回持有者卡组并标记需要洗切，处理原因为效果。
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 取得刚才实际被返回卡组的卡片组，用于判断处理结果。
	local g=Duel.GetOperatedGroup()
	-- 若返回后的卡中有卡位于卡组，则洗切玩家tp的卡组。
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct>0 then
		-- 中断当前效果处理，使之后的抽卡与返回卡组洗切分开处理，避免错失时点。
		Duel.BreakEffect()
		-- 玩家tp因效果抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
