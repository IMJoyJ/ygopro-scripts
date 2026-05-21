--バージェストマ・カナディア
-- 效果：
-- ①：以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
-- ②：这张卡在墓地存在，陷阱卡发动时才能发动（同一连锁上最多1次）。这张卡变成通常怪兽（水族·水·2星·攻1200/守0）在怪兽区域特殊召唤（不当作陷阱卡使用）。这个效果特殊召唤的这张卡不受怪兽的效果影响，从场上离开的场合除外。
function c98414735.initial_effect(c)
	-- ①：以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(TIMING_BATTLE_PHASE,TIMINGS_CHECK_MONSTER+TIMING_BATTLE_PHASE)
	e1:SetTarget(c98414735.target)
	e1:SetOperation(c98414735.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，陷阱卡发动时才能发动（同一连锁上最多1次）。这张卡变成通常怪兽（水族·水·2星·攻1200/守0）在怪兽区域特殊召唤（不当作陷阱卡使用）。这个效果特殊召唤的这张卡不受怪兽的效果影响，从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(c98414735.spcon)
	e2:SetTarget(c98414735.sptg)
	e2:SetOperation(c98414735.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示且可以变成里侧表示的怪兽
function c98414735.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- ①效果的靶向处理（检查是否可以发动、选择对象并设置操作信息）
function c98414735.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c98414735.filter(chkc) end
	-- 发动条件检查：对方场上是否存在至少1只满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c98414735.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择对方场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c98414735.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：包含改变表示形式的操作，数量为1
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ①效果的执行处理（将对象怪兽变成里侧守备表示）
function c98414735.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将目标怪兽改变为里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
-- ②效果的发动条件：陷阱卡发动时
function c98414735.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- ②效果的靶向处理（检查怪兽区域空位及是否能特招）
function c98414735.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件检查：自身怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：玩家是否能将此卡作为特定属性、种族、攻守的通常怪兽特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,98414735,0xd4,TYPES_NORMAL_TRAP_MONSTER,1200,0,2,RACE_AQUA,ATTRIBUTE_WATER) end
	-- 设置操作信息：包含特殊召唤的操作，数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②效果的执行处理（将自身作为通常怪兽特殊召唤，并赋予不受怪兽效果影响及离场除外的效果）
function c98414735.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时检查：若怪兽区域已无空位则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 检查此卡是否仍与效果相关，且玩家是否仍能特殊召唤该陷阱怪兽
	if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,98414735,0xd4,TYPES_NORMAL_TRAP_MONSTER,1200,0,2,RACE_AQUA,ATTRIBUTE_WATER) then
		c:AddMonsterAttribute(TYPE_NORMAL)
		-- 执行特殊召唤的步骤（表侧表示特招，不检查召唤条件）
		Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP)
		-- 这个效果特殊召唤的这张卡不受怪兽的效果影响
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetValue(c98414735.efilter)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2,true)
		-- 从场上离开的场合除外。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e3:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e3,true)
		-- 完成特殊召唤的流程
		Duel.SpecialSummonComplete()
	end
end
-- 免疫效果的过滤条件：不受怪兽的效果影响
function c98414735.efilter(e,re)
	return re:IsActiveType(TYPE_MONSTER)
end
