--悲劇のデスピアン
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡被效果送去墓地的场合或者被效果除外的场合才能发动。从卡组把「悲剧之死狱乡演员」以外的1只「死狱乡」怪兽加入手卡。
-- ②：把墓地的这张卡除外，以自己墓地1张「烙印」魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。
function c36577931.initial_effect(c)
	-- ①：这张卡被效果送去墓地的场合或者被效果除外的场合才能发动。从卡组把「悲剧之死狱乡演员」以外的1只「死狱乡」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36577931,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,36577931)
	e1:SetCondition(c36577931.thcon)
	e1:SetTarget(c36577931.thtg)
	e1:SetOperation(c36577931.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡除外，以自己墓地1张「烙印」魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(36577931,1))
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,36577931)
	-- 将此卡除外作为cost
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c36577931.settg)
	e3:SetOperation(c36577931.setop)
	c:RegisterEffect(e3)
end
-- 效果发动的发动条件为：此卡因效果或改变去向而送去墓地
function c36577931.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT+REASON_REDIRECT)
end
-- 检索满足条件的「死狱乡」怪兽（非此卡本身）
function c36577931.thfilter(c)
	return c:IsSetCard(0x164) and not c:IsCode(36577931) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置效果处理时要检索的卡组中的满足条件的卡
function c36577931.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足条件：卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c36577931.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时要检索的卡组中的满足条件的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 选择并执行将满足条件的卡加入手牌的效果
function c36577931.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c36577931.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 检索满足条件的「烙印」魔法·陷阱卡
function c36577931.setfilter(c)
	return c:IsSetCard(0x15d) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 设置效果处理时要选择的满足条件的墓地中的卡
function c36577931.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c36577931.setfilter(chkc) end
	-- 检查是否满足条件：墓地中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingTarget(c36577931.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectTarget(tp,c36577931.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理时要盖放的卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 选择并执行将满足条件的卡在自己场上盖放的效果
function c36577931.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡在自己场上盖放
		Duel.SSet(tp,tc)
	end
end
