--骸の魔妖－餓者髑髏
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：「骸之魔妖-饿者髑髅」在自己场上只能有1只表侧表示存在。
-- ②：这张卡在墓地存在，自己的连接怪兽被战斗或者对方的效果破坏的场合才能发动。从自己墓地把1只其他的不死族怪兽除外，这张卡特殊召唤。
-- ③：这张卡从墓地的特殊召唤成功的场合才能发动。这个回合，表侧表示的这张卡不受其他卡的效果影响。
function c39475024.initial_effect(c)
	c:SetUniqueOnField(1,0,39475024)
	-- 为卡片添加同调召唤手续，要求1只调整和1只调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ③：这张卡从墓地的特殊召唤成功的场合才能发动。这个回合，表侧表示的这张卡不受其他卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39475024,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,39475024)
	e1:SetCondition(c39475024.condition)
	e1:SetOperation(c39475024.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己的连接怪兽被战斗或者对方的效果破坏的场合才能发动。从自己墓地把1只其他的不死族怪兽除外，这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39475024,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,39475025)
	e2:SetCondition(c39475024.spcon)
	e2:SetTarget(c39475024.sptg)
	e2:SetOperation(c39475024.spop)
	c:RegisterEffect(e2)
end
-- 判断该卡是否从墓地被特殊召唤成功
function c39475024.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- 使该卡在主怪兽区获得效果免疫效果，使其在本回合内不受其他卡的效果影响
function c39475024.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 效果免疫其他卡的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(c39475024.imfilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 返回值为true表示该效果不被自身效果影响
function c39475024.imfilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 过滤出被破坏的连接怪兽，且破坏原因必须是战斗或对方效果
function c39475024.spfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:GetPreviousTypeOnField()&TYPE_LINK~=0
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 判断是否满足②效果的发动条件
function c39475024.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c39475024.spfilter,1,nil,tp)
end
-- 过滤出可除外的不死族怪兽
function c39475024.rmfilter(c)
	return c:IsAbleToRemove() and c:IsRace(RACE_ZOMBIE)
end
-- 设置效果发动时的处理信息，包括特殊召唤和除外操作
function c39475024.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有足够的场上空位进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查墓地中是否存在满足条件的不死族怪兽用于除外
		and Duel.IsExistingMatchingCard(c39475024.rmfilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置除外的处理信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
-- 执行②效果的处理流程，选择除外不死族怪兽并特殊召唤自身
function c39475024.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从墓地中选择1只符合条件的不死族怪兽进行除外
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c39475024.rmfilter),tp,LOCATION_GRAVE,0,1,1,c)
	-- 判断是否成功除外怪兽并确认自身是否还在场上
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		-- 将自身从墓地特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
