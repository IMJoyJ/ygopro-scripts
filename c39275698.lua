--ハーピィの羽根休め
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己墓地的「鹰身女郎」「鹰身女郎三姐妹」之中以合计3只为对象才能发动。那些卡加入卡组洗切。那之后，自己从卡组抽1张。自己场上有5星以上的「鹰身」怪兽存在的状态发动的场合抽出的数量变成2张。这张卡的发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤。
function c39275698.initial_effect(c)
	-- 记录该卡效果文上记载了「鹰身女郎」「鹰身女郎三姐妹」的卡名
	aux.AddCodeList(c,76812113,12206212)
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
-- 过滤条件函数：筛选卡名为「鹰身女郎」或「鹰身女郎三姐妹」且可以返回卡组的卡
function c39275698.drfilter(c)
	return c:IsCode(76812113,12206212) and c:IsAbleToDeck()
end
-- 过滤条件函数：筛选场上表侧表示、等级5以上的「鹰身」怪兽
function c39275698.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x64) and c:IsLevelAbove(5)
end
-- ①效果的目标选择与检查函数：判定抽卡数量（1张或2张），确认玩家可抽卡且墓地有3只目标怪兽，选择3只作为对象并登记回卡组与抽卡的操作信息
function c39275698.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=1
	-- 检查自己场上是否存在5星以上的表侧表示「鹰身」怪兽，若存在则将本次抽卡数量设为2张
	if Duel.IsExistingMatchingCard(c39275698.ctfilter,tp,LOCATION_MZONE,0,1,nil) then ct=2 end
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39275698.drfilter(chkc) end
	-- 发动条件检查：确认玩家能够效果抽指定数量的卡，且自己墓地存在至少3只可成为对象的目标怪兽
	if chk==0 then return Duel.IsPlayerCanDraw(tp,ct) and Duel.IsExistingTarget(c39275698.drfilter,tp,LOCATION_GRAVE,0,3,nil) end
	-- 向玩家发送选择提示：请选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己墓地选择合计3只「鹰身女郎」或「鹰身女郎三姐妹」作为对象
	local g=Duel.SelectTarget(tp,c39275698.drfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	e:SetLabel(ct)
	-- 向系统登记操作信息：将会把所选对象的3张卡加入卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 向系统登记操作信息：玩家将会从卡组抽1张或2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- ①效果的处理函数：将仍与效果关联的对象怪兽加入卡组并洗切，若至少有1张进入卡组或额外卡组则随后抽卡，最后为发动者施加直到回合结束时只能特殊召唤风属性怪兽的限制
function c39275698.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中全部对象卡，并筛选出当前仍与该效果关联的卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #tg~=0 then
		-- 将对象怪兽以效果加入持有者卡组并标记洗牌
		Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 获取刚才实际执行了返回卡组操作的卡片组
		local g=Duel.GetOperatedGroup()
		-- 若实际回到自己主卡组的卡至少有1张，则立刻执行洗切卡组
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
		local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
		if ct>0 then
			-- 中断当前处理，将加入卡组洗切与后续抽卡分为不同时点依次处理
			Duel.BreakEffect()
			-- 按照发动时记录的抽卡数量，让玩家以效果从卡组抽卡
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
		-- 为发动玩家注册持续至回合结束时的特召限制效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 特殊召唤限制条件函数：禁止特殊召唤非风属性的怪兽
function c39275698.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WIND)
end
