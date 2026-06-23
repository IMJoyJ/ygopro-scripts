--御巫の祓舞
-- 效果：
-- 「御巫」怪兽才能装备。这个卡名的②的效果1回合只能使用1次。
-- ①：装备怪兽不会被效果破坏。
-- ②：对方场上有怪兽特殊召唤的场合，以自己以及对方场上的怪兽各1只为对象才能发动。那些怪兽回到手卡。
function c16433136.initial_effect(c)
	-- ①：装备怪兽不会被效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c16433136.target)
	e1:SetOperation(c16433136.activate)
	c:RegisterEffect(e1)
	-- 「御巫」怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c16433136.eqlimit)
	c:RegisterEffect(e2)
	-- ①：装备怪兽不会被效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ②：对方场上有怪兽特殊召唤的场合，以自己以及对方场上的怪兽各1只为对象才能发动。那些怪兽回到手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(16433136,0))  --"双方怪兽回到手卡"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,16433136)
	e4:SetCondition(c16433136.thcon)
	e4:SetTarget(c16433136.thtg)
	e4:SetOperation(c16433136.thop)
	c:RegisterEffect(e4)
end
-- 筛选「御巫」怪兽
function c16433136.filter(c)
	return c:IsSetCard(0x18d) and c:IsFaceup()
end
-- 选择1只自己场上的「御巫」怪兽作为装备对象
function c16433136.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c16433136.filter(chkc) end
	-- 检查是否有1只自己场上的「御巫」怪兽可以作为装备对象
	if chk==0 then return Duel.IsExistingTarget(c16433136.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 选择1只自己场上的「御巫」怪兽作为装备对象
	local g=Duel.SelectTarget(tp,c16433136.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
-- 装备卡效果处理
function c16433136.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁对象卡
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 装备对象为「御巫」怪兽
function c16433136.eqlimit(e,c)
	return c:IsSetCard(0x18d)
end
-- 对方场上有怪兽特殊召唤成功
function c16433136.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end
-- 选择双方场上的怪兽各1只作为对象
function c16433136.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否有怪兽可以返回手卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否有怪兽可以返回手卡
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示选择要返回手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上的1只怪兽返回手卡
	local g1=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示选择要返回手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上的1只怪兽返回手卡
	local g2=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	-- 设置效果处理信息为返回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
end
-- 处理效果：将对象怪兽返回手卡
function c16433136.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的对象卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将对象卡组送回手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
