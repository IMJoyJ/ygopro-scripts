--翼の魔妖－天狗
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：「翼之魔妖-天狗」在自己场上只能有1只表侧表示存在。
-- ②：这张卡在墓地存在，原本等级是9星的自己的同调怪兽被战斗或者对方的效果破坏的场合才能发动。从自己墓地把1只其他的不死族怪兽除外，这张卡特殊召唤。
-- ③：这张卡从墓地的特殊召唤成功的场合才能发动。选对方场上1张魔法·陷阱卡破坏。
function c4103668.initial_effect(c)
	c:SetUniqueOnField(1,0,4103668)
	-- 为「翼之魔妖-天狗」添加同调召唤手续：调整 + 调整以外的怪兽1只以上（素材数量为1）。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ③：这张卡从墓地的特殊召唤成功的场合才能发动。选对方场上1张魔法·陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4103668,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,4103668)
	e1:SetCondition(c4103668.condition)
	e1:SetTarget(c4103668.target)
	e1:SetOperation(c4103668.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，原本等级是9星的自己的同调怪兽被战斗或者对方的效果破坏的场合才能发动。从自己墓地把1只其他的不死族怪兽除外，这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4103668,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,4103669)
	e2:SetCondition(c4103668.spcon)
	e2:SetTarget(c4103668.sptg)
	e2:SetOperation(c4103668.spop)
	c:RegisterEffect(e2)
end
-- ③效果的发动条件：这张卡特殊召唤成功时，其之前所在的位置为墓地（即从墓地特殊召唤成功）。
function c4103668.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- ③效果的发动时点判定：取得对方场上全部魔法·陷阱卡，若存在任意1张则效果可以发动，并设置破坏1张魔法·陷阱卡的操作信息。
function c4103668.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检索对方场上的所有魔法·陷阱卡（用于判断是否存在可破坏的对象）。
	local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	if chk==0 then return #g>0 end
	-- 设置本次效果的处理信息：将破坏1张魔法·陷阱卡，对象候选为对方场上所有魔法·陷阱卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ③效果处理：从对方场上选择1张魔法·陷阱卡并破坏。
function c4103668.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示当前玩家选择要破坏的卡（弹出“请选择要破坏的卡”的选择消息）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 由当前玩家从对方场上选择1张魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,0,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
	if g:GetCount()>0 then
		-- 为被选择的卡显示“成为对象”的动画效果，并记录该卡被选择为对象。
		Duel.HintSelection(g)
		-- 以效果原因将所选的那张魔法·陷阱卡破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- ②效果的触发对象判定：被破坏的怪兽必须是表侧表示、原本控制者为发动玩家、曾是同调怪兽、原本等级为9，并且破坏原因是战斗或对方发动的效果。
function c4103668.spfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:GetPreviousTypeOnField()&TYPE_SYNCHRO~=0
		and c:GetOriginalLevel()==9 and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- ②效果的发动条件：被破坏的怪兽集合中不包含这张卡自身，且其中存在满足上述spfilter条件的怪兽。
function c4103668.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c4103668.spfilter,1,nil,tp)
end
-- 除外用怪兽的过滤条件：可以被除外，且种族为不死族（用于从自己墓地除外1只其他不死族怪兽）。
function c4103668.rmfilter(c)
	return c:IsAbleToRemove() and c:IsRace(RACE_ZOMBIE)
end
-- ②效果的发动条件：我方主要怪兽区有空位、这张卡能够被特殊召唤、且墓地存在1只其他不死族怪兽可以除外；满足则返回true。
function c4103668.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查我方主要怪兽区是否有可用的空格（用于特殊召唤这张卡）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 并且墓地存在1只除这张卡以外的不死族怪兽满足可除外的条件。
		and Duel.IsExistingMatchingCard(c4103668.rmfilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 设置操作信息：本次效果将特殊召唤这张卡（1张）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置操作信息：本次效果将从我方墓地除外1张卡（具体对象在效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果处理：从自己墓地选择1只其他不死族怪兽除外；若除外成功且这张卡仍与效果关联，则将其特殊召唤。
function c4103668.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示当前玩家选择要除外的卡（弹出“请选择要除外的卡”的选择消息）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 由当前玩家从自己墓地选择1只除这张卡以外的不死族怪兽（额外检查王家长眠之谷的影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c4103668.rmfilter),tp,LOCATION_GRAVE,0,1,1,c)
	-- 如果成功选择并除外了那只不死族怪兽，且这张卡仍与所发动的效果保持关联，则继续执行特殊召唤。
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到当前玩家场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
