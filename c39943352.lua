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
	-- 为这张卡添加XYZ召唤手续，使其可以以2只等级4的怪兽为素材进行超量召唤。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- 为这张卡附加灵摆怪兽属性，支持灵摆召唤和作为灵摆卡放置在灵摆区；false表示不自动注册灵摆卡“发动”的效果。
	aux.EnablePendulumAttribute(c,false)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：以自己场上1只超量怪兽为对象才能发动。把这张卡在那只怪兽下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39943352,0))
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,39943352)
	e1:SetTarget(c39943352.xyztg)
	e1:SetOperation(c39943352.xyzop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的怪兽效果1回合各能使用1次。①：把这张卡1个超量素材取除才能发动。这张卡在自己的灵摆区域放置。那之后，可以从自己墓地把1只灵摆怪兽表侧加入额外卡组。
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
-- 定义过滤器：筛选场上表侧表示的超量怪兽，用于灵摆效果①的对象选择。
function c39943352.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 灵摆效果①的发动条件和选择对象：检查自己场上有表侧表示超量怪兽可选取且自身可作超量素材，并让玩家选择1只对象。
function c39943352.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c39943352.filter(chkc) end
	-- 发动合法性检查：确认自己场上有1只表侧表示超量怪兽可选为目标，且这张卡自身可以被叠放（作为超量素材），满足条件才能发动。
	if chk==0 then return Duel.IsExistingTarget(c39943352.filter,tp,LOCATION_MZONE,0,1,nil) and e:GetHandler():IsCanOverlay() end
	-- 提示玩家选择效果的对象（对话框显示“请选择效果的对象”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从我方主要怪兽区域选择1只符合条件的表侧超量怪兽作为效果对象，并记录为连锁对象。
	Duel.SelectTarget(tp,c39943352.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：取回目标怪兽，确认双方仍与效果关联且目标不免疫此效果、自身仍可作为超量素材后，将自身叠放到目标怪兽下面作为超量素材。
function c39943352.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的那只超量怪兽作为目标对象。
	local tc=Duel.GetFirstTarget()
	if not tc:IsImmuneToEffect(e) and tc:IsRelateToEffect(e) and c:IsRelateToEffect(e) and c:IsCanOverlay() then
		-- 将这张卡作为超量素材，叠放到目标超量怪兽的下面（Overlay）。
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
-- 怪兽效果①的发动代价：若可支付，则从这张卡取除1个超量素材（REASON_COST）。
function c39943352.pencost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 怪兽效果①的发动条件检查：确认自己的灵摆区域有空格（左或右）可供放置这张卡。
function c39943352.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定我方灵摆区域的位置0或位置1是否存在可用空格，满足其一才能发动效果。
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 定义过滤器：筛选墓地中的灵摆怪兽，用于选择是否加入额外卡组。
function c39943352.pmfilter(c)
	return c:IsType(TYPE_PENDULUM)
end
-- 怪兽效果①的处理：将自身移动到灵摆区表侧放置；若成功且墓地有符合条件的灵摆怪兽，则询问玩家选择1只加入额外卡组。
function c39943352.penop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时校验：若自身已与效果失去联系，或无法移动到灵摆区域，则终止后续处理；否则将自身表侧放置在灵摆区。
	if not c:IsRelateToEffect(e) or not Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true) then return end
	-- 检查自己墓地是否存在符合条件的灵摆怪兽（排除受王家长眠之谷影响的卡）可供加入额外卡组。
	if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c39943352.pmfilter),tp,LOCATION_GRAVE,0,1,nil)
		-- 若墓地存在符合条件的灵摆怪兽，则询问玩家是否选择1只加入额外卡组；选择“是”则继续处理。
		and Duel.SelectYesNo(tp,aux.Stringid(39943352,3)) then  --"是否从墓地选1只灵摆怪兽加入额外卡组？"
		-- 发送选择提示，提示玩家选择要送入额外卡组的卡（消息：“请选择要返回卡组的卡”）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 让玩家从自己墓地选择1只符合条件的灵摆怪兽，作为表侧加入额外卡组的对象。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c39943352.pmfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		-- 中断当前效果处理，使后续送额外卡组的操作独立结算，避免错过时点。
		Duel.BreakEffect()
		-- 将选中的灵摆怪兽表侧表示加入持有者的额外卡组，原因为效果。
		Duel.SendtoExtraP(g,nil,REASON_EFFECT)
	end
end
-- 怪兽效果②的发动条件：此卡在怪兽区域被战斗或效果破坏，且破坏前位于主要怪兽区域。
function c39943352.pencon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 怪兽效果②的处理：若这张卡仍与效果关联，则将其移动到自己的灵摆区域表侧放置。
function c39943352.penop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡移动到自己的灵摆区域，以表侧表示放置。
	Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
end
