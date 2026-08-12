--ネメシス・コリドー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，以「星义绿廊兽」以外的自己的除外状态的1只怪兽为对象才能发动。这张卡特殊召唤，作为对象的怪兽回到卡组。
-- ②：以「星义绿廊兽」以外的自己的除外状态的1只「星义」怪兽为对象才能发动。那只怪兽加入手卡。
function c72090076.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，以「星义绿廊兽」以外的自己的除外状态的1只怪兽为对象才能发动。这张卡特殊召唤，作为对象的怪兽回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72090076,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,72090076)
	e1:SetTarget(c72090076.sptg)
	e1:SetOperation(c72090076.spop)
	c:RegisterEffect(e1)
	-- ②：以「星义绿廊兽」以外的自己的除外状态的1只「星义」怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(72090076,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,72090077)
	e2:SetTarget(c72090076.thtg)
	e2:SetOperation(c72090076.thop)
	c:RegisterEffect(e2)
end
-- 过滤出除外状态的、表侧表示的、非「星义绿廊兽」的、可以回到卡组的怪兽卡
function c72090076.tdfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and not c:IsCode(72090076) and c:IsAbleToDeck()
end
-- 效果①的发动准备与目标选择
function c72090076.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c72090076.tdfilter(chkc) end
	-- 判断自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断自己除外状态是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c72090076.tdfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己除外状态的1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c72090076.tdfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置特殊召唤此卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置将对象怪兽送回卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果①的效果处理，将此卡特殊召唤，并将对象怪兽送回卡组
function c72090076.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若此卡仍存在于手卡且成功特殊召唤，并且对象怪兽仍存在于除外区
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and tc:IsRelateToEffect(e) then
		-- 将对象怪兽送回持有者卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 过滤出除外状态的、表侧表示的、非「星义绿廊兽」的「星义」怪兽卡
function c72090076.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x13d) and c:IsType(TYPE_MONSTER) and not c:IsCode(72090076) and c:IsAbleToHand()
end
-- 效果②的发动准备与目标选择
function c72090076.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c72090076.thfilter(chkc) end
	-- 判断自己除外状态是否存在满足条件的「星义」怪兽
	if chk==0 then return Duel.IsExistingTarget(c72090076.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己除外状态的1只满足条件的「星义」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c72090076.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置将对象怪兽加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的效果处理，将对象怪兽加入手牌
function c72090076.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽加入持有者手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
