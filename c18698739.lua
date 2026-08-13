--ガーベージ・オーガ
-- 效果：
-- 自己的主要阶段时，把这张卡从手卡送去墓地才能发动。从卡组把1只「垃圾王」加入手卡。「垃圾食人魔」的效果1回合只能使用1次。
function c18698739.initial_effect(c)
	-- 自己的主要阶段时，把这张卡从手卡送去墓地才能发动。从卡组把1只「垃圾王」加入手卡。「垃圾食人魔」的效果1回合只能使用1次。
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
-- 代价函数：当chk==0（合法性检查）时，返回这张手牌中的卡是否可作为代价送去墓地；当chk==1（实际支付）时，将这张卡从手牌送去墓地作为发动代价。
function c18698739.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 以“代价”的原因将效果持有者（这张卡）从手牌送入墓地，完成发动代价的支付。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 检索过滤条件：卡名必须是「垃圾王」（44682448），且这张卡能够被加入手牌。
function c18698739.filter(c)
	return c:IsCode(44682448) and c:IsAbleToHand()
end
-- 目标函数：在chk==0时检查卡组中是否存在符合条件的「垃圾王」；若存在则设置操作信息，表示效果处理时将从卡组把1张卡加入手牌（不取对象）。
function c18698739.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前合法性检查：确认卡组中存在至少1张符合条件的「垃圾王」，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c18698739.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次效果的操作信息：效果处理时会从卡组将1张卡加入手牌，用于后续效果检测与连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：从卡组中获取符合条件的「垃圾王」，若存在则将其加入手牌，并向对方玩家确认该卡。
function c18698739.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从自己卡组中获取第一张符合条件的「垃圾王」（不取对象检索），若不存在则效果处理不执行检索。
	local tc=Duel.GetFirstMatchingCard(c18698739.filter,tp,LOCATION_DECK,0,nil)
	if tc then
		-- 以“效果”的原因将检索到的「垃圾王」加入其持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 将检索到的卡展示给对方玩家确认，以符合公开检索信息的规则要求。
		Duel.ConfirmCards(1-tp,tc)
	end
end
