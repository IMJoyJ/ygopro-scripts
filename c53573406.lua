--カメンレオン
-- 效果：
-- 这张卡在自己场上没有5星以上的怪兽存在的场合才能召唤。这张卡的效果发动的回合，自己不用从额外卡组的特殊召唤以及这张卡的效果不能特殊召唤。
-- ①：这张卡召唤成功时，以自己墓地1只守备力0的怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c53573406.initial_effect(c)
	-- 这张卡在自己场上没有5星以上的怪兽存在的场合才能召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c53573406.sumcon)
	c:RegisterEffect(e1)
	-- 这张卡的效果发动的回合，自己不用从额外卡组的特殊召唤以及这张卡的效果不能特殊召唤。①：这张卡召唤成功时，以自己墓地1只守备力0的怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53573406,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCost(c53573406.spcost)
	e2:SetTarget(c53573406.sptg)
	e2:SetOperation(c53573406.spop)
	c:RegisterEffect(e2)
	-- 注册一个特殊召唤行为计数器，用于记录本回合自己进行过的“不是从额外卡组来的特殊召唤”次数（供发动条件与自肃判定使用）。
	Duel.AddCustomActivityCounter(53573406,ACTIVITY_SPSUMMON,c53573406.counterfilter)
end
-- 计数器过滤函数：仅当被特殊召唤的怪兽来自额外卡组时返回true；否则返回false，使该次特殊召唤被计入非额外卡组特殊召唤计数。
function c53573406.counterfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 过滤条件：怪兽为表侧表示且等级在5星以上，用于判断自己场上是否存在5星以上怪兽。
function c53573406.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(5)
end
-- 召唤限制条件：如果自己场上存在表侧表示且5星以上的怪兽，则该卡不能召唤（effect为该限制效果）。
function c53573406.sumcon(e)
	-- 具体检查：以效果持有者玩家视角，检查其场上（LOCATION_MZONE）是否存在至少1张满足cfilter的卡。
	return Duel.IsExistingMatchingCard(c53573406.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 发动代价/发动时处理：先检查本回合未进行过非额外卡组特殊召唤；然后记录本次效果的编号，在自己场上生成一个直到结束阶段有效的誓约效果，禁止非本卡效果的非额外卡组特殊召唤。
function c53573406.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：chk==0时，确认自定义计数器显示本回合自己进行过的非额外卡组特殊召唤次数为0，即没有进行过非额外特殊召唤。
	if chk==0 then return Duel.GetCustomActivityCount(53573406,tp,ACTIVITY_SPSUMMON)==0 end
	local fid=e:GetHandler():GetFieldID()
	e:SetLabel(fid)
	-- 这张卡的效果发动的回合，自己不用从额外卡组的特殊召唤以及这张卡的效果不能特殊召唤。①：这张卡召唤成功时，以自己墓地1只守备力0的怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabel(fid)
	e1:SetTarget(c53573406.sumlimit)
	-- 将新创建的誓约效果e1注册到当前玩家tp，使该限制效果开始适用。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃过滤函数：如果某个特殊召唤不是由本卡效果（se的label与e的label不同）发起的，并且被特殊召唤的怪兽不是从额外卡组来的，则禁止该特殊召唤。
function c53573406.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return e:GetLabel()~=se:GetLabel() and not c:IsLocation(LOCATION_EXTRA)
end
-- 选择对象的过滤条件：目标是守备力为0，且能够由玩家tp以表侧守备表示特殊召唤的怪兽。
function c53573406.filter(c,e,tp)
	return c:IsDefense(0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果目标设定阶段：验证被指定对象是否合法；并在发动时检查自己有怪兽区空位且墓地存在满足条件的守备力0怪兽。
function c53573406.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c53573406.filter(chkc,e,tp) end
	-- 发动检查（chk==0）的一部分：自己的主要怪兽区域必须有至少1个空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动检查（chk==0）的另一部分：自己墓地存在至少1张满足filter条件且可以成为效果对象的怪兽。
		and Duel.IsExistingTarget(c53573406.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家显示“请选择要特殊召唤的卡”的提示消息，用于后续选择卡的UI。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地的符合filter的怪兽中选择1只作为效果对象，并将其记录为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c53573406.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果将特殊召唤1只怪兽（已确定对象g），供其他卡连锁或时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：若主怪兽区有空位，取回对象怪兽；若对象仍与效果关联，则将其以表侧守备表示特殊召唤，并附加效果无效化与效果无效处理；最后完成特殊召唤。
function c53573406.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时的再检查：自己的主要怪兽区已无空位，则特殊召唤处理中止（效果不处理）。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取发动时选择的对象卡（墓地那只守备力0的怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍然与效果关联（未离场/未被重置），并执行特殊召唤步骤，将其以表侧守备表示特殊召唤到自己的主要怪兽区。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 结束连续特殊召唤过程，完成整个特殊召唤并触发相关时点（如召唤成功时）。
	Duel.SpecialSummonComplete()
end
