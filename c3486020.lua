--麗の魔妖－妖狐
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：「丽之魔妖-妖狐」在自己场上只能有1只表侧表示存在。
-- ②：这张卡在墓地存在，原本等级是11星的自己的同调怪兽被战斗或者对方的效果破坏的场合才能发动。从自己墓地把1只其他的不死族怪兽除外，这张卡特殊召唤。
-- ③：这张卡从墓地的特殊召唤成功的场合才能发动。选对方场上1只怪兽破坏。
function c3486020.initial_effect(c)
	c:SetUniqueOnField(1,0,3486020)
	-- 为这张卡添加同调召唤手续：调整＋调整以外的怪兽1只以上（任意调整，调整以外的怪兽至少1只）。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ③：这张卡从墓地的特殊召唤成功的场合才能发动。选对方场上1只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3486020,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,3486020)
	e1:SetCondition(c3486020.condition)
	e1:SetTarget(c3486020.target)
	e1:SetOperation(c3486020.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，原本等级是11星的自己的同调怪兽被战斗或者对方的效果破坏的场合才能发动。从自己墓地把1只其他的不死族怪兽除外，这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3486020,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,3486021)
	e2:SetCondition(c3486020.spcon)
	e2:SetTarget(c3486020.sptg)
	e2:SetOperation(c3486020.spop)
	c:RegisterEffect(e2)
end
-- 效果③的发动条件：判定这张卡在被特殊召唤成功之前所在位置为墓地，即只有从墓地特殊召唤成功时才能发动。
function c3486020.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- 效果③的发动目标判定：获取对方场上的全部怪兽作为破坏候选，若存在至少1只则允许发动，并设置操作信息为破坏对方场上1只怪兽。
function c3486020.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的所有怪兽（用于后续选择破坏对象）。
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	-- 设置操作信息：本次效果处理将破坏1只对方场上的怪兽，候选集合为g，用于连锁判定等系统检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果③的实际处理：由玩家选择对方场上1只怪兽，展示选择后将其破坏。
function c3486020.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 发出选择卡片提示，提示文字为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家tp从对方场上选择1只怪兽（效果处理时选择，因此为不取对象破坏）。
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		-- 为选择的卡片播放选中动画，并将其记为效果处理所涉及的卡。
		Duel.HintSelection(g)
		-- 将选择的对方怪兽以“效果”原因破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 效果②所需被破坏怪兽的过滤条件：该怪兽在场上表侧表示时被破坏，原控制者为tp，原本种类包含同调，原本等级为11，且破坏原因为战斗破坏或对方玩家的效果破坏。
function c3486020.spfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:GetPreviousTypeOnField()&TYPE_SYNCHRO~=0
		and c:GetOriginalLevel()==11 and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 效果②的触发条件：被破坏的怪兽集合中不包含这张卡自身（这张卡在墓地），且存在至少1只满足spfilter条件的自己11星同调怪兽。
function c3486020.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c3486020.spfilter,1,nil,tp)
end
-- 效果②除外对象的过滤条件：该卡为不死族怪兽，且可以被除外。
function c3486020.rmfilter(c)
	return c:IsAbleToRemove() and c:IsRace(RACE_ZOMBIE)
end
-- 效果②的发动目标判定：自己怪兽区有空位、这张卡可以特殊召唤、且墓地存在1张其他不死族可除外怪兽。
function c3486020.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查墓地是否存在满足filter的除外对象（排除这张卡自身）。
		and Duel.IsExistingMatchingCard(c3486020.rmfilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 设置操作信息：将这张卡特殊召唤，对象为c。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置操作信息：将从墓地除外1张卡，具体除外对象在效果处理时决定（targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
-- 效果②的实际处理：选择并除外自己墓地1只不死族怪兽，若除外成功且这张卡仍与效果关联，则把这张卡特殊召唤。
function c3486020.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 发出选择卡片提示，提示文字为“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家tp从自己墓地选择1张不受王家长眠之谷影响且满足rmfilter的不死族怪兽（排除这张卡自身）作为除外对象。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c3486020.rmfilter),tp,LOCATION_GRAVE,0,1,1,c)
	-- 判断是否实际除外了卡，且这张卡仍与当前效果有联系，若满足则继续特殊召唤。
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		-- 将这张卡以表侧攻击表示特殊召唤到tp场上（正常检查召唤条件和苏生限制）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
