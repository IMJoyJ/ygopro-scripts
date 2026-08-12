--バージェストマ・オパビニア
-- 效果：
-- 2星怪兽×2
-- 「伯吉斯异兽·欧巴宾海蝎」的③的效果1回合只能使用1次。
-- ①：这张卡不受其他怪兽的效果影响。
-- ②：只要这张卡在怪兽区域存在，自己可以把「伯吉斯异兽」陷阱卡从手卡发动。
-- ③：这张卡有陷阱卡在作为超量素材的场合，把这张卡1个超量素材取除才能发动。从卡组把1张「伯吉斯异兽」陷阱卡加入手卡。
function c37649320.initial_effect(c)
	-- 添加XYZ召唤手续，使用2星怪兽叠放，最少2只最多2只
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
	-- 设置效果目标为持有「伯吉斯异兽」卡名的陷阱卡
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xd4))
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetValue(37649320)
	c:RegisterEffect(e2)
	-- ③：这张卡有陷阱卡在作为超量素材的场合，把这张卡1个超量素材取除才能发动。从卡组把1张「伯吉斯异兽」陷阱卡加入手卡。
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
-- 效果值函数，返回true表示该效果不被自身怪兽效果影响
function c37649320.efilter(e,re)
	return re:IsActiveType(TYPE_MONSTER) and re:GetOwner()~=e:GetOwner()
end
-- 条件函数，判断该卡是否有陷阱卡作为超量素材
function c37649320.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsType,1,nil,TYPE_TRAP)
end
-- 费用函数，消耗1个超量素材作为发动代价
function c37649320.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 检索过滤函数，筛选「伯吉斯异兽」陷阱卡
function c37649320.thfilter(c)
	return c:IsSetCard(0xd4) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- 发动时的处理函数，设置将要检索的卡组中的陷阱卡
function c37649320.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c37649320.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将要从卡组检索陷阱卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，选择并把符合条件的陷阱卡加入手牌
function c37649320.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的陷阱卡
	local g=Duel.SelectMatchingCard(tp,c37649320.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
