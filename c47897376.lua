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
-- 效果①的发动条件：判定这张卡是否为「魔救」卡的效果特殊召唤成功。
function c47897376.dtcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSpecialSummonSetCard(0x140)
end
-- 效果①选择回卡组目标的筛选函数：是「魔救」系列卡且可以返回卡组。
function c47897376.dtfilter(c)
	return c:IsSetCard(0x140) and c:IsAbleToDeck()
end
-- 效果①的发动目标处理：发动时确认己方手卡·墓地存在至少1张「魔救」卡，并登记将1张卡返回卡组的操作信息。
function c47897376.dttg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果①发动合法性检查：己方手卡·墓地是否存在至少1张符合条件的「魔救」卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c47897376.dtfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	-- 登记效果①的处理信息：将1张来自手卡·墓地的卡返回持有者卡组，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果①的处理：玩家从手卡·墓地选择1张「魔救」卡，若来自手卡则向对方展示，来自墓地则显示选中动画，最后将其返回卡组最顶端。
function c47897376.dtop1(e,tp,eg,ep,ev,re,r,rp)
	-- 给予玩家“请选择要返回卡组的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家从己方手卡·墓地选择1张符合条件的「魔救」卡，并应用王家长眠之谷的过滤（墓地的卡不能受其影响而无法回卡组）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c47897376.dtfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		if tc:IsLocation(LOCATION_HAND) then
			-- 选择的卡来自手卡时，向对方玩家公开确认这张卡。
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 选择的卡来自墓地时，为其显示被选中的动画并记录选择标记。
			Duel.HintSelection(g)
		end
		-- 将选择的卡以效果原因返回持有者卡组最顶端。
		Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
-- 效果②对象的筛选函数：自己场上表侧表示或自己墓地的炎属性同调怪兽，且能够返回额外卡组。
function c47897376.texfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsType(TYPE_SYNCHRO) and c:IsAbleToExtra()
end
-- 效果②的发动目标处理：选择自己场上·墓地1只炎属性同调怪兽为对象（不能选自身），并确认自身可回卡组；登记对象回额外卡组和自身回卡组的信息。
function c47897376.dttg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(tp) and c47897376.texfilter(chkc) and chkc~=c end
	-- 效果②发动合法性检查：自己场上·墓地存在可能作为对象的炎属性同调怪兽，且这张卡自身能够返回卡组，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c47897376.texfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,c) and c:IsAbleToDeck() end
	-- 给予玩家“请选择效果的对象”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家从自己场上·墓地选择1只符合条件的炎属性同调怪兽作为对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c47897376.texfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,c)
	-- 登记将所选择对象怪兽返回额外卡组的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
	-- 登记将这张卡自身返回卡组的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end
-- 效果②的处理：将对象怪兽返回持有者额外卡组；若该操作成功且这张卡仍与效果关联，则再将自身返回卡组最顶端。
function c47897376.dtop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果②选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判定对象怪兽仍与效果关联，若关联则将其返回持有者额外卡组，并检查返回成功、对象确实在额外卡组且这张卡自身仍与效果关联；全部满足才继续后续回卡组效果。
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_EXTRA) and c:IsRelateToEffect(e) then
		-- 将效果②的这张卡从墓地返回持有者卡组最顶端。
		Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
