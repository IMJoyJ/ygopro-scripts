--天威龍－ヴィシュダ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上没有效果怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己场上有效果怪兽以外的表侧表示怪兽存在的场合，把手卡·墓地的这张卡除外，以对方场上1张卡为对象才能发动。那张卡回到持有者手卡。
function c23431858.initial_effect(c)
	-- ①：自己场上没有效果怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23431858,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,23431858)
	e1:SetCondition(c23431858.spcon)
	e1:SetTarget(c23431858.sptg)
	e1:SetOperation(c23431858.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上有效果怪兽以外的表侧表示怪兽存在的场合，把手卡·墓地的这张卡除外，以对方场上1张卡为对象才能发动。那张卡回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23431858,1))  --"对方卡回到手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCountLimit(1,23431859)
	e2:SetCondition(c23431858.thcon)
	-- 效果cost为把这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c23431858.thtg)
	e2:SetOperation(c23431858.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在正面表示的效果怪兽
function c23431858.spcfilter(c)
	return c:IsType(TYPE_EFFECT) and c:IsFaceup()
end
-- 效果条件函数，判断自己场上是否没有效果怪兽
function c23431858.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否没有效果怪兽
	return not Duel.IsExistingMatchingCard(c23431858.spcfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果目标函数，判断是否满足特殊召唤的条件
function c23431858.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理时将要特殊召唤的卡片信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数，执行特殊召唤操作
function c23431858.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡片特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于判断场上是否存在正面表示的非效果怪兽
function c23431858.thcfilter(c)
	return not c:IsType(TYPE_EFFECT) and c:IsFaceup()
end
-- 效果条件函数，判断自己场上是否存在效果怪兽以外的表侧表示怪兽
function c23431858.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否存在效果怪兽以外的表侧表示怪兽
	return Duel.IsExistingMatchingCard(c23431858.thcfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果目标函数，选择对方场上的卡作为对象
function c23431858.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 判断对方场上是否存在可以送回手牌的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要送回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理时将要送回手牌的卡片信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理函数，执行将卡送回手牌的操作
function c23431858.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片送回手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
