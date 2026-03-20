--カメンレオン
-- 效果：
-- 这张卡在自己场上没有5星以上的怪兽存在的场合才能召唤。这张卡的效果发动的回合，自己不用从额外卡组的特殊召唤以及这张卡的效果不能特殊召唤。
-- ①：这张卡召唤成功时，以自己墓地1只守备力0的怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c53573406.initial_effect(c)
	-- 效果原文：这张卡在自己场上没有5星以上的怪兽存在的场合才能召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c53573406.sumcon)
	c:RegisterEffect(e1)
	-- 效果原文：①：这张卡召唤成功时，以自己墓地1只守备力0的怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
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
	-- 设置一个计数器，用于记录玩家在该回合中从额外卡组特殊召唤的次数。
	Duel.AddCustomActivityCounter(53573406,ACTIVITY_SPSUMMON,c53573406.counterfilter)
end
-- 过滤函数，判断卡片是否从额外卡组召唤。
function c53573406.counterfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 过滤函数，判断场上是否存在5星或以上的怪兽。
function c53573406.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(5)
end
-- 条件函数，判断是否满足召唤条件（场上没有5星以上的怪兽）。
function c53573406.sumcon(e)
	-- 判断场上是否存在5星或以上的怪兽。
	return Duel.IsExistingMatchingCard(c53573406.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 设置效果成本，确保该回合内不能特殊召唤。
function c53573406.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查该玩家在本回合是否已经进行过特殊召唤。
	if chk==0 then return Duel.GetCustomActivityCount(53573406,tp,ACTIVITY_SPSUMMON)==0 end
	local fid=e:GetHandler():GetFieldID()
	e:SetLabel(fid)
	-- 创建一个影响全场玩家的永续效果，禁止特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabel(fid)
	e1:SetTarget(c53573406.sumlimit)
	-- 将效果注册给指定玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的条件，排除来自额外卡组的召唤。
function c53573406.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return e:GetLabel()~=se:GetLabel() and not c:IsLocation(LOCATION_EXTRA)
end
-- 过滤函数，判断墓地中的怪兽是否守备力为0且可以特殊召唤。
function c53573406.filter(c,e,tp)
	return c:IsDefense(0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置选择目标的条件，检查是否有满足条件的墓地怪兽。
function c53573406.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c53573406.filter(chkc,e,tp) end
	-- 检查玩家场上是否有足够的空间进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在满足条件的墓地怪兽。
		and Duel.IsExistingTarget(c53573406.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽。
	local g=Duel.SelectTarget(tp,c53573406.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，告知连锁处理中将要特殊召唤的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作，并对召唤出的怪兽施加效果无效化。
function c53573406.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的空间进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取当前连锁中选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且可以进行特殊召唤。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 使特殊召唤出的怪兽效果无效。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使特殊召唤出的怪兽效果在回合结束时无效。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤流程。
	Duel.SpecialSummonComplete()
end
