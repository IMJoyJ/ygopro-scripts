--パラメタルフォーゼ・アゾートレス
-- 效果：
-- ←8 【灵摆】 8→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己场上的表侧表示的「炼装」卡被效果破坏的场合，以场上1张表侧表示的卡为对象才能发动。那张卡破坏。
-- 【怪兽效果】
-- 「炼装」怪兽＋融合怪兽
-- 这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：这张卡从额外卡组的特殊召唤成功的场合，以对方场上1张卡为对象才能发动。从自己的额外卡组让2只表侧表示的灵摆怪兽回到卡组，作为对象的卡破坏。
-- ②：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
function c37491810.initial_effect(c)
	c:EnableReviveLimit()
	-- 使这张卡获得灵摆怪兽属性（可进行灵摆召唤、作为灵摆卡发动），但不注册灵摆卡“卡的发动”的效果。
	aux.EnablePendulumAttribute(c,false)
	-- 为这张卡添加融合召唤手续：可以用满足条件的“炼装”怪兽和融合怪兽各1只作为融合素材。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xe1),aux.FilterBoolFunction(Card.IsFusionType,TYPE_FUSION),true)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：自己场上的表侧表示的「炼装」卡被效果破坏的场合，以场上1张表侧表示的卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37491810,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,37491810)
	e1:SetCondition(c37491810.despcon)
	e1:SetTarget(c37491810.desptg)
	e1:SetOperation(c37491810.despop)
	c:RegisterEffect(e1)
	-- 这个卡名的①的怪兽效果1回合只能使用1次。①：这张卡从额外卡组的特殊召唤成功的场合，以对方场上1张卡为对象才能发动。从自己的额外卡组让2只表侧表示的灵摆怪兽回到卡组，作为对象的卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37491810,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,37491811)
	e2:SetCondition(c37491810.desmcon)
	e2:SetTarget(c37491810.desmtg)
	e2:SetOperation(c37491810.desmop)
	c:RegisterEffect(e2)
	-- ②：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(98452268,2))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCondition(c37491810.pencon)
	e5:SetTarget(c37491810.pentg)
	e5:SetOperation(c37491810.penop)
	c:RegisterEffect(e5)
end
-- 定义过滤器：判断被破坏的卡是否满足“自己场上表侧表示的炼装卡被效果破坏”的条件（破坏原因为效果、原控制者是这张效果的使用者、原区域为场上、原表示形式为表侧且具有炼装字段）。
function c37491810.filter(c,tp)
	return c:IsReason(REASON_EFFECT) and c:IsPreviousSetCard(0xe1)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
-- 诱发条件：这次被破坏的卡中存在至少1张满足上述过滤条件的“炼装”卡。
function c37491810.despcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c37491810.filter,1,nil,tp)
end
-- 灵摆①的发动时处理：选择场上1张表侧表示的卡为对象，并设置破坏效果的操作信息。
function c37491810.desptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	-- 发动合法性检查：场上是否存在至少1张表侧表示且能成为当前效果对象的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 给玩家显示“请选择要破坏的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1张表侧表示的卡作为效果对象，并自动登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置本次连锁将破坏1张对象卡的操作信息，供相关卡（如星尘龙）发动检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 灵摆①效果处理：若选择的对象仍与该效果关联，则将其破坏。
function c37491810.despop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏该对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 怪兽①的发动条件：这张卡从额外卡组成功特殊召唤。
function c37491810.desmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_EXTRA)
end
-- 定义额外卡组中可返回卡组的表侧表示灵摆怪兽的过滤器。
function c37491810.desmfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAbleToDeck()
end
-- 怪兽①的发动时处理：选择对方场上1张卡为对象，同时确认额外卡组存在2只表侧灵摆怪兽可回卡组；设置回卡组与破坏的操作信息。
function c37491810.desmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	-- 发动合法性检查：对方场上有可成为对象的卡，且自己的额外卡组中有至少2只表侧表示且可返回卡组的灵摆怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) and Duel.IsExistingMatchingCard(c37491810.desmfilter,tp,LOCATION_EXTRA,0,2,nil) end
	-- 给玩家显示“请选择要破坏的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1张卡作为效果对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：此次效果预计将2张表侧表示的灵摆怪兽从自己的额外卡组返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_EXTRA)
	-- 设置操作信息：此次效果预计破坏1张对象卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 怪兽①效果处理：取对象卡；从额外卡组选择2只表侧灵摆怪兽返回卡组洗牌；若返回成功且对象仍关联，则破坏对象卡。
function c37491810.desmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出怪兽①发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 给玩家显示“请选择要返回卡组的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己的额外卡组选择2只满足条件的表侧表示灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,c37491810.desmfilter,tp,LOCATION_EXTRA,0,2,2,nil)
	-- 显示所选卡片的选中动画并记录这些卡被选为对象。
	Duel.HintSelection(g)
	-- 判断回卡组是否成功（实际处理数量不为0），且选择的卡仍在卡组或额外（未被其他效果移动），且对象卡仍与该效果关联，满足则执行破坏。
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) and tc:IsRelateToEffect(e) then
		-- 以效果原因破坏对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 怪兽②的发动条件：这张卡被破坏前位于怪兽区域且为表侧表示。
function c37491810.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 怪兽②发动时检查：自己的灵摆区域是否存在至少1个可用位置。
function c37491810.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的灵摆区域0号或1号位是否有空位。
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 怪兽②效果处理：若这张卡仍与该效果关联，则将其放置到自己的灵摆区域。
function c37491810.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示移动到自己的灵摆区域，并立即适用其效果。
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
