--天空賢者ミネルヴァ
-- 效果：
-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把反击陷阱卡发动，这张卡的攻击力上升500，场上有「天空的圣域」存在的场合，再从自己墓地选和那张发动的反击陷阱卡卡名不同的1张反击陷阱卡加入手卡。
function c53666449.initial_effect(c)
	-- 记录该卡具有「天空的圣域」这张卡的卡名
	aux.AddCodeList(c,56433456)
	-- 只要这张卡在怪兽区域存在，每次自己或者对方把反击陷阱卡发动，这张卡的攻击力上升500
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	-- 记录连锁发生时这张卡在场上存在
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	-- 场上有「天空的圣域」存在的场合，再从自己墓地选和那张发动的反击陷阱卡卡名不同的1张反击陷阱卡加入手卡
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c53666449.atkcon)
	e1:SetOperation(c53666449.atkop)
	c:RegisterEffect(e1)
end
-- 判断是否为反击陷阱卡发动且该卡在场上存在
function c53666449.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_COUNTER) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0
end
-- 过滤墓地中的反击陷阱卡，排除与发动卡同名的卡
function c53666449.thfilter(c,code)
	return c:IsType(TYPE_COUNTER) and not c:IsCode(code) and c:IsAbleToHand()
end
-- 使该卡攻击力上升500点，并在满足条件时从墓地检索符合条件的反击陷阱卡加入手牌
function c53666449.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 使该卡攻击力上升500点
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
	local rc=re:GetHandler()
	-- 检索满足条件的反击陷阱卡组
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c53666449.thfilter),tp,LOCATION_GRAVE,0,nil,rc:GetCode())
	-- 检查场上有「天空的圣域」存在且有符合条件的卡可选
	if Duel.IsEnvironment(56433456) and g:GetCount()>0 then
		-- 提示发动了该卡的效果
		Duel.Hint(HINT_CARD,0,53666449)
		-- 提示选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
