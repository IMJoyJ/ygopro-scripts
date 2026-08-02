--魔界の警邏課デスポリス
-- 效果：
-- 怪兽2只
-- ①：卡名不同的暗属性怪兽2只为素材作连接召唤的这张卡得到以下效果。
-- ●把自己场上1只怪兽解放，以场上1张表侧表示的卡为对象才能发动。给那张卡放置1个警逻指示物。这个卡名的这个效果1回合只能使用1次。有警逻指示物放置的卡被战斗·效果破坏的场合，作为代替把那张卡1个警逻指示物取除。
function c99011763.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续
	aux.AddLinkProcedure(c,nil,2,2)
	-- ①：卡名不同的暗属性怪兽2只为素材作连接召唤的这张卡得到以下效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c99011763.regcon)
	e1:SetOperation(c99011763.regop)
	c:RegisterEffect(e1)
	-- 卡名不同的暗属性怪兽2只为素材作连接召唤的这张卡得到以下效果。
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
c99011763.mentioned_counter={
	[0x1049]=true,
}
-- 判断该卡是否为连接召唤出场且满足了赋予效果的素材条件
function c99011763.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and e:GetLabel()==1
end
-- 赋予该卡记录标志，并添加客户端显示的文本提示
function c99011763.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(99011763,RESET_EVENT+RESETS_STANDARD,0,0)
	c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(99011763,1))  --"拥有效果"
end
-- 检查连接素材是否为2只卡名不同的暗属性怪兽，据此设置记录标签
function c99011763.valcheck(e,c)
	local g=c:GetMaterial()
	if g:GetClassCount(Card.GetLinkCode)==g:GetCount() and g:IsExists(Card.IsLinkAttribute,2,nil,ATTRIBUTE_DARK) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 效果发动条件：检查该卡是否拥有记录的赋予效果标志
function c99011763.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(99011763)~=0
end
-- 过滤条件：场上存在可以放置警逻指示物的表侧表示的卡
function c99011763.cfilter(c)
	-- 判断场上是否存在可以放置警逻指示物的表侧表示的卡
	return Duel.IsExistingTarget(Card.IsCanAddCounter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,0x1049,1)
end
-- 效果发动代价：把自己场上1只怪兽解放
function c99011763.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 如果是检查阶段，则判断场上是否有可解放的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c99011763.cfilter,1,nil) end
	-- 让玩家选择自己场上1只可解放的怪兽
	local g=Duel.SelectReleaseGroup(tp,c99011763.cfilter,1,1,nil)
	-- 将选择的怪兽解放
	Duel.Release(g,REASON_COST)
end
-- 效果发动目标：以场上1张可以放置指示物的表侧表示的卡为对象
function c99011763.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsCanAddCounter(0x1049,1) end
	if chk==0 then return true end
	-- 向玩家发送提示消息：请选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家在场上选择1张可放置指示物的目标卡
	Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,0x1049,1)
end
-- 效果处理：给目标卡放置指示物，并赋予其代替破坏效果
function c99011763.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选为对象的卡
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
-- 检查对象卡是否因为战斗或效果被破坏，并且可以取除警逻指示物来代替
function c99011763.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		and c:IsCanRemoveCounter(tp,0x1049,1,REASON_EFFECT) end
	return true
end
-- 取除对象卡的1个警逻指示物作为代替
function c99011763.repop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveCounter(tp,0x1049,1,REASON_EFFECT)
end
