--天空賢者ミネルヴァ
-- 效果：
-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把反击陷阱卡发动，这张卡的攻击力上升500，场上有「天空的圣域」存在的场合，再从自己墓地选和那张发动的反击陷阱卡卡名不同的1张反击陷阱卡加入手卡。
function c53666449.initial_effect(c)
	-- 将卡号56433456（天空的圣域）登记为这张卡记载的卡名，用于后续配合/判断与「天空的圣域」相关的效果。
	aux.AddCodeList(c,56433456)
	-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把反击陷阱卡发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	-- 设置e0的事件处理函数为aux.chainreg，在反击陷阱发动的连锁时给此卡打上标记，记录此卡在怪兽区域存在。
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	-- 这张卡的攻击力上升500，场上有「天空的圣域」存在的场合，再从自己墓地选和那张发动的反击陷阱卡卡名不同的1张反击陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c53666449.atkcon)
	e1:SetOperation(c53666449.atkop)
	c:RegisterEffect(e1)
end
-- 判断触发条件：本次处理的效果是反击陷阱卡的发动（效果类型为魔法/陷阱发动且为反击陷阱），并且通过FLAG_ID_CHAINING标记确认这张卡在反击陷阱发动时就在怪兽区域存在。
function c53666449.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_COUNTER) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0
end
-- 墓地过滤条件：选择反击陷阱卡、卡名与发动的那张反击陷阱卡不同、且能够加入手卡的卡。
function c53666449.thfilter(c,code)
	return c:IsType(TYPE_COUNTER) and not c:IsCode(code) and c:IsAbleToHand()
end
-- 处理效果：先让这张卡攻击力上升500；若场上有「天空的圣域」，则从自己墓地选1张符合条件的反击陷阱卡加入手卡。
function c53666449.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这张卡的攻击力上升500
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
	local rc=re:GetHandler()
	-- 从自己墓地中筛选满足thfilter条件（反击陷阱、卡名不同、可加入手卡）且不受王家长眠之谷影响的卡，作为加入手卡的候选。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c53666449.thfilter),tp,LOCATION_GRAVE,0,nil,rc:GetCode())
	-- 检查当前场上是否适用「天空的圣域」（卡号56433456），且存在符合条件的墓地反击陷阱卡，满足时才执行加入手卡。
	if Duel.IsEnvironment(56433456) and g:GetCount()>0 then
		-- 向双方展示卡片动画，提示正在处理密涅瓦的效果（不进入连锁）。
		Duel.Hint(HINT_CARD,0,53666449)
		-- 给玩家tp显示“请选择要加入手牌的卡”的选择提示，用于选择墓地反击陷阱卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的反击陷阱卡以效果原因送回到其持有者的手卡。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
