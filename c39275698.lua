--ハーピィの羽根休め
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己墓地的「鹰身女郎」「鹰身女郎三姐妹」之中以合计3只为对象才能发动。那些卡加入卡组洗切。那之后，自己从卡组抽1张。自己场上有5星以上的「鹰身」怪兽存在的状态发动的场合抽出的数量变成2张。这张卡的发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤。
function c39275698.initial_effect(c)
	-- 注册此卡的额外卡名代码，用于识别其关联的「鹰身女郎三姐妹」卡
	aux.AddCodeList(c,12206212)
	-- ①：从自己墓地的「鹰身女郎」「鹰身女郎三姐妹」之中以合计3只为对象才能发动。那些卡加入卡组洗切。那之后，自己从卡组抽1张。自己场上有5星以上的「鹰身」怪兽存在的状态发动的场合抽出的数量变成2张。这张卡的发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤。
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
-- 过滤函数，用于判断墓地中的卡是否为「鹰身女郎」或「鹰身女郎三姐妹」且可以送入卡组
function c39275698.drfilter(c)
	return c:IsCode(76812113,12206212) and c:IsAbleToDeck()
end
-- 过滤函数，用于判断场上是否有5星以上的「鹰身」怪兽
function c39275698.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x64) and c:IsLevelAbove(5)
end
-- 效果处理的初始化函数，检查是否满足发动条件并选择目标卡片
function c39275698.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=1
	-- 若场上存在5星以上的「鹰身」怪兽，则将抽卡数量设为2张
	if Duel.IsExistingMatchingCard(c39275698.ctfilter,tp,LOCATION_MZONE,0,1,nil) then ct=2 end
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39275698.drfilter(chkc) end
	-- 检查是否可以抽卡且墓地是否存在3张符合条件的卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,ct) and Duel.IsExistingTarget(c39275698.drfilter,tp,LOCATION_GRAVE,0,3,nil) end
	-- 提示玩家选择要送入卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择3张符合条件的墓地卡片作为效果对象
	local g=Duel.SelectTarget(tp,c39275698.drfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	e:SetLabel(ct)
	-- 设置效果操作信息，标记将要送入卡组的卡片
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置效果操作信息，标记将要进行的抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- 效果处理函数，执行送卡组、洗卡组、抽卡及设置不能特殊召唤风属性怪兽的效果
function c39275698.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中被选择的目标卡片组，并筛选出与当前效果相关的卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #tg~=0 then
		-- 将目标卡片送入卡组并洗切
		Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 获取实际被操作的卡片组
		local g=Duel.GetOperatedGroup()
		-- 若送入卡组的卡片中有位于卡组的，则进行卡组洗切
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
		local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
		if ct>0 then
			-- 中断当前效果处理，使后续效果视为错时处理
			Duel.BreakEffect()
			-- 根据设定的抽卡数量进行抽卡
			Duel.Draw(tp,e:GetLabel(),REASON_EFFECT)
		end
	end
	local c=e:GetHandler()
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c39275698.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将设置的不能特殊召唤效果注册到场上
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制不能特殊召唤非风属性的怪兽
function c39275698.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WIND)
end
