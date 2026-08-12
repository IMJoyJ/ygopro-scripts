--クリフォート・ゲニウス
-- 效果：
-- 机械族怪兽2只
-- ①：连接召唤的这张卡不受魔法·陷阱卡的效果影响，也不受这张卡以外的连接怪兽发动的效果影响。
-- ②：1回合1次，以这张卡以外的自己以及对方场上的表侧表示的卡各1张为对象才能发动。那2张卡的效果直到回合结束时无效。
-- ③：这张卡所连接区有怪兽2只同时特殊召唤时才能发动。从卡组把1只5星以上的机械族怪兽加入手卡。
function c22423493.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，要求使用2只以上2只以下的机械族连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_MACHINE),2,2)
	-- ①：连接召唤的这张卡不受魔法·陷阱卡的效果影响，也不受这张卡以外的连接怪兽发动的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetCondition(c22423493.immcon)
	e1:SetValue(c22423493.efilter)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以这张卡以外的自己以及对方场上的表侧表示的卡各1张为对象才能发动。那2张卡的效果直到回合结束时无效。
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
	-- ③：这张卡所连接区有怪兽2只同时特殊召唤时才能发动。从卡组把1只5星以上的机械族怪兽加入手卡。
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
-- 效果适用条件：此卡为连接召唤
function c22423493.immcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果适用对象：魔法·陷阱卡或非此卡的连接怪兽发动的效果
function c22423493.efilter(e,te)
	if te:IsActiveType(TYPE_SPELL+TYPE_TRAP) then return true
	else return te:IsActiveType(TYPE_LINK) and te:IsActivated() and te:GetOwner()~=e:GetOwner() end
end
-- 效果发动时选择目标：选择自己场上的1张表侧表示的卡和对方场上的1张表侧表示的卡
function c22423493.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查是否满足选择目标条件：自己场上存在满足条件的卡
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
		-- 检查是否满足选择目标条件：对方场上存在满足条件的卡
		and Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择自己的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)  --"请选择自己的卡"
	-- 选择自己场上的1张表侧表示的卡
	Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 提示玩家选择对方的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)  --"请选择对方的卡"
	-- 选择对方场上的1张表侧表示的卡
	Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
end
-- 效果处理：使选择的2张卡的效果无效化
function c22423493.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁相关的2张目标卡
	local g=Duel.GetTargetsRelateToChain():Filter(aux.NegateAnyFilter,nil)
	if g:GetCount()~=2 then return end
	-- 遍历目标卡组中的每张卡
	for tc in aux.Next(g) do
		-- 使目标卡的连锁无效
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标卡的效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标卡的效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 使目标陷阱怪兽的效果无效
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
-- 判断特殊召唤的怪兽是否为连接区的怪兽
function c22423493.thcfilter(c,ec)
	if c:IsLocation(LOCATION_MZONE) then
		return ec:GetLinkedGroup():IsContains(c)
	else
		return bit.extract(ec:GetLinkedZone(c:GetPreviousControler()),c:GetPreviousSequence())~=0
	end
end
-- 效果发动条件：非此卡的2只怪兽同时特殊召唤
function c22423493.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not eg:IsContains(c) and eg:FilterCount(c22423493.thcfilter,nil,c)==2
end
-- 检索条件：5星以上机械族怪兽
function c22423493.thfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsLevelAbove(5) and c:IsAbleToHand()
end
-- 效果发动时的处理：检索满足条件的卡
function c22423493.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件：卡组中存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c22423493.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：选择并加入手牌
function c22423493.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c22423493.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
