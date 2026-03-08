--戦華の仲－孫謀
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要自己场上有其他的「战华」怪兽存在，对方不能选择这张卡作为攻击对象。
-- ②：从自己的手卡·场上把1张卡送去墓地才能发动。从卡组把「战华之仲-孙谋」以外的1只「战华」怪兽加入手卡。
-- ③：这张卡以外的自己的「战华」怪兽的效果发动的场合，以对方场上1只怪兽为对象才能发动。那只怪兽回到持有者手卡。
function c40140448.initial_effect(c)
	-- ①：只要自己场上有其他的「战华」怪兽存在，对方不能选择这张卡作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetCondition(c40140448.atcon)
	-- 设置该效果为使自身不能成为攻击对象的效果
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	-- ②：从自己的手卡·场上把1张卡送去墓地才能发动。从卡组把「战华之仲-孙谋」以外的1只「战华」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40140448,0))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,40140448)
	e2:SetCost(c40140448.srcost)
	e2:SetTarget(c40140448.srtg)
	e2:SetOperation(c40140448.srop)
	c:RegisterEffect(e2)
	-- ③：这张卡以外的自己的「战华」怪兽的效果发动的场合，以对方场上1只怪兽为对象才能发动。那只怪兽回到持有者手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(40140448,1))  --"回到手卡"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,40140449)
	e4:SetCondition(c40140448.thcon)
	e4:SetTarget(c40140448.thtg)
	e4:SetOperation(c40140448.thop)
	c:RegisterEffect(e4)
end
-- 过滤函数：判断一张卡是否为表侧表示的「战华」怪兽
function c40140448.atfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x137)
end
-- 条件函数：判断自己场上是否存在其他「战华」怪兽
function c40140448.atcon(e)
	-- 检查自己场上是否存在至少1张其他「战华」怪兽
	return Duel.IsExistingMatchingCard(c40140448.atfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
-- 效果Cost函数：选择1张手卡或场上的卡送去墓地作为代价
function c40140448.srcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足送去墓地的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	-- 选择满足条件的1张卡送去墓地
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	-- 将选中的卡送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 检索过滤函数：判断一张卡是否为「战华」怪兽且能加入手牌且不是此卡
function c40140448.srfilter(c)
	return c:IsSetCard(0x137) and c:IsAbleToHand() and not c:IsCode(40140448) and c:IsType(TYPE_MONSTER)
end
-- 效果Target函数：检查卡组中是否存在满足条件的「战华」怪兽
function c40140448.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「战华」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c40140448.srfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：准备从卡组检索1张「战华」怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果Operation函数：从卡组检索1张「战华」怪兽加入手牌并确认
function c40140448.srop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张卡从卡组加入手牌
	local g=Duel.SelectMatchingCard(tp,c40140448.srfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 诱发效果条件函数：判断对方发动的怪兽效果是否为「战华」怪兽且不是此卡
function c40140448.thcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x137) and rp==tp and re:GetHandler()~=e:GetHandler()
end
-- 效果Target函数：选择对方场上1只怪兽作为对象
function c40140448.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 检查对方场上是否存在至少1只可以返回手牌的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要返回手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1只怪兽作为对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：准备将1只怪兽返回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果Operation函数：将对象怪兽返回手牌
function c40140448.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽返回手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
