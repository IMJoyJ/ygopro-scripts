--No.90 銀河眼の光子卿
-- 效果：
-- 8星怪兽×2
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：有「光子」卡在作为超量素材中的这张卡不会被效果破坏。
-- ②：对方把怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个效果无效。取除的超量素材是「银河」卡的场合，再把那只怪兽破坏。
-- ③：对方回合才能发动。从卡组选1张「光子」卡或「银河」卡加入手卡或作为这张卡的超量素材。
function c8165596.initial_effect(c)
	-- 添加超量召唤手续：8星怪兽×2。
	aux.AddXyzProcedure(c,nil,8,2)
	c:EnableReviveLimit()
	-- ①：有「光子」卡在作为超量素材中的这张卡不会被效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c8165596.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：对方把怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个效果无效。取除的超量素材是「银河」卡的场合，再把那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(8165596,0))  --"效果无效"
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,8165596)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(c8165596.negcon)
	e2:SetCost(c8165596.negcost)
	e2:SetTarget(c8165596.negtg)
	e2:SetOperation(c8165596.negop)
	c:RegisterEffect(e2)
	-- ③：对方回合才能发动。从卡组选1张「光子」卡或「银河」卡加入手卡或作为这张卡的超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetDescription(aux.Stringid(8165596,1))  --"卡组检索或补充超量素材"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,8165597)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c8165596.condition)
	e3:SetTarget(c8165596.target)
	e3:SetOperation(c8165596.operation)
	c:RegisterEffect(e3)
end
-- 设置该怪兽的「No.」编号为90。
aux.xyz_number[8165596]=90
-- 定义效果①的生效条件：这张卡的超量素材中存在「光子」卡。
function c8165596.indcon(e)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,0x55)
end
-- 定义效果②的发动条件：对方发动怪兽效果，且该效果可以被无效。
function c8165596.negcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
		-- 检查发动的效果是否为怪兽效果，且该连锁效果是否可以被无效。
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end
-- 定义效果②的代价：取除这张卡的1个超量素材，并记录被取除的卡。
function c8165596.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	-- 获取刚刚作为代价被取除的超量素材卡。
	local ct=Duel.GetOperatedGroup():GetFirst()
	e:SetLabelObject(ct)
end
-- 定义效果②的靶向与操作信息：确立无效效果的操作，若取除的是「银河」卡且对方怪兽可破坏，则确立破坏操作。
function c8165596.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁信息：该效果包含无效该怪兽效果的操作。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and e:GetLabelObject():IsSetCard(0x7b) then
		-- 设置连锁信息：该效果包含破坏该怪兽的操作。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,re:GetHandler(),1,0,0)
	end
end
-- 定义效果②的效果处理：使发动的效果无效，若取除的素材是「银河」卡，则再将该怪兽破坏。
function c8165596.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功无效效果，且该怪兽卡在场，且取除的超量素材是「银河」卡。
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) and e:GetLabelObject():IsSetCard(0x7b) then
		-- 因效果将该怪兽破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 定义效果③的发动条件：当前是对方的回合。
function c8165596.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否不是自己（即对方回合）。
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤卡组中满足条件的「光子」或「银河」卡：可以加入手牌，或者可以作为超量素材叠放。
function c8165596.filter(c,mc)
	return c:IsSetCard(0x55,0x7b) and (c:IsAbleToHand() or (mc:IsType(TYPE_XYZ) and c:IsCanOverlay()))
end
-- 定义效果③的靶向与发动准备：检查卡组中是否存在符合条件的「光子」或「银河」卡。
function c8165596.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动准备阶段，检查卡组中是否存在至少1张符合过滤条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c8165596.filter,tp,LOCATION_DECK,0,1,nil,e:GetHandler()) end
end
-- 定义效果③的效果处理：从卡组选1张「光子」或「银河」卡，由玩家选择加入手牌或作为这张卡的超量素材。
function c8165596.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌（或作为素材）的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local c=e:GetHandler()
	-- 让玩家从卡组中选择1张符合条件的「光子」或「银河」卡。
	local g=Duel.SelectMatchingCard(tp,c8165596.filter,tp,LOCATION_DECK,0,1,1,nil,c)
	local tc=g:GetFirst()
	if tc then
		-- 判断这张卡是否是超量怪兽、选中的卡是否可以作为素材，且（选中的卡不能加入手牌，或者玩家主动选择将其作为超量素材）。
		if c:IsType(TYPE_XYZ) and tc:IsCanOverlay() and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,aux.Stringid(8165596,2))==1) then  --"重叠作为超量素材"
			-- 将选中的卡作为超量素材重叠在这张卡下面。
			Duel.Overlay(c,Group.FromCards(tc))
		else
			-- 将选中的卡加入玩家手牌。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手牌的卡。
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end
