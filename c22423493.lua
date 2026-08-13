--クリフォート・ゲニウス
-- 效果：
-- 机械族怪兽2只
-- ①：连接召唤的这张卡不受魔法·陷阱卡的效果影响，也不受这张卡以外的连接怪兽发动的效果影响。
-- ②：1回合1次，以这张卡以外的自己以及对方场上的表侧表示的卡各1张为对象才能发动。那2张卡的效果直到回合结束时无效。
-- ③：这张卡所连接区有怪兽2只同时特殊召唤时才能发动。从卡组把1只5星以上的机械族怪兽加入手卡。
function c22423493.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：使用2只机械族怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_MACHINE),2,2)
	-- “①：连接召唤的这张卡不受魔法·陷阱卡的效果影响，也不受这张卡以外的连接怪兽发动的效果影响。”
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetCondition(c22423493.immcon)
	e1:SetValue(c22423493.efilter)
	c:RegisterEffect(e1)
	-- “②：1回合1次，以这张卡以外的自己以及对方场上的表侧表示的卡各1张为对象才能发动。那2张卡的效果直到回合结束时无效。”
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22423493,0))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c22423493.distg)
	e2:SetOperation(c22423493.disop)
	c:RegisterEffect(e2)
	-- “③：这张卡所连接区有怪兽2只同时特殊召唤时才能发动。从卡组把1只5星以上的机械族怪兽加入手卡。”
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(22423493,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c22423493.thcon)
	e3:SetTarget(c22423493.thtg)
	e3:SetOperation(c22423493.thop)
	c:RegisterEffect(e3)
end
-- ①的免疫效果适用条件：这张卡必须是以连接召唤方式出场的怪兽。
function c22423493.immcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- ①的免疫筛选：来源于魔法·陷阱卡的效果，或来源于其他连接怪兽发动的已生效效果（效果持有者不是这张卡）都免疫。
function c22423493.efilter(e,te)
	if te:IsActiveType(TYPE_SPELL+TYPE_TRAP) then return true
	else return te:IsActiveType(TYPE_LINK) and te:IsActivated() and te:GetOwner()~=e:GetOwner() end
end
-- ②的发动条件与取对象流程：先检查自己、对方场上是否各存在1张可被无效化且不取自身的表侧表示卡；满足后提示并选择双方各1张作为效果对象。
function c22423493.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动条件检查：确认自己场上有1张除这张卡以外能被无效化的表侧表示卡。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
		-- 发动条件检查：确认对方场上有1张能被无效化的表侧表示卡。
		and Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向发动玩家显示“请选择自己的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)  --"请选择自己的卡"
	-- 选择自己场上1张除自身以外可被无效化的表侧表示卡作为对象。
	Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 向发动玩家显示“请选择对方的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)  --"请选择对方的卡"
	-- 选择对方场上1张可被无效化的表侧表示卡作为对象。
	Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
end
-- ②效果处理：获取连锁中仍可无效的2张对象卡，对每张卡赋予直到回合结束时效果无效、效果发动无效的处理；若对象是陷阱怪兽，也一并无效其陷阱怪兽化状态。
function c22423493.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取回当前连锁关联的对象卡，并筛选出仍可被无效化的卡。
	local g=Duel.GetTargetsRelateToChain():Filter(aux.NegateAnyFilter,nil)
	if g:GetCount()~=2 then return end
	-- 遍历所有需要无效化的对象卡，逐张附加无效效果。
	for tc in aux.Next(g) do
		-- 将与该卡相关的连锁效果无效化，重置时机为回合结束时/变里侧等。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- “那2张卡的效果直到回合结束时无效。”（无效对象卡效果的部分）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- “那2张卡的效果直到回合结束时无效。”（无效对象卡效果发动的部分）
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- “那2张卡的效果直到回合结束时无效。”（对象为陷阱怪兽时无效其陷阱怪兽化状态）
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
-- 判定特殊召唤的怪兽是否位于这张卡的连接区域：若仍在场上则检查是否被这张卡连接箭头所指；若已离场则根据离场前的位置与控制者判断。
function c22423493.thcfilter(c,ec)
	if c:IsLocation(LOCATION_MZONE) then
		return ec:GetLinkedGroup():IsContains(c)
	else
		return bit.extract(ec:GetLinkedZone(c:GetPreviousControler()),c:GetPreviousSequence())~=0
	end
end
-- ③的发动条件：特殊召唤成功的怪兽群中不包含这张卡自身，且恰好有2只在这张卡的连接区域同时特殊召唤。
function c22423493.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not eg:IsContains(c) and eg:FilterCount(c22423493.thcfilter,nil,c)==2
end
-- 检索过滤条件：5星以上的机械族怪兽，并且可以被加入手卡。
function c22423493.thfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsLevelAbove(5) and c:IsAbleToHand()
end
-- ③的发动判定：检查卡组中是否存在1只满足检索条件的机械族怪兽；并设置操作信息为从卡组把1张卡加入手卡。
function c22423493.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在1张满足条件（5星以上机械族且可加入手卡）的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c22423493.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次效果处理信息为“从卡组将1张卡加入持有者手卡”，供连锁与效果判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③的效果处理：从卡组选择1张5星以上机械族怪兽加入手卡，并让对手确认。
function c22423493.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足条件（5星以上机械族且可加入手卡）的卡。
	local g=Duel.SelectMatchingCard(tp,c22423493.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡，这是效果处理造成的移动。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示本次加入手卡的卡牌确认信息。
		Duel.ConfirmCards(1-tp,g)
	end
end
