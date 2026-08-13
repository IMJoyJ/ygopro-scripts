--宝玉獣 コバルト・イーグル
-- 效果：
-- ①：1回合1次，以自己场上1张「宝玉兽」卡为对象才能发动。那张自己的「宝玉兽」卡回到持有者卡组最上面。
-- ②：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
function c21698716.initial_effect(c)
	-- ②：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(c21698716.repcon)
	e1:SetOperation(c21698716.repop)
	c:RegisterEffect(e1)
	-- ①：1回合1次，以自己场上1张「宝玉兽」卡为对象才能发动。那张自己的「宝玉兽」卡回到持有者卡组最上面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21698716,1))  --"返回卡组"
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c21698716.target)
	e2:SetOperation(c21698716.operation)
	c:RegisterEffect(e2)
end
-- 判断②效果能否发动的条件：这张卡在怪兽区域表侧表示存在，且因被破坏而要送去墓地的场合。
function c21698716.repcon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
end
-- 执行②效果的操作：不把这张卡送去墓地，而是改为在魔法与陷阱区域作为永续魔法卡表侧表示放置。
function c21698716.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	c:RegisterEffect(e1)
end
-- 过滤可作为①效果对象的卡：必须是我方场上的表侧表示「宝玉兽」卡，且能够返回卡组。
function c21698716.filter(c)
	return c:IsSetCard(0x1034) and c:IsAbleToDeck() and c:IsFaceup()
end
-- ①效果的发动处理：以自己场上1张表侧表示的「宝玉兽」卡为对象，确定后将其返回持有者卡组最上面。
function c21698716.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c21698716.filter(chkc) end
	-- 发动条件检查：我方场上是否存在至少1张满足过滤条件的「宝玉兽」卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c21698716.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 向操作者显示“请选择要返回卡组的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让操作者从我方场上选择1张符合条件的「宝玉兽」卡作为效果对象。
	local g=Duel.SelectTarget(tp,c21698716.filter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置本次连锁的操作信息：将选择的对象卡以1张的数量加入“回卡组”这一效果分类，用于后续相关效果应对。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- ①效果处理时：取出效果对象，若该对象仍与效果相关且仍由我方控制并满足条件，则将其返回持有者卡组最上面。
function c21698716.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得①效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(tp) and c21698716.filter(tc) then
		-- 将对象卡以效果原因返回持有者卡组最上面。
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
