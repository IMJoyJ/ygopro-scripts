--天威龍－ヴィシュダ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上没有效果怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己场上有效果怪兽以外的表侧表示怪兽存在的场合，把手卡·墓地的这张卡除外，以对方场上1张卡为对象才能发动。那张卡回到持有者手卡。
function c23431858.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己场上没有效果怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
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
	-- 这个卡名的①②的效果1回合各能使用1次。②：自己场上有效果怪兽以外的表侧表示怪兽存在的场合，把手卡·墓地的这张卡除外，以对方场上1张卡为对象才能发动。那张卡回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23431858,1))  --"对方卡回到手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCountLimit(1,23431859)
	e2:SetCondition(c23431858.thcon)
	-- 设置②效果的发动代价：将这张卡从手卡·墓地除外（aux.bfgcost 实现除外自身作为cost）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c23431858.thtg)
	e2:SetOperation(c23431858.thop)
	c:RegisterEffect(e2)
end
-- 定义过滤函数 spcfilter：判断卡片是否为表侧表示的效果怪兽，用于检查场上是否存在效果怪兽。
function c23431858.spcfilter(c)
	return c:IsType(TYPE_EFFECT) and c:IsFaceup()
end
-- 效果①的发动条件：自己场上没有效果怪兽存在的场合才能发动。
function c23431858.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上（主要怪兽区）不存在表侧表示的效果怪兽。
	return not Duel.IsExistingMatchingCard(c23431858.spcfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①发动时的合法性检查：自己场上存在可用的怪兽区域，且这张手牌怪兽能够被特殊召唤。
function c23431858.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有至少1个可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁的操作信息：本次效果处理涉及特殊召唤，要特殊召唤的是这张卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的处理：若这张卡仍与效果关联，则将其表侧表示特殊召唤。
function c23431858.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 由tp将这张卡以表侧表示特殊召唤到tp场上，并正常检查召唤条件与苏生限制。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义过滤函数 thcfilter：判断卡片是否为表侧表示且不是效果怪兽，即“效果怪兽以外的表侧表示怪兽”。
function c23431858.thcfilter(c)
	return not c:IsType(TYPE_EFFECT) and c:IsFaceup()
end
-- 效果②的发动条件：自己场上有效果怪兽以外的表侧表示怪兽存在的场合才能发动。
function c23431858.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上（主要怪兽区）是否存在至少1只表侧表示的非效果怪兽。
	return Duel.IsExistingMatchingCard(c23431858.thcfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果②的目标处理：连锁时校验所选对象为对方场上能回手卡的卡；发动时确认存在可选对象；随后提示玩家选择对方场上1张卡作为对象，并设置操作信息。
function c23431858.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 效果②发动时检查对方场上是否存在至少1张能够返回持有者手卡的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 显示“请选择要返回手牌的卡”的选择提示，用于玩家选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择对方场上1张能够返回手卡的卡作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置本次连锁的操作信息：本次效果处理涉及回手卡，对象为所选择的卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的处理：取得对象卡，若其仍与效果关联，则将其返回持有者手卡。
function c23431858.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的第一个效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因送回持有者手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
