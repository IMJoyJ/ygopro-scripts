--トライアングル・エリア
-- 效果：
-- 把场上存在的1只有A指示物放置的怪兽破坏。并且可以再从自己卡组把1只名字带有「外星」的4星怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段时破坏。
function c53291093.initial_effect(c)
	-- 效果设定：将此卡作为发动效果的魔法卡，具有取对象特性，可在自由时点发动，提示在怪兽正面上场和结束阶段时点
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
-- 过滤函数：判断目标怪兽是否拥有A指示物（指示物编号0x100e）
function c53291093.filter(c)
	return c:GetCounter(0x100e)>0
end
-- 效果处理的目标选择：设定效果目标为场上存在A指示物的怪兽，若无满足条件的怪兽则效果不发动
function c53291093.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c53291093.filter(chkc) end
	-- 检查阶段：确认是否有满足条件的怪兽可作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c53291093.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示信息：向玩家发送“请选择要破坏的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择目标：从场上选择1只拥有A指示物的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c53291093.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：将本次效果处理中要破坏的怪兽加入操作信息，用于发动检测和连锁处理
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 特殊召唤过滤函数：筛选名字带有「外星」且等级为4的怪兽，可被特殊召唤
function c53291093.spfilter(c,e,tp)
	return c:IsSetCard(0xc) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理流程：判断目标怪兽是否满足破坏条件并成功破坏，若满足则从卡组检索符合条件的怪兽进行特殊召唤
function c53291093.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标对象：获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标状态：确认目标怪兽正面表示且与效果相关联，并成功破坏该怪兽
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0
		-- 判断召唤区域是否充足：确认玩家场上是否有足够的召唤区域进行特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 检索符合条件的怪兽：从卡组中筛选名字带有「外星」且等级为4的怪兽
		local g=Duel.GetMatchingGroup(c53291093.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 询问是否特殊召唤：向玩家询问是否要特殊召唤检索到的怪兽
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(53291093,0)) then  --"是否要特殊召唤？"
			-- 提示信息：向玩家发送“请选择要特殊召唤的卡”的提示信息
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 中断当前效果处理：使后续效果处理不与当前效果同时进行，避免错时点
			Duel.BreakEffect()
			-- 特殊召唤怪兽：将选择的怪兽以正面表示方式特殊召唤到场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			local sc=sg:GetFirst()
			local fid=e:GetHandler():GetFieldID()
			sc:RegisterFlagEffect(53291093,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			-- 注册结束阶段破坏效果：为特殊召唤的怪兽在结束阶段时自动破坏的效果设定
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetLabel(fid)
			e1:SetLabelObject(sc)
			e1:SetCondition(c53291093.descon)
			e1:SetOperation(c53291093.desop)
			-- 注册效果：将设定好的结束阶段破坏效果注册到全局环境
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 破坏条件判断函数：判断目标怪兽是否仍处于场上并满足破坏条件
function c53291093.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(53291093)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 破坏操作函数：执行对目标怪兽的破坏处理
function c53291093.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 实际破坏怪兽：将目标怪兽以效果原因进行破坏
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
