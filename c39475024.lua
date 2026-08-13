--骸の魔妖－餓者髑髏
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：「骸之魔妖-饿者髑髅」在自己场上只能有1只表侧表示存在。
-- ②：这张卡在墓地存在，自己的连接怪兽被战斗或者对方的效果破坏的场合才能发动。从自己墓地把1只其他的不死族怪兽除外，这张卡特殊召唤。
-- ③：这张卡从墓地的特殊召唤成功的场合才能发动。这个回合，表侧表示的这张卡不受其他卡的效果影响。
function c39475024.initial_effect(c)
	c:SetUniqueOnField(1,0,39475024)
	-- 为这张卡添加同调召唤手续：需要调整＋调整以外的怪兽1只以上。
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
-- 判断这张卡是否是从墓地特殊召唤成功，即在此次特殊召唤成功之前这张卡位于墓地。
function c39475024.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- 特殊召唤成功时，若这张卡仍表侧表示且与效果关联，则为其注册一个‘不受其他卡的效果影响’的免疫效果，持续到这个回合结束（并随离场等条件重置）。
function c39475024.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这个回合，表侧表示的这张卡不受其他卡的效果影响。
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
-- 免疫过滤函数：只有来自‘其他卡’（效果拥有者不是本卡）的效果才会被免疫。
function c39475024.imfilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 判断被破坏的怪兽是否为‘自己的连接怪兽被战斗或者对方的效果破坏’：被破坏前为表侧表示、控制者为己方，原本怪兽种类包含连接，且破坏原因为战斗或由对方玩家的效果破坏。
function c39475024.spfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:GetPreviousTypeOnField()&TYPE_LINK~=0
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- ②效果的触发条件：被破坏的怪兽集合中不含这张卡自身，并且其中存在至少1只满足spfilter的连接怪兽。
function c39475024.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c39475024.spfilter,1,nil,tp)
end
-- 选择除外对象时的过滤条件：该卡可以除外，且种族为不死族。
function c39475024.rmfilter(c)
	return c:IsAbleToRemove() and c:IsRace(RACE_ZOMBIE)
end
-- ②效果发动时点检查：自己主要怪兽区有空位、这张卡可以被特殊召唤，并且墓地存在这张卡以外的可除外不死族怪兽。
function c39475024.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己主要怪兽区是否有空位可特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查墓地是否存在这张卡以外的、满足除外条件的不死族怪兽。
		and Duel.IsExistingMatchingCard(c39475024.rmfilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 设置操作信息：本次效果处理将特殊召唤这张卡（数量1）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置操作信息：本次效果处理将对自己墓地除外1张卡，具体卡在效果处理时选择。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果的操作：提示选择除外卡，从自己墓地选择1张满足条件且不受王家长眠之谷影响的不死族卡，除外成功后若这张卡仍与效果关联，则将其特殊召唤到自己场上。
function c39475024.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1张满足可除外且为不死族的卡（排除这张卡自身，并考虑王家长眠之谷的适用）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c39475024.rmfilter),tp,LOCATION_GRAVE,0,1,1,c)
	-- 确认成功除外了1张卡且这张卡仍与效果关联，才执行特殊召唤。
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
