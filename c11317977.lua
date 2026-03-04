--月光黒羊
-- 效果：
-- ①：可以把这张卡从手卡丢弃，从以下效果选择1个发动。
-- ●从自己墓地把「月光黑羊」以外的1只「月光」怪兽加入手卡。
-- ●从卡组把1张「融合」加入手卡。
-- ②：这张卡成为融合召唤的素材送去墓地的场合才能发动。从自己的额外卡组（表侧）·墓地把「月光黑羊」以外的1只「月光」怪兽加入手卡。
function c11317977.initial_effect(c)
	-- ①：可以把这张卡从手卡丢弃，从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11317977,0))  --"墓地回收"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c11317977.cost)
	e1:SetTarget(c11317977.thtg)
	e1:SetOperation(c11317977.thop)
	c:RegisterEffect(e1)
	-- ①：可以把这张卡从手卡丢弃，从以下效果选择1个发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11317977,1))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCost(c11317977.cost)
	e2:SetTarget(c11317977.sctg)
	e2:SetOperation(c11317977.scop)
	c:RegisterEffect(e2)
	-- ②：这张卡成为融合召唤的素材送去墓地的场合才能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCondition(c11317977.thcon2)
	e3:SetTarget(c11317977.thtg2)
	e3:SetOperation(c11317977.thop2)
	c:RegisterEffect(e3)
end
-- 支付代价：将自身从手卡丢弃
function c11317977.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将自身从手卡丢弃到墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
	-- 向对方提示发动了效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 检索满足条件的怪兽的过滤函数
function c11317977.thfilter(c)
	return c:IsSetCard(0xdf) and c:IsType(TYPE_MONSTER) and not c:IsCode(11317977) and c:IsAbleToHand()
end
-- 效果①的发动时的处理函数
function c11317977.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：自己墓地存在「月光」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c11317977.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置效果处理信息：将1张怪兽从墓地加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 效果①的发动处理函数
function c11317977.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择1张满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c11317977.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 检索满足条件的卡的过滤函数
function c11317977.scfilter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- 效果②的发动时的处理函数
function c11317977.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：自己卡组存在「融合」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c11317977.scfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的发动处理函数
function c11317977.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c11317977.scfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动条件函数
function c11317977.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_FUSION
end
-- 检索满足条件的怪兽的过滤函数
function c11317977.thfilter2(c)
	return c:IsSetCard(0xdf) and c:IsType(TYPE_MONSTER) and not c:IsCode(11317977) and c:IsAbleToHand()
		and ((c:IsFaceup() and c:IsLocation(LOCATION_EXTRA) and c:IsType(TYPE_PENDULUM)) or c:IsLocation(LOCATION_GRAVE))
end
-- 效果②的发动时的处理函数
function c11317977.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：自己墓地或额外卡组存在「月光」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c11317977.thfilter2,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil) end
	-- 设置效果处理信息：将1张怪兽从墓地或额外卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end
-- 效果②的发动处理函数
function c11317977.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择1张满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c11317977.thfilter2),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
