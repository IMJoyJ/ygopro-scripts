--ブルーアイズ・ジェット・ドラゴン
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次，若非自己的场上或墓地有「青眼白龙」存在的场合则不能发动。
-- ①：这张卡在手卡·墓地存在，场上的卡被战斗·效果破坏的场合才能发动。这张卡特殊召唤。
-- ②：只要这张卡在怪兽区域存在，自己场上的其他卡不会被对方的效果破坏。
-- ③：这张卡进行战斗的伤害步骤开始时，以对方场上1张卡为对象才能发动。那张卡回到手卡。
function c30576089.initial_effect(c)
	-- 将卡号89631139（青眼白龙）登记到本卡的记载卡名列表中，用于支持“有「青眼白龙」存在”等文本相关判定。
	aux.AddCodeList(c,89631139)
	-- 这个卡名的①③的效果1回合各能使用1次，若非自己的场上或墓地有「青眼白龙」存在的场合则不能发动。①：这张卡在手卡·墓地存在，场上的卡被战斗·效果破坏的场合才能发动。这张卡特殊召唤。
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
	-- 设置该免疫效果的判定值为aux.indoval，即只对对方发动的效果生效，从而实现“不会被对方的效果破坏”。
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- 这个卡名的①③的效果1回合各能使用1次，若非自己的场上或墓地有「青眼白龙」存在的场合则不能发动。③：这张卡进行战斗的伤害步骤开始时，以对方场上1张卡为对象才能发动。那张卡回到手卡。
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
-- 定义筛选“青眼白龙”的过滤函数：卡为表侧表示（场上）或在墓地，且卡号为89631139，用于检查己方场上·墓地是否存在「青眼白龙」。
function c30576089.cfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsCode(89631139)
end
-- ①③共同的发动前置条件：在己方场上·墓地是否存在至少1张满足cfilter条件的「青眼白龙」。
function c30576089.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 以tp为视角检查己方场上（表侧）和墓地中是否存在至少1张「青眼白龙」，作为本卡效果的发动限制。
	return Duel.IsExistingMatchingCard(c30576089.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
end
-- 定义被破坏卡的过滤条件：该卡被破坏前位于场上，且破坏原因为战斗或效果，用于判定“场上的卡被战斗·效果破坏”。
function c30576089.spfilter(c)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- ①效果的发动条件：满足“己方场上有「青眼白龙」”的前置条件；本次破坏事件中存在至少1张场上的卡被战斗/效果破坏；若破坏的卡中包含效果发动者自身，则发动者必须是在手牌（而非墓地）状态。
function c30576089.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c30576089.condition(e,tp,eg,ep,ev,re,r,rp) and eg:IsExists(c30576089.spfilter,1,nil) and (not eg:IsContains(c) or c:IsLocation(LOCATION_HAND))
end
-- ①效果的目标设定与合法性检查：在发动时确认己方怪兽区域有空位，且本卡能够被特殊召唤；随后将操作信息登记为特殊召唤本卡。
function c30576089.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动时检查tp的主要怪兽区域空格数大于0，且本卡不检查召唤条件、不检查苏生限制即可特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，标明本效果将特殊召唤本卡，数量为1，供后续处理及相关卡片的联动检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理时：若本卡仍与效果关联，则将其特殊召唤上场。
function c30576089.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将本卡以表侧表示特殊召唤到tp场上，不经过召唤条件/苏生限制的检查。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 免疫效果的目标过滤函数：仅保护除本卡自身以外的卡，即自己场上的其他卡不会受到对方效果破坏。
function c30576089.indtg(e,c)
	return c~=e:GetHandler()
end
-- ③效果的目标选择与合法性判定：选择对方场上的1张能够加入手卡的卡作为对象，并登记回手牌操作信息。
function c30576089.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 在发动时检查对方场上是否存在至少1张能够被选择为对象并加入手卡的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 弹出选择提示，提示玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让tp从对方场上选择1张能够加入手卡的卡，并将其设为该效果的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，将所选对象卡作为本次回手牌效果的对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ③效果处理时：取得对象卡，若对象卡仍与该效果关联，则将其送回持有者手卡。
function c30576089.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中登记的唯一对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡送回其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
