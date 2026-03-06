--スプリガンズ・キャプテン サルガス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·场上·墓地存在的场合，以自己场上1只「护宝炮妖」超量怪兽为对象才能发动。把这张卡作为那只怪兽的超量素材。
-- ②：对方回合，把自己场上1个超量素材取除，以场上1张表侧表示卡为对象才能发动。那张卡破坏。
-- ③：持有这张卡作为素材中的「护宝炮妖」超量怪兽得到以下效果。
-- ●这张卡的攻击力上升500。
function c29601381.initial_effect(c)
	-- ①：这张卡在手卡·场上·墓地存在的场合，以自己场上1只「护宝炮妖」超量怪兽为对象才能发动。把这张卡作为那只怪兽的超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29601381,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetCountLimit(1,29601381)
	e1:SetTarget(c29601381.ovtg)
	e1:SetOperation(c29601381.ovop)
	c:RegisterEffect(e1)
	-- ②：对方回合，把自己场上1个超量素材取除，以场上1张表侧表示卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29601381,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,29601382)
	e2:SetCondition(c29601381.descon)
	e2:SetCost(c29601381.descost)
	e2:SetTarget(c29601381.destg)
	e2:SetOperation(c29601381.desop)
	c:RegisterEffect(e2)
	-- ③：持有这张卡作为素材中的「护宝炮妖」超量怪兽得到以下效果。●这张卡的攻击力上升500。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(29601381,2))
	e3:SetType(EFFECT_TYPE_XMATERIAL)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(500)
	e3:SetCondition(c29601381.gfcon)
	c:RegisterEffect(e3)
end
-- 过滤满足条件的「护宝炮妖」超量怪兽
function c29601381.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x155) and c:IsType(TYPE_XYZ)
end
-- 判断是否能发动效果①
function c29601381.ovtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c29601381.ovfilter(chkc) and chkc~=e:GetHandler() end
	-- 检索满足条件的「护宝炮妖」超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c29601381.ovfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
		and e:GetHandler():IsCanOverlay() end
	-- 提示选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择1只「护宝炮妖」超量怪兽作为效果的对象
	Duel.SelectTarget(tp,c29601381.ovfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	if e:GetHandler():IsLocation(LOCATION_GRAVE) then
		-- 设置效果①的发动信息
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
	end
end
-- 处理效果①的发动
function c29601381.ovop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果①的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not c:IsImmuneToEffect(e) and c:IsCanOverlay() then
		local og=c:GetOverlayGroup()
		if og:GetCount()>0 then
			-- 将目标怪兽身上的叠放卡送去墓地
			Duel.SendtoGrave(og,REASON_RULE)
		end
		-- 将此卡叠放至目标怪兽上
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
-- 判断是否为对方回合
function c29601381.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方回合
	return Duel.GetTurnPlayer()==1-tp
end
-- 处理效果②的费用
function c29601381.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付效果②的费用
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_COST) end
	-- 支付效果②的费用
	Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_COST)
end
-- 处理效果②的发动
function c29601381.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	-- 检索满足条件的表侧表示卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择1张表侧表示卡作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果②的发动信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 处理效果②的发动
function c29601381.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏目标卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判断此卡是否为「护宝炮妖」超量怪兽的叠放卡
function c29601381.gfcon(e)
	return e:GetHandler():IsSetCard(0x155)
end
