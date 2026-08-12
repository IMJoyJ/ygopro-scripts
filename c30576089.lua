--ブルーアイズ・ジェット・ドラゴン
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次，若非自己的场上或墓地有「青眼白龙」存在的场合则不能发动。
-- ①：这张卡在手卡·墓地存在，场上的卡被战斗·效果破坏的场合才能发动。这张卡特殊召唤。
-- ②：只要这张卡在怪兽区域存在，自己场上的其他卡不会被对方的效果破坏。
-- ③：这张卡进行战斗的伤害步骤开始时，以对方场上1张卡为对象才能发动。那张卡回到手卡。
function c30576089.initial_effect(c)
	-- 记录此卡具有「青眼白龙」的卡名
	aux.AddCodeList(c,89631139)
	-- ①：这张卡在手卡·墓地存在，场上的卡被战斗·效果破坏的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30576089,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,30576089)
	e1:SetCondition(c30576089.spcon)
	e1:SetTarget(c30576089.sptg)
	e1:SetOperation(c30576089.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己场上的其他卡不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(c30576089.indtg)
	-- 设置效果值为过滤函数aux.indoval，用于判断是否不会被对方效果破坏
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- ③：这张卡进行战斗的伤害步骤开始时，以对方场上1张卡为对象才能发动。那张卡回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(30576089,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,30576090)
	e3:SetCondition(c30576089.condition)
	e3:SetTarget(c30576089.thtg)
	e3:SetOperation(c30576089.thop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断场上或墓地是否存在「青眼白龙」
function c30576089.cfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsCode(89631139)
end
-- 判断是否满足发动条件①③的前提：自己场上或墓地存在「青眼白龙」
function c30576089.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上或墓地是否存在「青眼白龙」
	return Duel.IsExistingMatchingCard(c30576089.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
end
-- 过滤函数：判断被破坏的卡是否来自场上且由战斗或效果破坏
function c30576089.spfilter(c)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 综合判断①效果的发动条件：满足前提条件且被破坏的卡中存在符合条件的卡
function c30576089.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c30576089.condition(e,tp,eg,ep,ev,re,r,rp) and eg:IsExists(c30576089.spfilter,1,nil) and (not eg:IsContains(c) or c:IsLocation(LOCATION_HAND))
end
-- 设置①效果的发动目标：检查是否有足够的特殊召唤区域并可特殊召唤
function c30576089.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有足够的特殊召唤区域并可特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：将此卡加入特殊召唤的处理对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的处理函数：将此卡特殊召唤
function c30576089.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 设置②效果的目标过滤函数：排除自身
function c30576089.indtg(e,c)
	return c~=e:GetHandler()
end
-- ③效果的目标选择函数：选择对方场上的1张可送回手牌的卡
function c30576089.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 检查对方场上是否存在可送回手牌的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要送回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上的1张可送回手牌的卡
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息：将选中的卡加入送回手牌的处理对象
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ③效果的处理函数：将目标卡送回手牌
function c30576089.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡送回手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
