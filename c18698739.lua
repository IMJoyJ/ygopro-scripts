--ガーベージ・オーガ
-- 效果：
-- 自己的主要阶段时，把这张卡从手卡送去墓地才能发动。从卡组把1只「垃圾王」加入手卡。「垃圾食人魔」的效果1回合只能使用1次。
function c18698739.initial_effect(c)
	-- 效果原文内容：自己的主要阶段时，把这张卡从手卡送去墓地才能发动。从卡组把1只「垃圾王」加入手卡。「垃圾食人魔」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18698739,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,18698739)
	e1:SetCost(c18698739.cost)
	e1:SetTarget(c18698739.target)
	e1:SetOperation(c18698739.operation)
	c:RegisterEffect(e1)
end
-- 规则层面操作：检查是否可以支付将此卡送去墓地作为代价
function c18698739.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 规则层面操作：将此卡送去墓地作为代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 规则层面操作：定义检索卡牌的过滤条件，即卡号为44682448且可以送去手卡的卡
function c18698739.filter(c)
	return c:IsCode(44682448) and c:IsAbleToHand()
end
-- 规则层面操作：设置连锁处理信息，表明效果发动时会从卡组检索1张「垃圾王」加入手卡
function c18698739.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查卡组中是否存在满足条件的「垃圾王」
	if chk==0 then return Duel.IsExistingMatchingCard(c18698739.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 规则层面操作：设置连锁处理信息，表明效果发动时会从卡组检索1张「垃圾王」加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 规则层面操作：执行效果处理，从卡组检索满足条件的「垃圾王」并加入手卡，同时确认对方查看该卡
function c18698739.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：从卡组中检索满足条件的第一张「垃圾王」
	local tc=Duel.GetFirstMatchingCard(c18698739.filter,tp,LOCATION_DECK,0,nil)
	if tc then
		-- 规则层面操作：将检索到的「垃圾王」加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 规则层面操作：确认对方查看该张加入手卡的「垃圾王」
		Duel.ConfirmCards(1-tp,tc)
	end
end
