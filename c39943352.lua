--液状巨人ダイダラタント
-- 效果：
-- ←3 【灵摆】 3→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：以自己场上1只超量怪兽为对象才能发动。把这张卡在那只怪兽下面重叠作为超量素材。
-- 【怪兽效果】
-- 4星怪兽×2
-- 4星可以灵摆召唤的场合在额外卡组的表侧表示的这张卡可以灵摆召唤。这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除才能发动。这张卡在自己的灵摆区域放置。那之后，可以从自己墓地选1只灵摆怪兽表侧表示加入额外卡组。
-- ②：怪兽区域的这张卡被战斗·效果破坏的场合才能发动。这张卡在自己的灵摆区域放置。
function c39943352.initial_effect(c)
	-- 为卡片添加等级为4、需要2只怪兽进行超量召唤的手续
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- 为卡片添加灵摆怪兽属性，但不注册灵摆卡的发动效果
	aux.EnablePendulumAttribute(c,false)
	-- ①：以自己场上1只超量怪兽为对象才能发动。把这张卡在那只怪兽下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39943352,0))
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,39943352)
	e1:SetTarget(c39943352.xyztg)
	e1:SetOperation(c39943352.xyzop)
	c:RegisterEffect(e1)
	-- ①：把这张卡1个超量素材取除才能发动。这张卡在自己的灵摆区域放置。那之后，可以从自己墓地选1只灵摆怪兽表侧表示加入额外卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39943352,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,39943353)
	e2:SetCost(c39943352.pencost1)
	e2:SetTarget(c39943352.pentg)
	e2:SetOperation(c39943352.penop1)
	c:RegisterEffect(e2)
	-- ②：怪兽区域的这张卡被战斗·效果破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(39943352,2))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,39943354)
	e3:SetCondition(c39943352.pencon2)
	e3:SetTarget(c39943352.pentg)
	e3:SetOperation(c39943352.penop2)
	c:RegisterEffect(e3)
end
c39943352.pendulum_level=4
-- 过滤函数，用于判断是否为正面表示的超量怪兽
function c39943352.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 设置效果的对象为己方场上的1只超量怪兽
function c39943352.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c39943352.filter(chkc) end
	-- 检查是否满足选择对象的条件：己方场上存在1只超量怪兽且此卡可以作为超量素材
	if chk==0 then return Duel.IsExistingTarget(c39943352.filter,tp,LOCATION_MZONE,0,1,nil) and e:GetHandler():IsCanOverlay() end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择己方场上的1只超量怪兽作为效果对象
	Duel.SelectTarget(tp,c39943352.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 执行将此卡叠放至目标怪兽下方的操作
function c39943352.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsImmuneToEffect(e) and tc:IsRelateToEffect(e) and c:IsRelateToEffect(e) and c:IsCanOverlay() then
		-- 将此卡叠放至目标怪兽下方
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
-- 设置效果的费用为去除1个超量素材
function c39943352.pencost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置效果的目标为灵摆区域是否可用
function c39943352.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方灵摆区域是否有空位
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 过滤函数，用于判断是否为灵摆怪兽
function c39943352.pmfilter(c)
	return c:IsType(TYPE_PENDULUM)
end
-- 执行将此卡移至灵摆区域并可选择将墓地灵摆怪兽加入额外卡组的操作
function c39943352.penop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否能正常移至灵摆区域
	if not c:IsRelateToEffect(e) or not Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true) then return end
	-- 检查己方墓地是否存在灵摆怪兽
	if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c39943352.pmfilter),tp,LOCATION_GRAVE,0,1,nil)
		-- 询问玩家是否选择将墓地灵摆怪兽加入额外卡组
		and Duel.SelectYesNo(tp,aux.Stringid(39943352,3)) then  --"是否从墓地选1只灵摆怪兽加入额外卡组？"
		-- 提示玩家选择要加入额外卡组的灵摆怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 选择1只墓地中的灵摆怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c39943352.pmfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		-- 中断当前效果处理，使后续处理视为不同时处理
		Duel.BreakEffect()
		-- 将选中的灵摆怪兽加入额外卡组
		Duel.SendtoExtraP(g,nil,REASON_EFFECT)
	end
end
-- 判断此卡被破坏的原因是否为战斗或效果，并且之前在主要怪兽区域
function c39943352.pencon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 将此卡移至灵摆区域
function c39943352.penop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡移至玩家的灵摆区域
	Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
end
