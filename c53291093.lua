--トライアングル・エリア
-- 效果：
-- 把场上存在的1只有A指示物放置的怪兽破坏。并且可以再从自己卡组把1只名字带有「外星」的4星怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段时破坏。
function c53291093.initial_effect(c)
	-- 把场上存在的1只有A指示物放置的怪兽破坏。并且可以再从自己卡组把1只名字带有「外星」的4星怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段时破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
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
-- 过滤器：判断该卡放置的A指示物数量是否大于0
function c53291093.filter(c)
	return c:GetCounter(0x100e)>0
end
-- 对象选取：确认场上存在可成为效果对象且有A指示物放置的怪兽后，让玩家选择其中1只作为破坏对象，并设置破坏操作信息
function c53291093.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c53291093.filter(chkc) end
	-- 发动条件检查：双方主要怪兽区存在至少1只可以取为对象且放置有A指示物的怪兽才能发动
	if chk==0 then return Duel.IsExistingTarget(c53291093.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示「请选择要破坏的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1只放置有A指示物的怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,c53291093.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁的操作信息：确定要破坏的对象卡1张
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 特殊召唤过滤器：名字带有「外星」的4星且可以特殊召唤的怪兽
function c53291093.spfilter(c,e,tp)
	return c:IsSetCard(0xc) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：破坏对象怪兽，破坏成功且自己主要怪兽区有空位时，可询问玩家是否从卡组特殊召唤1只「外星」4星怪兽，并注册结束阶段将其破坏的延迟效果
function c53291093.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡（要破坏的怪兽）
	local tc=Duel.GetFirstTarget()
	-- 对象怪兽仍为正面表示且仍与本效果关联时，以效果原因将其破坏
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0
		-- 且自己主要怪兽区还有可用空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 从自己卡组检索满足条件的怪兽（「外星」4星且可以特殊召唤）
		local g=Duel.GetMatchingGroup(c53291093.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 若卡组存在满足条件的怪兽，则询问玩家「是否要特殊召唤？」
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(53291093,0)) then  --"是否要特殊召唤？"
			-- 向玩家提示「请选择要特殊召唤的卡」
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 中断当前效果处理，使之后的特殊召唤与破坏不同时处理
			Duel.BreakEffect()
			-- 把选择的怪兽以正面表示特殊召唤到自己场上
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
			-- 把结束阶段破坏那只特殊召唤怪兽的持续效果注册给玩家
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 破坏条件判断：若那只怪兽的标识与本效果不符（如已离场重置），则重置此效果并返回false，否则结束阶段时生效
function c53291093.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(53291093)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 破坏操作：以效果原因破坏这个效果特殊召唤的那只怪兽
function c53291093.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因破坏标签中记录的那只特殊召唤的怪兽
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
