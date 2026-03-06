--華信龍－ノウルーズ・エリーズ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在墓地存在的场合，从手卡把1只5星以上的怪兽送去墓地才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：这张卡被战斗或者对方的效果破坏的场合，以对方场上1张卡为对象才能发动。那张卡除外。
function c25607552.initial_effect(c)
	-- ①：这张卡在墓地存在的场合，从手卡把1只5星以上的怪兽送去墓地才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,25607552)
	e1:SetCost(c25607552.spcost)
	e1:SetTarget(c25607552.sptg)
	e1:SetOperation(c25607552.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗或者对方的效果破坏的场合，以对方场上1张卡为对象才能发动。那张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,25607553)
	e2:SetCondition(c25607552.rmcon)
	e2:SetTarget(c25607552.rmtg)
	e2:SetOperation(c25607552.rmop)
	c:RegisterEffect(e2)
end
-- 过滤函数，检查手卡中是否存在1只5星以上且为怪兽卡并能作为墓地代价的卡片。
function c25607552.cfilter(c)
	return c:IsLevelAbove(5) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 检查手卡中是否存在满足条件的卡片，若存在则丢弃1张满足条件的卡片作为代价。
function c25607552.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1张满足条件的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(c25607552.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手卡丢弃1张满足条件的卡片作为代价。
	Duel.DiscardHand(tp,c25607552.cfilter,1,1,REASON_COST)
end
-- 检查是否满足特殊召唤的条件，包括场上是否有空位以及此卡是否能被特殊召唤。
function c25607552.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位可用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示此效果将特殊召唤此卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，若成功则设置效果使此卡离场时被除外。
function c25607552.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否与当前效果相关联且特殊召唤成功。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 创建一个永续效果，使此卡离场时被除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- 判断此卡被破坏的原因是否为战斗或对方的效果。
function c25607552.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE)
		or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp))
end
-- 设置除外效果的目标选择函数，选择对方场上的1张可除外的卡。
function c25607552.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查对方场上是否存在至少1张可除外的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上的1张可除外的卡作为目标。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，表示此效果将除外目标卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 执行除外操作，将目标卡除外。
function c25607552.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以正面表示的方式除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
