--魔救の奇石－レオナイト
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡用「魔救」卡的效果特殊召唤成功的场合才能发动。从自己的手卡·墓地选1张「魔救」卡回到卡组最上面。
-- ②：这张卡在墓地存在的场合，以自己的场上·墓地1只炎属性同调怪兽为对象才能发动。那只怪兽回到持有者的额外卡组，这张卡回到卡组最上面。
function c47897376.initial_effect(c)
	-- ①：这张卡用「魔救」卡的效果特殊召唤成功的场合才能发动。从自己的手卡·墓地选1张「魔救」卡回到卡组最上面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47897376,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,47897376)
	e1:SetCondition(c47897376.dtcon1)
	e1:SetTarget(c47897376.dttg1)
	e1:SetOperation(c47897376.dtop1)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以自己的场上·墓地1只炎属性同调怪兽为对象才能发动。那只怪兽回到持有者的额外卡组，这张卡回到卡组最上面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47897376,1))
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,47897377)
	e2:SetTarget(c47897376.dttg2)
	e2:SetOperation(c47897376.dtop2)
	c:RegisterEffect(e2)
end
-- 效果适用的条件：此卡是通过「魔救」卡的效果特殊召唤成功的
function c47897376.dtcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSpecialSummonSetCard(0x140)
end
-- 过滤函数：选择满足「魔救」系列且可以送回卡组的卡片
function c47897376.dtfilter(c)
	return c:IsSetCard(0x140) and c:IsAbleToDeck()
end
-- 效果的发动条件判断：确认自己手牌或墓地有至少1张「魔救」卡
function c47897376.dttg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果的发动条件判断：确认自己手牌或墓地有至少1张「魔救」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c47897376.dtfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁操作信息：准备将1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理函数：选择并执行将「魔救」卡送回卡组的操作
function c47897376.dtop1(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从手牌或墓地选择满足条件的「魔救」卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c47897376.dtfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		if tc:IsLocation(LOCATION_HAND) then
			-- 向对方确认所选卡片
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 显示被选为对象的卡片动画
			Duel.HintSelection(g)
		end
		-- 将选中的卡送回卡组顶端
		Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
-- 过滤函数：选择满足炎属性、同调类型且可以送回额外卡组的怪兽
function c47897376.texfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsType(TYPE_SYNCHRO) and c:IsAbleToExtra()
end
-- 效果的发动条件判断：确认自己场上或墓地有至少1只炎属性同调怪兽，并且此卡可以送回卡组
function c47897376.dttg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(tp) and c47897376.texfilter(chkc) and chkc~=c end
	-- 效果的发动条件判断：确认自己场上或墓地有至少1只炎属性同调怪兽，并且此卡可以送回卡组
	if chk==0 then return Duel.IsExistingTarget(c47897376.texfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,c) and c:IsAbleToDeck() end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的炎属性同调怪兽作为对象
	local g=Duel.SelectTarget(tp,c47897376.texfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,c)
	-- 设置连锁操作信息：准备将目标怪兽送回额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
	-- 设置连锁操作信息：准备将此卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end
-- 效果处理函数：执行将目标怪兽送回额外卡组并使此卡送回卡组的操作
function c47897376.dtop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽和此卡都有效且可以进行送卡操作
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_EXTRA) and c:IsRelateToEffect(e) then
		-- 将此卡送回卡组顶端
		Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
