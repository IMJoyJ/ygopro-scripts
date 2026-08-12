--TG メタル・スケルトン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：场上的怪兽被战斗或者对方的效果破坏的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己场上的「科技属」怪兽被战斗·效果破坏的场合，可以作为代替把场上·墓地的这张卡除外。
function c66733743.initial_effect(c)
	-- ①：场上的怪兽被战斗或者对方的效果破坏的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,66733743)
	e1:SetCondition(c66733743.spcon)
	e1:SetTarget(c66733743.sptg)
	e1:SetOperation(c66733743.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上的「科技属」怪兽被战斗·效果破坏的场合，可以作为代替把场上·墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE+LOCATION_MZONE)
	e2:SetCountLimit(1,66733744)
	e2:SetTarget(c66733743.reptg)
	e2:SetValue(c66733743.repval)
	e2:SetOperation(c66733743.repop)
	c:RegisterEffect(e2)
end
-- 过滤因战斗或对方卡片效果而被破坏的场上怪兽。
function c66733743.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 检查被破坏的怪兽中是否存在满足“场上的怪兽被战斗或对方效果破坏”条件的怪兽。
function c66733743.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c66733743.cfilter,1,nil,tp)
end
-- 特殊召唤效果的发动条件与效果处理目标检测。
function c66733743.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理的操作信息为将自身特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的效果处理：若这张卡仍在手卡，则将这张卡特殊召唤。
function c66733743.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤自己场上因战斗或效果而被破坏的表侧表示「科技属」怪兽。
function c66733743.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and c:IsSetCard(0x27) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的目标检查：检查是否有符合条件的「科技属」怪兽被破坏，且场上或墓地的这张卡可以被除外。
function c66733743.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(c66733743.repfilter,1,c,tp) and c:IsAbleToRemove()
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	-- 询问玩家是否发动代替破坏的效果。
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 确定代替破坏效果所适用的具体怪兽。
function c66733743.repval(e,c)
	return c66733743.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的处理：将场上或墓地的这张卡除外作为代替。
function c66733743.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将这张卡以表侧表示除外作为代替破坏的手段。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end
