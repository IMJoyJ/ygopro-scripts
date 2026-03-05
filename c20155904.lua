--十二獣クックル
-- 效果：
-- ①：这张卡被战斗·效果破坏的场合，以「十二兽 鸡拳」以外的自己墓地1张「十二兽」卡为对象才能发动。那张卡回到卡组。
-- ②：持有这张卡作为素材中的原本种族是兽战士族的超量怪兽得到以下效果。
-- ●这张卡为对象的对方怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效。
function c20155904.initial_effect(c)
	-- 效果原文：①：这张卡被战斗·效果破坏的场合，以「十二兽 鸡拳」以外的自己墓地1张「十二兽」卡为对象才能发动。那张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20155904,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c20155904.tdcon)
	e1:SetTarget(c20155904.tdtg)
	e1:SetOperation(c20155904.tdop)
	c:RegisterEffect(e1)
	-- 效果原文：②：持有这张卡作为素材中的原本种族是兽战士族的超量怪兽得到以下效果。●这张卡为对象的对方怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20155904,1))
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(c20155904.discon)
	e2:SetCost(c20155904.discost)
	e2:SetTarget(c20155904.distg)
	e2:SetOperation(c20155904.disop)
	c:RegisterEffect(e2)
end
-- 规则层面：判断破坏原因是否为战斗或效果破坏
function c20155904.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 规则层面：定义可用于选择的墓地「十二兽」卡的过滤条件
function c20155904.tdfilter(c)
	return c:IsSetCard(0xf1) and not c:IsCode(20155904) and c:IsAbleToDeck()
end
-- 规则层面：设置选择目标卡的条件并执行选择操作
function c20155904.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c20155904.tdfilter(chkc) end
	-- 规则层面：检查是否存在满足条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(c20155904.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 规则层面：向玩家提示选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 规则层面：执行选择目标卡的操作
	local g=Duel.SelectTarget(tp,c20155904.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 规则层面：设置效果处理信息，指定将要返回卡组的卡
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 规则层面：执行将目标卡返回卡组的操作
function c20155904.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 规则层面：将目标卡送回卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 规则层面：判断是否满足无效对方怪兽效果发动的条件
function c20155904.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetOriginalRace()==RACE_BEASTWARRIOR
		and not c:IsStatus(STATUS_BATTLE_DESTROYED) and ep==1-tp
		-- 规则层面：判断连锁效果是否为怪兽类型且可被无效
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
		and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
		-- 规则层面：获取连锁效果的目标卡组信息
		and Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
		-- 规则层面：判断当前卡是否为连锁效果的目标之一
		and Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):IsContains(c)
end
-- 规则层面：设置消耗超量素材作为发动代价
function c20155904.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 规则层面：设置无效对方效果发动的处理信息
function c20155904.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面：向对方提示发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 规则层面：设置效果处理信息，指定将要无效的效果
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 规则层面：执行使对方效果发动无效的操作
function c20155904.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：使当前连锁效果无效
	Duel.NegateActivation(ev)
end
