--魔界の警邏課デスポリス
-- 效果：
-- 怪兽2只
-- ①：卡名不同的暗属性怪兽2只为素材作连接召唤的这张卡得到以下效果。
-- ●把自己场上1只怪兽解放，以场上1张表侧表示的卡为对象才能发动。给那张卡放置1个警逻指示物。这个卡名的这个效果1回合只能使用1次。有警逻指示物放置的卡被战斗·效果破坏的场合，作为代替把那张卡1个警逻指示物取除。
function c99011763.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤的手续，需要2只怪兽作为素材。
	aux.AddLinkProcedure(c,nil,2,2)
	-- ①：卡名不同的暗属性怪兽2只为素材作连接召唤的这张卡得到以下效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c99011763.regcon)
	e1:SetOperation(c99011763.regop)
	c:RegisterEffect(e1)
	-- ①：卡名不同的暗属性怪兽2只为素材作连接召唤的这张卡得到以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c99011763.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ●把自己场上1只怪兽解放，以场上1张表侧表示的卡为对象才能发动。给那张卡放置1个警逻指示物。这个卡名的这个效果1回合只能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(99011763,0))
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,99011763)
	e3:SetCondition(c99011763.ctcon)
	e3:SetCost(c99011763.ctcost)
	e3:SetTarget(c99011763.cttg)
	e3:SetOperation(c99011763.ctop)
	c:RegisterEffect(e3)
end
-- 检查这张卡是否是通过连接召唤特殊召唤，且素材满足卡名不同暗属性怪兽2只的条件。
function c99011763.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and e:GetLabel()==1
end
-- 给这张卡注册一个Flag，表示其获得了后续的放置指示物效果，并添加客户端提示。
function c99011763.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(99011763,RESET_EVENT+RESETS_STANDARD,0,0)
	c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(99011763,1))  --"拥有效果"
end
-- 检查连接素材是否为2只卡名不同的暗属性怪兽，如果是，则将e1的Label设为1。
function c99011763.valcheck(e,c)
	local g=c:GetMaterial()
	if g:GetClassCount(Card.GetLinkCode)==g:GetCount() and g:IsExists(Card.IsLinkAttribute,2,nil,ATTRIBUTE_DARK) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 检查这张卡是否具有通过特定素材连接召唤成功时注册的Flag（即是否获得了该效果）。
function c99011763.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(99011763)~=0
end
-- 过滤可解放的怪兽，要求场上存在除该怪兽以外、可以放置警逻指示物的卡。
function c99011763.cfilter(c)
	-- 检查场上是否存在至少1张可以放置警逻指示物的表侧表示卡片（排除作为解放代价的卡本身）。
	return Duel.IsExistingTarget(Card.IsCanAddCounter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,0x1049,1)
end
-- 效果发动的代价：解放自己场上1只怪兽。
function c99011763.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在至少1只满足解放条件的怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c99011763.cfilter,1,nil) end
	-- 玩家选择场上1只满足条件的怪兽作为解放对象。
	local g=Duel.SelectReleaseGroup(tp,c99011763.cfilter,1,1,nil)
	-- 将选择的怪兽解放。
	Duel.Release(g,REASON_COST)
end
-- 效果的目标：选择场上1张可以放置警逻指示物的表侧表示卡片。
function c99011763.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsCanAddCounter(0x1049,1) end
	if chk==0 then return true end
	-- 提示玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择场上1张可以放置警逻指示物的表侧表示卡片作为效果对象。
	Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,0x1049,1)
end
-- 效果的处理：给作为对象的卡放置1个警逻指示物，并为其注册代替破坏的效果。
function c99011763.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x1049,1)
		if tc:GetFlagEffect(99011764)~=0 then return end
		-- 有警逻指示物放置的卡被战斗·效果破坏的场合，作为代替把那张卡1个警逻指示物取除。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EFFECT_DESTROY_REPLACE)
		e1:SetTarget(c99011763.reptg)
		e1:SetOperation(c99011763.repop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc:RegisterFlagEffect(99011764,RESET_EVENT+RESETS_STANDARD,0,0)
	end
end
-- 检查该卡是否因战斗或效果将被破坏，且该卡上存在至少1个警逻指示物可以被取除。
function c99011763.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		and c:IsCanRemoveCounter(tp,0x1049,1,REASON_EFFECT) end
	return true
end
-- 代替破坏的处理：取除该卡上的1个警逻指示物。
function c99011763.repop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveCounter(tp,0x1049,1,REASON_EFFECT)
end
