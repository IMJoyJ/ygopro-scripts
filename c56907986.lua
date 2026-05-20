--Kozmo－フォルミート
-- 效果：
-- 「星际仙踪-稻草人」的①的效果1回合只能使用1次。
-- ①：把场上的这张卡除外才能发动。从手卡把1只3星以上的「星际仙踪」怪兽特殊召唤。这个效果在对方回合也能发动。
-- ②：1回合1次，支付500基本分，以除外的1只自己的「星际仙踪」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段破坏。
function c56907986.initial_effect(c)
	-- 「星际仙踪-稻草人」的①的效果1回合只能使用1次。①：把场上的这张卡除外才能发动。从手卡把1只3星以上的「星际仙踪」怪兽特殊召唤。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56907986,0))  --"从手卡把「星际仙踪」怪兽特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,56907986)
	e1:SetCost(c56907986.spcost1)
	e1:SetTarget(c56907986.sptg1)
	e1:SetOperation(c56907986.spop1)
	c:RegisterEffect(e1)
	-- ②：1回合1次，支付500基本分，以除外的1只自己的「星际仙踪」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56907986,1))  --"把除外的「星际仙踪」怪兽特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c56907986.spcost2)
	e2:SetTarget(c56907986.sptg2)
	e2:SetOperation(c56907986.spop2)
	c:RegisterEffect(e2)
end
-- 效果①的Cost（发动代价）函数：检查自身是否能除外，并将自身除外。
function c56907986.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将自身表侧表示除外作为发动的代价。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 过滤条件：手卡中3星以上的「星际仙踪」怪兽。
function c56907986.spfilter1(c,e,tp)
	return c:IsSetCard(0xd2) and c:IsLevelAbove(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的Target（发动准备）函数：检查怪兽区域空位以及手卡中是否存在符合条件的怪兽，并设置特殊召唤的操作信息。
function c56907986.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有空位（因为自身作为代价除外会空出一个格子，所以可用空格数大于-1即可）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡中是否存在至少1只满足过滤条件的怪兽。
		and Duel.IsExistingMatchingCard(c56907986.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息为：从手卡特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的Operation（效果处理）函数：从手卡选择1只符合条件的「星际仙踪」怪兽特殊召唤。
function c56907986.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有可用空位，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息，提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡选择1只满足过滤条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c56907986.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的Cost（发动代价）函数：检查并支付500基本分。
function c56907986.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付500基本分。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 扣除玩家500基本分作为发动代价。
	Duel.PayLPCost(tp,500)
end
-- 过滤条件：除外区表侧表示的「星际仙踪」怪兽。
function c56907986.spfilter2(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0xd2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的Target（发动准备）函数：检查怪兽区域空位，选择除外区1只符合条件的「星际仙踪」怪兽作为对象，并设置特殊召唤的操作信息。
function c56907986.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c56907986.spfilter2(chkc,e,tp) end
	-- 检查怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查除外区是否存在至少1只可以作为效果对象的符合条件的怪兽。
		and Duel.IsExistingTarget(c56907986.spfilter2,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 给玩家发送提示信息，提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择除外区1只符合条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c56907986.spfilter2,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置连锁处理中的操作信息为：特殊召唤选中的对象怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的Operation（效果处理）函数：将选中的对象怪兽特殊召唤，并使其效果无效化，注册结束阶段破坏的效果。
function c56907986.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与效果相关，并尝试将其以表侧表示特殊召唤（分步处理）。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		-- 结束阶段破坏。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCountLimit(1)
		e3:SetCondition(c56907986.descon)
		e3:SetOperation(c56907986.desop)
		e3:SetLabelObject(tc)
		-- 将结束阶段破坏的效果作为玩家效果注册到全局环境中。
		Duel.RegisterEffect(e3,tp)
		tc:RegisterFlagEffect(56907986,RESET_EVENT+RESETS_STANDARD,0,1)
	end
	-- 完成特殊召唤的后续处理（刷新场上状态等）。
	Duel.SpecialSummonComplete()
end
-- 结束阶段破坏效果的Condition（发动条件）函数：检查目标怪兽是否仍带有标记，若无则重置该效果。
function c56907986.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(56907986)==0 then
		e:Reset()
		return false
	end
	return true
end
-- 结束阶段破坏效果的Operation（效果处理）函数：破坏目标怪兽。
function c56907986.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 因效果破坏目标怪兽。
	Duel.Destroy(tc,REASON_EFFECT)
end
