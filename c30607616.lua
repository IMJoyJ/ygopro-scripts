--轍の魔妖－朧車
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：「辙之魔妖-胧车」在自己场上只能有1只表侧表示存在。
-- ②：这张卡在墓地存在，原本等级是5星的自己的同调怪兽被战斗或者对方的效果破坏的场合才能发动。从自己墓地把1只其他的不死族怪兽除外，这张卡特殊召唤。
-- ③：这张卡从墓地的特殊召唤成功的场合才能发动。这个回合，自己怪兽不会被战斗破坏。
function c30607616.initial_effect(c)
	c:SetUniqueOnField(1,0,30607616)
	-- 为卡片添加同调召唤手续，要求1只调整和1只调整以外的怪兽参与同调召唤
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
-- 判断该卡是否从墓地被特殊召唤成功
function c30607616.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- 使自己场上所有怪兽在该回合内不会被战斗破坏
function c30607616.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 创建一个效果，使自己场上所有怪兽在该回合内不会被战斗破坏
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetValue(1)
	-- 将效果注册到玩家的全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 过滤满足条件的被破坏的同调怪兽：必须是5星等级、同调类型、被战斗或对方效果破坏
function c30607616.spfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:GetPreviousTypeOnField()&TYPE_SYNCHRO~=0
		and c:GetOriginalLevel()==5 and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 判断是否有满足条件的被破坏的同调怪兽
function c30607616.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c30607616.spfilter,1,nil,tp)
end
-- 过滤满足条件的不死族怪兽：可以除外、种族为不死族
function c30607616.rmfilter(c)
	return c:IsAbleToRemove() and c:IsRace(RACE_ZOMBIE)
end
-- 设置特殊召唤和除外的条件：场上存在空位、该卡可以特殊召唤、墓地存在符合条件的不死族怪兽
function c30607616.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查墓地是否存在符合条件的不死族怪兽
		and Duel.IsExistingMatchingCard(c30607616.rmfilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 设置操作信息：特殊召唤该卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置操作信息：除外1只不死族怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
-- 处理特殊召唤效果：选择并除外1只不死族怪兽，然后将该卡特殊召唤
function c30607616.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的不死族怪兽进行除外
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c30607616.rmfilter),tp,LOCATION_GRAVE,0,1,1,c)
	-- 判断是否成功除外卡并确认该卡仍在场上
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		-- 将该卡以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
