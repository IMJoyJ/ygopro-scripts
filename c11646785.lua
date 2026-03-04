--超量機獣エアロボロス
-- 效果：
-- 4星怪兽×2
-- ①：没有超量素材的这张卡不能攻击。
-- ②：1回合1次，把这张卡1个超量素材取除，以这张卡以外的场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。这张卡有「超级量子战士 绿光层」在作为超量素材的场合，这个效果在对方回合也能发动。
-- ③：1回合1次，自己主要阶段才能发动。选自己的手卡·场上1只「超级量子战士」怪兽在这张卡下面重叠作为超量素材。
function c11646785.initial_effect(c)
	-- 为卡片注册超量素材代码列表，用于判断是否包含「超级量子战士 绿光层」
	aux.AddCodeList(c,85374678)
	-- 添加XYZ召唤手续，使用2只4星怪兽进行超量召唤
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：没有超量素材的这张卡不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetCondition(c11646785.atcon)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡1个超量素材取除，以这张卡以外的场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11646785,0))  --"里侧守备表示"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCondition(c11646785.setcon1)
	e2:SetCost(c11646785.setcost)
	e2:SetTarget(c11646785.settg)
	e2:SetOperation(c11646785.setop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCondition(c11646785.setcon2)
	c:RegisterEffect(e3)
	-- ③：1回合1次，自己主要阶段才能发动。选自己的手卡·场上1只「超级量子战士」怪兽在这张卡下面重叠作为超量素材。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(11646785,1))  --"超量素材"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c11646785.mttg)
	e4:SetOperation(c11646785.mtop)
	c:RegisterEffect(e4)
end
-- 判断当前卡片是否没有超量素材
function c11646785.atcon(e)
	return e:GetHandler():GetOverlayCount()==0
end
-- 判断当前卡片是否不包含「超级量子战士 绿光层」作为超量素材
function c11646785.setcon1(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,85374678)
end
-- 判断当前卡片是否包含「超级量子战士 绿光层」作为超量素材
function c11646785.setcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,85374678)
end
-- 支付1个超量素材作为发动代价
function c11646785.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选可以变为里侧守备表示的怪兽
function c11646785.setfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 设置效果目标，选择一只可以变为里侧守备表示的怪兽
function c11646785.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c11646785.setfilter(chkc) and chkc~=e:GetHandler() end
	-- 检查是否存在满足条件的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c11646785.setfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c11646785.setfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
	-- 设置效果操作信息，指定将要改变表示形式的怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 处理效果操作，将目标怪兽变为里侧守备表示
function c11646785.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将目标怪兽变为里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
-- 筛选可以作为超量素材的「超级量子战士」怪兽
function c11646785.mtfilter(c,e)
	return c:IsFaceupEx() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x10dc) and c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
end
-- 设置效果目标，选择一只可以作为超量素材的怪兽
function c11646785.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		-- 检查是否存在满足条件的怪兽可以作为超量素材
		and Duel.IsExistingMatchingCard(c11646785.mtfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
end
-- 处理效果操作，将选中的怪兽作为超量素材叠放
function c11646785.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 提示玩家选择要作为超量素材的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	-- 选择作为超量素材的怪兽
	local g=Duel.SelectMatchingCard(tp,c11646785.mtfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e)
	if g:GetCount()>0 then
		local mg=g:GetFirst():GetOverlayGroup()
		if mg:GetCount()>0 then
			-- 将选中怪兽身上的叠放卡送去墓地
			Duel.SendtoGrave(mg,REASON_RULE)
		end
		-- 将选中的怪兽叠放至自身作为超量素材
		Duel.Overlay(c,g)
	end
end
