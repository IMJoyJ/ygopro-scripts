--バージェストマ・オパビニア
-- 效果：
-- 2星怪兽×2
-- 「伯吉斯异兽·欧巴宾海蝎」的③的效果1回合只能使用1次。
-- ①：这张卡不受其他怪兽的效果影响。
-- ②：只要这张卡在怪兽区域存在，自己可以把「伯吉斯异兽」陷阱卡从手卡发动。
-- ③：这张卡有陷阱卡在作为超量素材的场合，把这张卡1个超量素材取除才能发动。从卡组把1张「伯吉斯异兽」陷阱卡加入手卡。
function c37649320.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：用2只等级为2的怪兽叠放来XYZ召唤。
	aux.AddXyzProcedure(c,nil,2,2)
	c:EnableReviveLimit()
	-- ①：这张卡不受其他怪兽的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c37649320.efilter)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己可以把「伯吉斯异兽」陷阱卡从手卡发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37649320,1))  --"适用「伯吉斯异兽·欧巴宾海蝎」的效果来发动"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetRange(LOCATION_MZONE)
	-- 设置效果适用对象条件：仅当手牌中的卡是「伯吉斯异兽」陷阱卡时，才允许从手卡发动。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xd4))
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetValue(37649320)
	c:RegisterEffect(e2)
	-- 「伯吉斯异兽·欧巴宾海蝎」的③的效果1回合只能使用1次。③：这张卡有陷阱卡在作为超量素材的场合，把这张卡1个超量素材取除才能发动。从卡组把1张「伯吉斯异兽」陷阱卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(37649320,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,37649320)
	e3:SetCondition(c37649320.thcon)
	e3:SetCost(c37649320.thcost)
	e3:SetTarget(c37649320.thtg)
	e3:SetOperation(c37649320.thop)
	c:RegisterEffect(e3)
end
-- 判定免疫对象：该效果必须是怪兽效果，且效果持有者不是本卡的持有者，这样本卡才不受其影响。
function c37649320.efilter(e,re)
	return re:IsActiveType(TYPE_MONSTER) and re:GetOwner()~=e:GetOwner()
end
-- 发动条件判定：本卡持有的超量素材中存在陷阱卡时，③效果才能发动。
function c37649320.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsType,1,nil,TYPE_TRAP)
end
-- 发动代价处理：先检查能否取除1个超量素材，能满足则实际取除1张超量素材作为代价。
function c37649320.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 检索过滤器：卡组中满足「伯吉斯异兽」字段、是陷阱卡且可以被加入手卡的卡片。
function c37649320.thfilter(c)
	return c:IsSetCard(0xd4) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- 发动目标判定：检查卡组是否存在可检索的「伯吉斯异兽」陷阱卡，并设置本次连锁将1张卡加入手卡的操作信息。
function c37649320.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：卡组中是否存在至少1张符合条件的「伯吉斯异兽」陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c37649320.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：表示本次效果处理包含将卡组中的1张卡加入手卡（CATEGORY_TOHAND），供其他效果/时点检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1张「伯吉斯异兽」陷阱卡加入手卡，并让对手确认那张卡。
function c37649320.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出卡片选择提示，提示玩家从卡组中选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中筛选并选择1张满足条件的「伯吉斯异兽」陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c37649320.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡送去其持有者的手卡，即加入手牌，原因记为效果处理。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索加入手卡的卡展示给对手玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
