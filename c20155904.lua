--十二獣クックル
-- 效果：
-- ①：这张卡被战斗·效果破坏的场合，以「十二兽 鸡拳」以外的自己墓地1张「十二兽」卡为对象才能发动。那张卡回到卡组。
-- ②：持有这张卡作为素材中的原本种族是兽战士族的超量怪兽得到以下效果。
-- ●这张卡为对象的对方怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效。
function c20155904.initial_effect(c)
	-- ①：这张卡被战斗·效果破坏的场合，以「十二兽 鸡拳」以外的自己墓地1张「十二兽」卡为对象才能发动。那张卡回到卡组。
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
	-- ②：持有这张卡作为素材中的原本种族是兽战士族的超量怪兽得到以下效果。●这张卡为对象的对方怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效。
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
-- 判断这张卡被破坏的原因是否为战斗破坏或效果破坏，满足①效果的发动条件。
function c20155904.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 定义①效果可选择的对象：自己墓地中满足「十二兽」字段、卡名不是「十二兽 鸡拳」、且可以返回卡组的卡。
function c20155904.tdfilter(c)
	return c:IsSetCard(0xf1) and not c:IsCode(20155904) and c:IsAbleToDeck()
end
-- ①效果的发动时点处理：从自己墓地选择1张符合条件的「十二兽」卡作为对象，并设置回卡组的操作信息。
function c20155904.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c20155904.tdfilter(chkc) end
	-- 发动合法性检查：确认自己墓地存在至少1张符合条件的「十二兽」卡（除自身）可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c20155904.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出选择卡片的提示消息，提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己墓地选择1张符合条件的「十二兽」卡作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c20155904.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置本次连锁的操作信息，将对象卡标记为回卡组（CATEGORY_TODECK），用于后续效果处理及相关判定。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- ①效果的处理：取得对象卡，若其仍与效果关联，则将其返回持有者卡组并洗牌。
function c20155904.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的第一个对象卡，即玩家选择的那张墓地「十二兽」卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡送回持有者卡组，并洗切卡组。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- ②效果的发动条件：持有这张卡的超量怪兽原本种族为兽战士族、不处于战斗破坏状态，且对方怪兽效果发动以这张卡为对象、该发动可被无效。
function c20155904.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetOriginalRace()==RACE_BEASTWARRIOR
		and not c:IsStatus(STATUS_BATTLE_DESTROYED) and ep==1-tp
		-- 进一步确认对方发动的效果为怪兽效果，且该连锁的发动可以被无效。
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
		and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
		-- 获取对方发动效果时选择的对象卡组，确保该效果确实拥有对象（非空）。
		and Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
		-- 确认对方效果的对象列表中包含这张卡，即这张卡是对方怪兽效果的对象。
		and Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):IsContains(c)
end
-- ②效果的发动代价：取除这张卡（作为超量素材的这张卡）的1个超量素材；先检查是否可取除，再实际取除。
function c20155904.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ②效果的目标处理：发动时无需选择对象，设置无效发动的操作信息，并向对方玩家宣告效果发动。
function c20155904.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示“我方发动了该效果”，显示效果描述。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置本次连锁的操作信息，将对方发动的效果标记为需要无效化（CATEGORY_NEGATE）。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- ②效果的处理：无效对方发动的那个效果。
function c20155904.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 实际执行无效对方那个怪兽效果的发动。
	Duel.NegateActivation(ev)
end
