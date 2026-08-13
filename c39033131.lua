--もののけの巣くう祠
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上没有怪兽存在的场合，以自己墓地1只不死族怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：自己场上没有怪兽存在的场合，把墓地的这张卡除外，以自己墓地1只不死族怪兽为对象才能发动。那只怪兽效果无效特殊召唤。
function c39033131.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：自己场上没有怪兽存在的场合，以自己墓地1只不死族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,39033131)
	e1:SetCondition(c39033131.condition)
	e1:SetTarget(c39033131.target)
	e1:SetOperation(c39033131.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：自己场上没有怪兽存在的场合，把墓地的这张卡除外，以自己墓地1只不死族怪兽为对象才能发动。那只怪兽效果无效特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39033131,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,39033131)
	e2:SetCondition(c39033131.condition)
	-- 设置②效果的发动代价：把墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c39033131.target)
	e2:SetOperation(c39033131.spop)
	c:RegisterEffect(e2)
end
-- 定义①和②共用的发动条件：自己场上没有怪兽存在的场合才能发动。
function c39033131.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上怪兽区域是否存在怪兽：若怪兽数量为0则满足“自己场上没有怪兽存在”的条件。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 定义可供选择的对象筛选条件：该卡为不死族怪兽，且能被当前效果特殊召唤（不无视召唤条件和苏生限制）。
function c39033131.filter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标检查：若指定对象则确认其位于自己墓地且为不死族且可特殊召唤；若在发动时点，则确认自己场上有空余怪兽区域并且墓地存在至少1只满足条件的怪兽。
function c39033131.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39033131.filter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域，以保证能够特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认墓地存在至少1只符合条件的对象怪兽。
		and Duel.IsExistingTarget(c39033131.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出选择提示，要求玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足条件的不死族怪兽，并将其登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c39033131.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记操作信息：本效果将进行特殊召唤，目标为所选择的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①处理：将效果对象（墓地的1只不死族怪兽）以表侧表示特殊召唤到自己场上。
function c39033131.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到tp的场上（不改变控制权）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②处理：将对象怪兽特殊召唤，并在特殊召唤成功时使该怪兽效果无效化，最后完成特殊召唤结算。
function c39033131.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象怪兽（墓地的不死族怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 检查对象仍与效果关联且特殊召唤步骤成功，若成功则继续给该怪兽附加效果无效状态。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 那只怪兽效果无效特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
	end
	-- 结束特殊召唤的连锁处理，完成所有SpecialSummonStep的怪兽特殊召唤。
	Duel.SpecialSummonComplete()
end
