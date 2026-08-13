--プランキッズ・プランク
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡丢弃1张「调皮宝贝」卡才能发动。在自己场上把1只「调皮宝贝衍生物」（炎族·炎·1星·攻/守0）特殊召唤。这衍生物不能解放。
-- ②：自己结束阶段以「调皮宝贝捣蛋记」以外的自己墓地3张「调皮宝贝」卡为对象才能发动。那3张卡加入卡组洗切。那之后，自己从卡组抽1张。
function c43664494.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：从手卡丢弃1张「调皮宝贝」卡才能发动。在自己场上把1只「调皮宝贝衍生物」（炎族·炎·1星·攻/守0）特殊召唤。这衍生物不能解放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43664494,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,43664494)
	e2:SetCost(c43664494.tkcost)
	e2:SetTarget(c43664494.tktg)
	e2:SetOperation(c43664494.tkop)
	c:RegisterEffect(e2)
	-- ②：自己结束阶段以「调皮宝贝捣蛋记」以外的自己墓地3张「调皮宝贝」卡为对象才能发动。那3张卡加入卡组洗切。那之后，自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(43664494,1))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,43664495)
	e3:SetCondition(c43664494.drcon)
	e3:SetTarget(c43664494.drtg)
	e3:SetOperation(c43664494.drop)
	c:RegisterEffect(e3)
end
-- 筛选满足「调皮宝贝」字段且可以丢弃的手卡，作为发动①效果的代价素材。
function c43664494.cfilter(c)
	return c:IsSetCard(0x120) and c:IsDiscardable()
end
-- ①效果的发动代价：从手卡选择1张满足「调皮宝贝」字段且可以丢弃的卡丢弃（同时作为COST和丢弃）。
function c43664494.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时合法性检查：确认自己手卡中是否存在至少1张满足「调皮宝贝」字段且可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c43664494.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 实际执行代价：让玩家自己从手卡选择1张满足条件且可以丢弃的卡，以COST+丢弃的理由丢弃。
	Duel.DiscardHand(tp,c43664494.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- ①效果发动时的目标/条件判断：检查自己主要怪兽区是否有空位，并且能否特殊召唤一只「调皮宝贝衍生物」到场上。
function c43664494.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的主要怪兽区是否存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己是否能够以表侧表示特殊召唤一只「调皮宝贝衍生物」（炎族·炎·1星·攻/守0）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,43664495,0x120,TYPES_TOKEN_MONSTER,0,0,1,RACE_PYRO,ATTRIBUTE_FIRE,POS_FACEUP) end
	-- 设置本次操作包含衍生物特殊召唤，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置本次操作包含特殊召唤，数量为1，操作玩家为自己。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
-- ①效果处理：在自己场上特殊召唤1只「调皮宝贝衍生物」，并赋予其不能解放的效果，最后完成特殊召唤。
function c43664494.tkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时再次确认主要怪兽区是否有空位，若没有则特殊召唤失败。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 效果处理时再次确认是否仍能特殊召唤衍生物，若不能则中止处理。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,43664495,0x120,TYPES_TOKEN_MONSTER,0,0,1,RACE_PYRO,ATTRIBUTE_FIRE,POS_FACEUP) then return end
	-- 创建1只卡号为43664495的「调皮宝贝衍生物」Token。
	local token=Duel.CreateToken(tp,43664495)
	-- 将该衍生物以表侧攻击表示特殊召唤到自己的主要怪兽区（特殊召唤步骤，尚未最终成功）。
	Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	-- 『这衍生物不能解放。』②：自己结束阶段以「调皮宝贝捣蛋记」以外的自己墓地3张「调皮宝贝」卡为对象才能发动。那3张卡加入卡组洗切。那之后，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	token:RegisterEffect(e1,true)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	token:RegisterEffect(e2,true)
	-- 结束特殊召唤步骤，确认上述特殊召唤正式成功。
	Duel.SpecialSummonComplete()
end
-- ②效果的发动条件：只有在自己回合的结束阶段才能发动。
function c43664494.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己，即必须是自己回合的结束阶段。
	return Duel.GetTurnPlayer()==tp
end
-- 筛选墓地中满足「调皮宝贝」字段、卡名不是「调皮宝贝捣蛋记」、且可以返回卡组的卡。
function c43664494.tdfilter(c)
	return c:IsSetCard(0x120) and not c:IsCode(43664494) and c:IsAbleToDeck()
end
-- ②效果发动时的目标/条件判断：确认自己可以抽1张卡，并且墓地存在至少3张符合条件的「调皮宝贝」卡可作为对象。
function c43664494.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c43664494.tdfilter(chkc) end
	-- 确认自己是否允许通过效果抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 确认自己墓地中是否存在至少3张符合条件的「调皮宝贝」卡可供选择为对象。
		and Duel.IsExistingTarget(c43664494.tdfilter,tp,LOCATION_GRAVE,0,3,nil) end
	-- 向玩家弹出选择提示，提示文字为“请选择要返回卡组的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己墓地选择3张满足条件的「调皮宝贝」卡作为②效果的对象。
	local g=Duel.SelectTarget(tp,c43664494.tdfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	-- 设置操作信息：将选中的对象卡返回卡组，数量为实际选择数。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置操作信息：之后自己抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果处理：将对象卡返回卡组并洗切，然后抽1张卡。
function c43664494.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡，并筛选出仍与当前效果相关的卡（未被其他效果移动或离开墓地等）。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=3 then return end
	-- 将仍然有效的对象卡返回持有者卡组顶/底并标记需要洗切，同时作为卡组洗切的标志。
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 取得刚才实际被送回卡组的卡片组，用于后续判断是否成功洗牌。
	local g=Duel.GetOperatedGroup()
	-- 如果实际返回卡组的卡中有卡进入了主卡组，则洗切自己的卡组。
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct>0 then
		-- 中断当前效果处理，使接下来的抽卡视为不同时点处理，避免错过时点。
		Duel.BreakEffect()
		-- 效果处理最后，自己从卡组抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
