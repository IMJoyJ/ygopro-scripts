--戦華の妙－魯敬
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1张永续魔法·永续陷阱卡为对象才能发动。那张卡送去墓地，从自己墓地选和那张卡卡名不同的1张「战华」魔法·陷阱卡加入手卡。
-- ②：这张卡以外的自己的「战华」怪兽的效果发动的场合，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
function c13923256.initial_effect(c)
	-- ①：以自己场上1张永续魔法·永续陷阱卡为对象才能发动。那张卡送去墓地，从自己墓地选和那张卡卡名不同的1张「战华」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13923256,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,13923256)
	e1:SetTarget(c13923256.thtg)
	e1:SetOperation(c13923256.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡以外的自己的「战华」怪兽的效果发动的场合，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(13923256,1))  --"魔陷破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,13923257)
	e3:SetCondition(c13923256.descon)
	e3:SetTarget(c13923256.destg)
	e3:SetOperation(c13923256.desop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断目标卡是否满足①效果的发动条件
function c13923256.tgfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and c:IsAbleToGrave()
		-- 检查在墓地中是否存在与目标卡卡名不同的「战华」魔法·陷阱卡
		and Duel.IsExistingMatchingCard(c13923256.thfilter,tp,LOCATION_GRAVE,0,1,nil,c:GetCode())
end
-- 过滤函数，用于从墓地中选择满足条件的「战华」魔法·陷阱卡
function c13923256.thfilter(c,code)
	return c:IsSetCard(0x137) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand() and not c:IsCode(code)
end
-- ①效果的发动时点处理函数
function c13923256.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c13923256.tgfilter(chkc,tp) end
	-- 检查是否满足①效果的发动条件
	if chk==0 then return Duel.IsExistingTarget(c13923256.tgfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 选择满足条件的1张卡作为①效果的对象
	local g=Duel.SelectTarget(tp,c13923256.tgfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 设置①效果的处理信息，将目标卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	-- 设置①效果的处理信息，从墓地选卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- ①效果的处理函数
function c13923256.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取①效果的目标卡
	local tc=Duel.GetFirstTarget()
	-- 确认目标卡有效并将其送去墓地
	if tc:IsRelateToEffect(e) and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		-- 从墓地中选择满足条件的1张卡加入手牌
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c13923256.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,tc:GetCode())
		if g:GetCount()>0 then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- ②效果的发动条件判断函数
function c13923256.descon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x137) and rp==tp and re:GetHandler()~=e:GetHandler()
end
-- ②效果的发动时点处理函数
function c13923256.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	-- 检查是否满足②效果的发动条件
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,0,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择满足条件的1张卡作为②效果的对象
	local g=Duel.SelectTarget(tp,Card.IsType,tp,0,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
	-- 设置②效果的处理信息，将目标卡破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果的处理函数
function c13923256.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
