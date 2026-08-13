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
	-- 设置②效果的发动代价为把墓地中的这张卡除外（作为发动COST）。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c36577931.settg)
	e3:SetOperation(c36577931.setop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件：这张卡被效果送去墓地，或因效果被除外（含被效果处理改变去向）的场合才能发动。
function c36577931.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT+REASON_REDIRECT)
end
-- 检索过滤条件：卡名属于「死狱乡」字段、不是「悲剧之死狱乡演员」自身、是怪兽卡、并且能被加入手卡。
function c36577931.thfilter(c)
	return c:IsSetCard(0x164) and not c:IsCode(36577931) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果发动时的合法性检查与操作信息登记：chk==0时检查卡组是否存在满足检索条件的怪兽；存在则登记从卡组将1张卡加入手卡的操作信息。
function c36577931.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认卡组中存在至少1张满足检索条件的「死狱乡」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c36577931.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记当前连锁的操作信息：效果处理时将把1张卡从卡组加入手卡，用于连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：提示玩家选择要加入手卡的卡，从卡组选1张满足条件的「死狱乡」怪兽加入手卡，并向对方确认。
function c36577931.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示“请选择要加入手牌的卡”，供玩家在选择卡组卡片时作为提示文字。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从自己卡组选择1张满足检索条件的「死狱乡」怪兽（不取对象，效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c36577931.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡，原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡，以公开检索到的卡片信息。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的对象过滤条件：自己墓地中卡名属于「烙印」字段、是魔法·陷阱卡、并且可以盖放到魔法与陷阱区域的卡。
function c36577931.setfilter(c)
	return c:IsSetCard(0x15d) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- ②效果发动时的取对象处理：检查墓地是否存在合法对象；提示选择；选择1张作为对象；并登记涉及墓地卡片离开墓地的操作信息。
function c36577931.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c36577931.setfilter(chkc) end
	-- 发动合法性检查：确认自己墓地存在至少1张满足条件的「烙印」魔法·陷阱卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c36577931.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示选择提示“请选择要盖放的卡”，供玩家选择对象时作为提示文字。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从自己墓地选择1张符合条件的「烙印」魔法·陷阱卡作为对象（取对象）。
	local g=Duel.SelectTarget(tp,c36577931.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记当前连锁将处理墓地的卡离开墓地的操作信息，用于相关卡片或规则（如王家长眠之谷）的连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- ②效果处理：取得对象卡，若该卡仍与效果关联，则将那张卡盖放到自己场上。
function c36577931.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时最初选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡盖放（Set）到自己魔法与陷阱区域。
		Duel.SSet(tp,tc)
	end
end
