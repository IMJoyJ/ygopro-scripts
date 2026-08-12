--M∀LICE＜P＞March Hare
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，自己·对方的主要阶段才能发动。从自己的手卡·墓地把这张卡以外的1张「码丽丝」卡除外，这张卡特殊召唤。
-- ②：对方不能把有这张卡位于所连接区的「码丽丝」连接怪兽作为效果的对象。
-- ③：这张卡被除外的场合，支付300基本分，以自己的除外状态的1只「码丽丝」怪兽为对象才能发动。那只怪兽加入手卡。
local s,id,o=GetID()
-- 注册三个效果，分别是①特殊召唤、②免疫效果、③除外时加入手卡
function s.initial_effect(c)
	-- ①这张卡在手卡存在的场合，自己·对方的主要阶段才能发动。从自己的手卡·墓地把这张卡以外的1张「码丽丝」卡除外，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②对方不能把有这张卡位于所连接区的「码丽丝」连接怪兽作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置效果值为aux.tgoval函数，用于过滤不能成为对方效果对象的卡
	e2:SetValue(aux.tgoval)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.immtg)
	c:RegisterEffect(e2)
	-- ③这张卡被除外的场合，支付300基本分，以自己的除外状态的1只「码丽丝」怪兽为对象才能发动。那只怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"加入手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 判断是否处于主要阶段
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否处于主要阶段
	return Duel.IsMainPhase()
end
-- 过滤函数，用于筛选可除外的「码丽丝」卡
function s.cfilter(c)
	return c:IsAbleToRemove() and c:IsSetCard(0x1bf)
end
-- 设置特殊召唤和除外的处理信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断手卡或墓地是否存在符合条件的「码丽丝」卡
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置除外的处理信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 执行特殊召唤效果的处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择符合条件的「码丽丝」卡进行除外
	local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.cfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,aux.ExceptThisCard(e))
	-- 判断是否满足特殊召唤条件
	if sg:GetCount()>0 and Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) then
		-- 将卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 设置免疫效果的目标过滤函数
function s.immtg(e,c)
	local lg=c:GetLinkedGroup()
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsSetCard(0x1bf)
		and lg and lg:IsContains(e:GetHandler()) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 支付300基本分的处理函数
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否能支付300基本分
	if chk==0 then return Duel.CheckLPCost(tp,300) end
	-- 支付300基本分
	Duel.PayLPCost(tp,300)
end
-- 过滤函数，用于筛选可加入手牌的「码丽丝」怪兽
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1bf) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置加入手牌效果的处理信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 判断是否存在符合条件的除外怪兽
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择符合条件的除外怪兽
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置加入手牌的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行加入手牌效果的处理函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 确认对方看到该卡
		Duel.ConfirmCards(1-tp,tc)
	end
end
