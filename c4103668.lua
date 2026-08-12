--翼の魔妖－天狗
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：「翼之魔妖-天狗」在自己场上只能有1只表侧表示存在。
-- ②：这张卡在墓地存在，原本等级是9星的自己的同调怪兽被战斗或者对方的效果破坏的场合才能发动。从自己墓地把1只其他的不死族怪兽除外，这张卡特殊召唤。
-- ③：这张卡从墓地的特殊召唤成功的场合才能发动。选对方场上1张魔法·陷阱卡破坏。
function c4103668.initial_effect(c)
	c:SetUniqueOnField(1,0,4103668)
	-- 为卡片添加同调召唤手续，要求1只调整，1只调整以外的怪兽
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
-- 判断此卡是否从墓地特殊召唤成功
function c4103668.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- 检索满足条件的魔法·陷阱卡组，用于破坏效果
function c4103668.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上所有魔法·陷阱卡
	local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	if chk==0 then return #g>0 end
	-- 设置连锁操作信息，指定要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 选择并破坏对方场上的魔法·陷阱卡
function c4103668.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,0,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
	if g:GetCount()>0 then
		-- 显示被选为对象的卡
		Duel.HintSelection(g)
		-- 将选中的卡破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 过滤满足条件的被破坏的同调怪兽：原等级为9星，且被战斗或对方效果破坏
function c4103668.spfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:GetPreviousTypeOnField()&TYPE_SYNCHRO~=0
		and c:GetOriginalLevel()==9 and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 判断是否有满足条件的被破坏的同调怪兽
function c4103668.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c4103668.spfilter,1,nil,tp)
end
-- 过滤满足条件的不死族怪兽：可除外且种族为不死族
function c4103668.rmfilter(c)
	return c:IsAbleToRemove() and c:IsRace(RACE_ZOMBIE)
end
-- 设置特殊召唤的条件：有空场且此卡可特殊召唤，且墓地有不死族怪兽
function c4103668.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有足够的场空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查墓地是否有满足条件的不死族怪兽
		and Duel.IsExistingMatchingCard(c4103668.rmfilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 设置连锁操作信息，指定要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置连锁操作信息，指定要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
-- 选择并除外墓地的不死族怪兽，然后特殊召唤此卡
function c4103668.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的不死族怪兽除外
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c4103668.rmfilter),tp,LOCATION_GRAVE,0,1,1,c)
	-- 判断是否满足特殊召唤条件：除外成功且此卡仍在场上
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		-- 将此卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
