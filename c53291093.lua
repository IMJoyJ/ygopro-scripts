--トライアングル・エリア
-- 效果：
-- 把场上存在的1只有A指示物放置的怪兽破坏。并且可以再从自己卡组把1只名字带有「外星」的4星怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段时破坏。
function c53291093.initial_effect(c)
	-- 效果定义：将此卡作为发动效果的魔法卡，可以破坏场上1只带有A指示物的怪兽，并可特殊召唤1只名字带有「外星」的4星怪兽，该特殊召唤的怪兽在结束阶段时破坏。
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
-- 过滤函数：判断目标怪兽是否带有A指示物（指示物编号为0x100e）
function c53291093.filter(c)
	return c:GetCounter(0x100e)>0
end
-- 效果处理：选择场上1只带有A指示物的怪兽作为对象
function c53291093.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c53291093.filter(chkc) end
	-- 条件判定：确认场上是否存在1只带有A指示物的怪兽
	if chk==0 then return Duel.IsExistingTarget(c53291093.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示信息：向玩家提示“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择目标：从场上选择1只带有A指示物的怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,c53291093.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：将破坏效果的操作信息登记到连锁中
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 过滤函数：判断是否为名字带有「外星」（0xc）且等级为4的怪兽，可特殊召唤
function c53291093.spfilter(c,e,tp)
	return c:IsSetCard(0xc) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 主效果处理：执行破坏并尝试特殊召唤
function c53291093.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标：获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 条件判断：确认目标怪兽正面表示且存在于场上，并成功破坏
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0
		-- 条件判断：确认玩家场上存在空位可进行特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 过滤卡组：检索自己卡组中名字带有「外星」且等级为4的怪兽
		local g=Duel.GetMatchingGroup(c53291093.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 选择是否特殊召唤：询问玩家是否要特殊召唤检索到的怪兽
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(53291093,0)) then  --"是否要特殊召唤？"
			-- 提示信息：向玩家提示“请选择要特殊召唤的卡”
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 中断效果处理：使后续效果不与当前效果同时处理
			Duel.BreakEffect()
			-- 特殊召唤：将选择的怪兽正面表示特殊召唤到场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			local sc=sg:GetFirst()
			local fid=e:GetHandler():GetFieldID()
			sc:RegisterFlagEffect(53291093,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			-- 注册结束阶段破坏效果：为特殊召唤的怪兽在结束阶段时设置破坏效果
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetLabel(fid)
			e1:SetLabelObject(sc)
			e1:SetCondition(c53291093.descon)
			e1:SetOperation(c53291093.desop)
			-- 注册效果：将结束阶段破坏效果注册给玩家
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 破坏条件判断：确认特殊召唤的怪兽是否仍处于场上且未被移除
function c53291093.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(53291093)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 破坏操作：在结束阶段时破坏特殊召唤的怪兽
function c53291093.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 实际破坏：执行对目标怪兽的破坏动作
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
