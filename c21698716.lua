--宝玉獣 コバルト・イーグル
-- 效果：
-- ①：1回合1次，以自己场上1张「宝玉兽」卡为对象才能发动。那张自己的「宝玉兽」卡回到持有者卡组最上面。
-- ②：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
function c21698716.initial_effect(c)
	-- 效果原文内容：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(c21698716.repcon)
	e1:SetOperation(c21698716.repop)
	c:RegisterEffect(e1)
	-- 效果原文内容：1回合1次，以自己场上1张「宝玉兽」卡为对象才能发动。那张自己的「宝玉兽」卡回到持有者卡组最上面。
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
-- 规则层面操作：判断此卡是否为表侧表示、在怪兽区域、且因破坏而离场。
function c21698716.repcon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
end
-- 规则层面操作：将此卡改变为永续魔法卡类型。
function c21698716.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面操作：将此卡改变为永续魔法卡类型。
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	c:RegisterEffect(e1)
end
-- 规则层面操作：筛选满足条件的「宝玉兽」卡（表侧表示、可送入卡组）。
function c21698716.filter(c)
	return c:IsSetCard(0x1034) and c:IsAbleToDeck() and c:IsFaceup()
end
-- 规则层面操作：设置选择目标的处理流程，包括提示选择、选择卡片并设置操作信息。
function c21698716.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c21698716.filter(chkc) end
	-- 规则层面操作：判断是否存在满足条件的目标卡片。
	if chk==0 then return Duel.IsExistingTarget(c21698716.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 规则层面操作：向玩家发送提示信息，提示选择要返回卡组的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 规则层面操作：选择满足条件的1张目标卡片。
	local g=Duel.SelectTarget(tp,c21698716.filter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 规则层面操作：设置连锁的操作信息，指定将目标卡送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 规则层面操作：执行将目标卡送回卡组的处理。
function c21698716.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取当前连锁中被选择的目标卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(tp) and c21698716.filter(tc) then
		-- 规则层面操作：将目标卡片送回卡组顶端。
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
