--魔救の奇石－ラプタイト
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡用「魔救」卡的效果特殊召唤成功的场合才能发动。从自己的手卡·墓地选1只岩石族怪兽回到卡组最上面。
-- ②：这张卡在墓地存在的场合，以自己的场上·墓地1只风属性同调怪兽为对象才能发动。那只怪兽回到持有者的额外卡组，这张卡回到卡组最上面。
function c74891384.initial_effect(c)
	-- ①：这张卡用「魔救」卡的效果特殊召唤成功的场合才能发动。从自己的手卡·墓地选1只岩石族怪兽回到卡组最上面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(74891384,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,74891384)
	e1:SetCondition(c74891384.dtcon1)
	e1:SetTarget(c74891384.dttg1)
	e1:SetOperation(c74891384.dtop1)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以自己的场上·墓地1只风属性同调怪兽为对象才能发动。那只怪兽回到持有者的额外卡组，这张卡回到卡组最上面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74891384,1))
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,74891385)
	e2:SetTarget(c74891384.dttg2)
	e2:SetOperation(c74891384.dtop2)
	c:RegisterEffect(e2)
end
-- 检查这张卡是否是由「魔救」卡的效果特殊召唤成功
function c74891384.dtcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSpecialSummonSetCard(0x140)
end
-- 过滤条件：岩石族怪兽且能回到卡组
function c74891384.dtfilter(c)
	return c:IsRace(RACE_ROCK) and c:IsAbleToDeck()
end
-- 效果①的发动准备（检查手卡·墓地是否存在岩石族怪兽，并设置操作信息为将卡回到卡组）
function c74891384.dttg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的手卡·墓地是否存在至少1只可以回到卡组的岩石族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c74891384.dtfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁的操作信息：将手卡或墓地的1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果①的效果处理（从手卡·墓地选1只岩石族怪兽回到卡组最上面，手卡的卡需要给对方确认，墓地的卡需要向对方展示）
function c74891384.dtop1(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从手卡·墓地选择1只满足条件的岩石族怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c74891384.dtfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		if tc:IsLocation(LOCATION_HAND) then
			-- 如果选中的卡在手卡，则给对方玩家确认该卡
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 如果选中的卡在墓地，则在场上/墓地中显式展示该卡
			Duel.HintSelection(g)
		end
		-- 将选中的怪兽回到持有者卡组的最上面
		Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
-- 过滤条件：场上表侧表示或墓地存在的风属性同调怪兽，且能回到额外卡组
function c74891384.texfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_SYNCHRO) and c:IsAbleToExtra()
end
-- 效果②的发动准备（选择场上·墓地1只风属性同调怪兽作为对象，并设置操作信息）
function c74891384.dttg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(tp) and c74891384.texfilter(chkc) and chkc~=c end
	-- 检查场上·墓地是否存在可以回到额外卡组的风属性同调怪兽，且自身能回到卡组
	if chk==0 then return Duel.IsExistingTarget(c74891384.texfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,c) and c:IsAbleToDeck() end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择场上·墓地1只风属性同调怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c74891384.texfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,c)
	-- 设置连锁的操作信息：将对象怪兽送回额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
	-- 设置连锁的操作信息：将这张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end
-- 效果②的效果处理（将作为对象的风属性同调怪兽回到额外卡组，若成功则将这张卡回到卡组最上面）
function c74891384.dtop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选为对象的卡
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡是否仍与效果相关，并将其送回额外卡组，若成功送回且自身仍与效果相关，则继续处理
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_EXTRA) and c:IsRelateToEffect(e) then
		-- 将这张卡回到持有者卡组的最上面
		Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
