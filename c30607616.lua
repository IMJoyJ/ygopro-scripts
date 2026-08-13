--轍の魔妖－朧車
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：「辙之魔妖-胧车」在自己场上只能有1只表侧表示存在。
-- ②：这张卡在墓地存在，原本等级是5星的自己的同调怪兽被战斗或者对方的效果破坏的场合才能发动。从自己墓地把1只其他的不死族怪兽除外，这张卡特殊召唤。
-- ③：这张卡从墓地的特殊召唤成功的场合才能发动。这个回合，自己怪兽不会被战斗破坏。
function c30607616.initial_effect(c)
	c:SetUniqueOnField(1,0,30607616)
	-- 为这张卡添加同调召唤手续：需要1只调整＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ③：这张卡从墓地的特殊召唤成功的场合才能发动。这个回合，自己怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30607616,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,30607616)
	e1:SetCondition(c30607616.condition)
	e1:SetOperation(c30607616.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，原本等级是5星的自己的同调怪兽被战斗或者对方的效果破坏的场合才能发动。从自己墓地把1只其他的不死族怪兽除外，这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30607616,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,30607617)
	e2:SetCondition(c30607616.spcon)
	e2:SetTarget(c30607616.sptg)
	e2:SetOperation(c30607616.spop)
	c:RegisterEffect(e2)
end
-- 发动条件：这张卡是位于墓地时被特殊召唤成功，即之前位置为墓地。
function c30607616.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- ③效果处理：给己方场上的所有怪兽附加不会被战斗破坏的效果，持续到回合结束。
function c30607616.operation(e,tp,eg,ep,ev,re,r,rp)
	-- ②：这张卡在墓地存在，原本等级是5星的自己的同调怪兽被战斗或者对方的效果破坏的场合才能发动。从自己墓地把1只其他的不死族怪兽除外，这张卡特殊召唤。③：这张卡从墓地的特殊召唤成功的场合才能发动。这个回合，自己怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetValue(1)
	-- 将‘不会被战斗破坏’效果注册到场上，影响玩家tp控制的主要怪兽区怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 判定被破坏的怪兽是否满足②发动条件：破坏前表侧表示且由自己控制、是同调怪兽、原本等级为5，并且是被战斗破坏或对方的效果破坏。
function c30607616.spfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:GetPreviousTypeOnField()&TYPE_SYNCHRO~=0
		and c:GetOriginalLevel()==5 and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- ②发动条件：被破坏的怪兽集合中不包含这张卡自身，且存在至少1只满足条件的自己的同调怪兽被战斗/对方效果破坏。
function c30607616.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c30607616.spfilter,1,nil,tp)
end
-- 除外过滤：选择墓地中1只不死族怪兽且该卡能够被除外。
function c30607616.rmfilter(c)
	return c:IsAbleToRemove() and c:IsRace(RACE_ZOMBIE)
end
-- 发动目标检测：自己主要怪兽区有空位、这张卡可以特殊召唤、且墓地存在1只除外的其他不死族怪兽（这张卡自身除外）。
function c30607616.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上主要怪兽区是否有可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查墓地是否存在1张符合除外条件的不死族怪兽（除这张卡自身外）。
		and Duel.IsExistingMatchingCard(c30607616.rmfilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 设置操作信息：将要特殊召唤的对象为这张卡，数量1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置操作信息：将从墓地除外1张卡（具体卡在处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果处理：从自己墓地选择1只其他不死族怪兽除外，成功后特殊召唤这张卡。
function c30607616.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 给玩家显示‘请选择要除外的卡’的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1只满足条件的不死族怪兽（不受王家长眠之谷影响），且不能选择这张卡自身。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c30607616.rmfilter),tp,LOCATION_GRAVE,0,1,1,c)
	-- 如果成功选择了卡并除外成功，且这张卡仍与效果关联，则继续处理。
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
