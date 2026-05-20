--花札衛－柳－
-- 效果：
-- ①：自己场上有10星以下的「花札卫」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不是「花札卫」怪兽不能召唤·特殊召唤。
-- ②：1回合1次，以自己墓地1只「花札卫」怪兽为对象才能发动。那只怪兽加入卡组洗切。那之后，自己从卡组抽1张。
function c54135423.initial_effect(c)
	-- ①：自己场上有10星以下的「花札卫」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不是「花札卫」怪兽不能召唤·特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c54135423.spcon)
	e1:SetTarget(c54135423.sptg)
	e1:SetOperation(c54135423.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以自己墓地1只「花札卫」怪兽为对象才能发动。那只怪兽加入卡组洗切。那之后，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c54135423.target)
	e2:SetOperation(c54135423.operation)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示的10星以下的「花札卫」怪兽
function c54135423.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe6) and c:IsLevelBelow(10)
end
-- 特殊召唤效果的发动条件
function c54135423.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的10星以下的「花札卫」怪兽
	return Duel.IsExistingMatchingCard(c54135423.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤效果的发动准备
function c54135423.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理
function c54135423.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己不是「花札卫」怪兽不能召唤·特殊召唤。②：1回合1次，以自己墓地1只「花札卫」怪兽为对象才能发动。那只怪兽加入卡组洗切。那之后，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c54135423.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤非「花札卫」怪兽的玩家效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	-- 注册不能召唤非「花札卫」怪兽的玩家效果
	Duel.RegisterEffect(e2,tp)
end
-- 限制只能召唤·特殊召唤「花札卫」怪兽
function c54135423.splimit(e,c)
	return not c:IsSetCard(0xe6)
end
-- 过滤自己墓地可以返回卡组的「花札卫」怪兽
function c54135423.filter(c)
	return c:IsSetCard(0xe6) and c:IsAbleToDeck()
end
-- 抽卡并返回卡组效果的发动准备
function c54135423.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c54135423.filter(chkc) end
	-- 检查玩家是否能抽卡，以及自己墓地是否存在可以返回卡组的「花札卫」怪兽
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingTarget(c54135423.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1只「花札卫」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c54135423.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置将目标怪兽送回卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置抽1张卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡并返回卡组效果的处理
function c54135423.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=1 then return end
	-- 将目标怪兽送回卡组
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取上一步实际操作（送回卡组）的卡片组
	local g=Duel.GetOperatedGroup()
	-- 如果目标怪兽成功返回卡组，则洗切卡组
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==1 then
		-- 使后续的抽卡处理与返回卡组处理不同时进行
		Duel.BreakEffect()
		-- 玩家从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
