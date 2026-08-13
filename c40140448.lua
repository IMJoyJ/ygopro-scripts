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
	-- 设置①效果的判定值为aux.imval1，使不免疫该效果的怪兽不能选择这张卡作为攻击对象。
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
-- 过滤条件：场上表侧表示且拥有「战华」字段的怪兽。
function c40140448.atfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x137)
end
-- ①效果的适用条件：检查自己场上是否存在至少1只除自身以外的表侧表示「战华」怪兽。
function c40140448.atcon(e)
	-- 以效果持有者视角，在自己的怪兽区域查找除自身以外的表侧表示「战华」怪兽，若存在1只以上则返回true。
	return Duel.IsExistingMatchingCard(c40140448.atfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
-- ②效果的发动代价：从自己的手牌·场上选择1张卡送去墓地作为cost。
function c40140448.srcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以从自己的手牌·场上选出1张能作为代价送去墓地的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	-- 从自己的手牌·场上选择1张卡作为发动代价。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	-- 将选择的卡送去墓地，作为此次效果的发动代价。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 检索候选过滤条件：是「战华」怪兽、可以加入手牌、不是「战华之仲-孙谋」自身、且为怪兽卡。
function c40140448.srfilter(c)
	return c:IsSetCard(0x137) and c:IsAbleToHand() and not c:IsCode(40140448) and c:IsType(TYPE_MONSTER)
end
-- ②效果的发动目标判定：确认卡组中存在符合条件的「战华」怪兽，并设置效果处理信息为从卡组检索1张卡加入手牌。
function c40140448.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件：卡组中存在至少1只符合条件的「战华」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c40140448.srfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：本次效果将从卡组把1张卡加入手牌（检索操作）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1只符合条件的「战华」怪兽加入手牌，并向对方展示。
function c40140448.srop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，要求玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只符合条件的「战华」怪兽。
	local g=Duel.SelectMatchingCard(tp,c40140448.srfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ③效果的触发条件：自己场上这张卡以外的「战华」怪兽发动了怪兽效果，且该效果的发动者为这张卡的控制者。
function c40140448.thcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x137) and rp==tp and re:GetHandler()~=e:GetHandler()
end
-- ③效果的发动目标判定：检查并选择对方场上1只可返回手牌的怪兽为对象，同时设置效果处理信息为返回手牌。
function c40140448.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 发动条件：对方场上存在至少1只可以作为对象且能被返回手牌的怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示，要求玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从对方场上选择1只可返回手牌的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：本次效果将把已选择的1只对象怪兽返回手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ③效果处理：取得对象怪兽，若其仍与效果关联，则将其返回持有者手牌。
function c40140448.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本连锁中登记的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽返回其持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
