--ハーピィの羽根休め
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己墓地的「鹰身女郎」「鹰身女郎三姐妹」之中以合计3只为对象才能发动。那些卡加入卡组洗切。那之后，自己从卡组抽1张。自己场上有5星以上的「鹰身」怪兽存在的状态发动的场合抽出的数量变成2张。这张卡的发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤。
function c39275698.initial_effect(c)
	-- 将鹰身女郎三姐妹的卡号记录在本卡的代码列表中，表明本卡效果文本涉及该卡名，供规则/文本提示使用。
	aux.AddCodeList(c,12206212)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己墓地的「鹰身女郎」「鹰身女郎三姐妹」之中以合计3只为对象才能发动。那些卡加入卡组洗切。那之后，自己从卡组抽1张。自己场上有5星以上的「鹰身」怪兽存在的状态发动的场合抽出的数量变成2张。这张卡的发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c39275698.drtg)
	e1:SetOperation(c39275698.drop)
	e1:SetCountLimit(1,39275698+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
-- 定义墓地对象的筛选条件：卡名是「鹰身女郎」或「鹰身女郎三姐妹」，并且可以返回卡组。
function c39275698.drfilter(c)
	return c:IsCode(76812113,12206212) and c:IsAbleToDeck()
end
-- 定义判定条件：自己场上有表侧表示的、卡名含有「鹰身」字段的5星以上怪兽。
function c39275698.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x64) and c:IsLevelAbove(5)
end
-- 效果发动的目标处理：根据场上是否有5星以上的「鹰身」怪兽决定抽卡数量；从自己墓地选择合计3只符合条件的「鹰身女郎」「鹰身女郎三姐妹」作为对象；设置回卡组和抽卡的操作信息。
function c39275698.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=1
	-- 检查自己场上是否存在至少1只表侧表示5星以上的「鹰身」怪兽，若存在则将抽卡数改为2张。
	if Duel.IsExistingMatchingCard(c39275698.ctfilter,tp,LOCATION_MZONE,0,1,nil) then ct=2 end
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39275698.drfilter(chkc) end
	-- 发动合法性检查：自己能够按判定数量抽卡，且墓地存在至少3只符合条件的对象卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,ct) and Duel.IsExistingTarget(c39275698.drfilter,tp,LOCATION_GRAVE,0,3,nil) end
	-- 向操作者显示“请选择要返回卡组的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己墓地选择3张符合条件的「鹰身女郎」「鹰身女郎三姐妹」作为效果的对象。
	local g=Duel.SelectTarget(tp,c39275698.drfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	e:SetLabel(ct)
	-- 设置操作信息：将选择的对象卡送回卡组，数量为对象数量。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置操作信息：自己将进行抽卡，抽卡数量为ct（1或2）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- 效果处理：将对象卡返回卡组并洗切，随后抽对应数量的卡；之后给己方附加直到回合结束不能特殊召唤风属性以外怪兽的限制。
function c39275698.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡，并筛选出仍与该效果有关联（未被无效、未离场重置联系）的卡。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #tg~=0 then
		-- 将对象卡以效果原因送回持有者卡组，并指定需要洗切（SEQ_DECKSHUFFLE）。
		Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 取得刚才被送回卡组的实际卡片组，用于确认处理结果。
		local g=Duel.GetOperatedGroup()
		-- 若存在被送回卡组的卡，则洗切己方卡组。
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
		local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
		if ct>0 then
			-- 中断当前效果处理，使后续抽卡作为另一次独立处理，避免错失时点。
			Duel.BreakEffect()
			-- 自己抽取与效果标签中记录数量（ct）相同的卡（1张或2张）。
			Duel.Draw(tp,e:GetLabel(),REASON_EFFECT)
		end
	end
	local c=e:GetHandler()
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c39275698.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将“不是风属性怪兽不能特殊召唤”的制约效果注册给发动玩家，持续到回合结束。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制条件：被特殊召唤的怪兽若不是风属性，则不能进行特殊召唤。
function c39275698.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WIND)
end
