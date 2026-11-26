--トライアングル・エリア
-- 效果：
-- 把场上存在的1只有A指示物放置的怪兽破坏。并且可以再从自己卡组把1只名字带有「外星」的4星怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段时破坏。
function c53291093.initial_effect(c)
	-- 把场上存在的1只有A指示物放置的怪兽破坏。并且可以再从自己卡组把1只名字带有「外星」的4星怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c53291093.target)
	e1:SetOperation(c53291093.activate)
	c:RegisterEffect(e1)
end
c53291093.mentioned_counter={
	[0x100e]=true,
}
-- 过滤函数：筛选放置有至少1个A指示物(0x100e)的怪兽
function c53291093.filter(c)
	return c:GetCounter(0x100e)>0
end
-- 效果Target函数：取双方场上1只放置有A指示物的怪兽为破坏对象，并设置破坏操作信息
function c53291093.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c53291093.filter(chkc) end
	-- 发动检测时确认双方怪兽区存在至少1只放置有A指示物的怪兽
	if chk==0 then return Duel.IsExistingTarget(c53291093.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向己方玩家发送选择要破坏的怪兽提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方怪兽区选择1只放置有A指示物的怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,c53291093.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置将所选对象怪兽破坏的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 过滤函数：筛选卡组中「外星」(0xc)字段、4星且可被特殊召唤的怪兽
function c53291093.spfilter(c,e,tp)
	return c:IsSetCard(0xc) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理函数：破坏对象怪兽后，若有怪兽区空位可询问玩家从卡组特召1只4星「外星」怪兽，并为其注册结束阶段破坏的自毁效果
function c53291093.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时指定为对象的场上怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否表侧在场、仍与效果关联并尝试将其破坏
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0
		-- 检查破坏后己方主要怪兽区是否至少有1个可用空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 收集己方卡组中所有可特殊召唤的4星「外星」怪兽
		local g=Duel.GetMatchingGroup(c53291093.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 若卡组存在可特召的4星「外星」怪兽，询问己方玩家是否要进行特殊召唤
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(53291093,0)) then  --"是否要特殊召唤？"
			-- 向己方玩家发送选择要特殊召唤的4星「外星」怪兽提示
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 中断当前处理步骤，使后续卡组特召与前面的破坏处理视为不同时处理
			Duel.BreakEffect()
			-- 将选中的4星「外星」怪兽以表侧表示特殊召唤到己方场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			local sc=sg:GetFirst()
			local fid=e:GetHandler():GetFieldID()
			sc:RegisterFlagEffect(53291093,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			-- 这个效果特殊召唤的怪兽在结束阶段时破坏。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetLabel(fid)
			e1:SetLabelObject(sc)
			e1:SetCondition(c53291093.descon)
			e1:SetOperation(c53291093.desop)
			-- 为己方玩家注册在结束阶段破坏该特殊召唤怪兽的持续触发效果
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 自毁效果的Condition函数：检查特召出的怪兽是否仍带有匹配的标记fid，否则重置并销毁该效果
function c53291093.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(53291093)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 自毁效果的Operation函数：在结束阶段将之前特殊召唤的4星「外星」怪兽破坏
function c53291093.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果破坏保存在LabelObject中的那只特殊召唤怪兽
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
