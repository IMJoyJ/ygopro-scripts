--転生炎獣の炎軍
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●以自己的墓地·除外状态的3只炎属性怪兽为对象才能发动。那3只之内的2只回到卡组，剩下的1只特殊召唤。这个效果特殊召唤的怪兽在这个回合效果无效化，不能攻击。
-- ●持有和原本攻击力不同攻击力的炎属性的仪式·融合·同调·超量·连接怪兽在自己场上存在的场合，以场上1张卡为对象才能发动。那张卡破坏。
local s,id,o=GetID()
-- 注册两个魔法卡发动效果：e1为回收·特殊召唤效果（取对象、自由时点、结束阶段时点提示、同名卡1回合1张），e2为场上卡破坏效果（需满足发动条件、取对象、自由时点、同名卡1回合1张）。
function s.initial_effect(c)
	-- ①：可以从以下效果选择1个发动。●以自己的墓地·除外状态的3只炎属性怪兽为对象才能发动。那3只之内的2只回到卡组，剩下的1只特殊召唤。这个效果特殊召唤的怪兽在这个回合效果无效化，不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回收除外的怪兽"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ●持有和原本攻击力不同攻击力的炎属性的仪式·融合·同调·超量·连接怪兽在自己场上存在的场合，以场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"场上卡破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 过滤函数：要求怪兽为炎属性、表侧表示存在于墓地或除外状态、可以返回卡组（用于选择回卡组的2只）。
function s.filter1(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsFaceupEx() and c:IsAbleToDeck()
end
-- 过滤函数：要求怪兽为炎属性、表侧表示、可以被特殊召唤，并且除此之外墓地·除外状态还存在2只可回卡组的炎属性怪兽（用于选择特殊召唤的1只）。
function s.filter2(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsFaceupEx() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 并且在自己墓地·除外状态还能再选取2只满足回卡组条件（filter1）的怪兽作为对象。
		and Duel.IsExistingTarget(s.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,c)
end
-- e1的目标函数：连锁处理时判断自己主要怪兽区有空位，且墓地·除外状态存在可作为对象的特殊召唤用炎属性怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动条件判断：自己主要怪兽区至少有1个可用空格（能特殊召唤怪兽）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己墓地·除外状态存在至少1只满足特殊召唤条件（filter2）且能成为对象的怪兽。
		and Duel.IsExistingTarget(s.filter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向自己发送选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地·除外状态选择1只满足特殊召唤条件的炎属性怪兽作为对象。
	local g1=Duel.SelectTarget(tp,s.filter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 向自己发送选择提示：请选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 再从自己墓地·除外状态选择2只满足回卡组条件（filter1）的炎属性怪兽作为对象（排除刚才选为特殊召唤对象的那只）。
	local g2=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,2,g1:GetFirst())
	-- 设置操作信息：确定将2只对象怪兽返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g2,2,0,0)
	-- 设置操作信息：确定将1只对象怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,1,0,0)
end
-- e1的处理函数：取回与本次连锁相关的3只对象，确认2只回卡组对象和1只特殊召唤对象都仍与效果相关后，先将2只返回卡组洗牌，再特殊召唤剩下的1只并赋予其这个回合效果无效化、不能攻击的限制。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得与本次连锁相关的全部对象卡（应为3只）。
	local g=Duel.GetTargetsRelateToChain()
	if #g~=3 then return end
	-- 取得操作信息中记录的2只返回卡组的怪兽。
	local ex,g1=Duel.GetOperationInfo(0,CATEGORY_TODECK)
	-- 取得操作信息中记录的1只要特殊召唤的怪兽。
	local ex,g2=Duel.GetOperationInfo(0,CATEGORY_SPECIAL_SUMMON)
	if g1:GetFirst():IsRelateToEffect(e) and g1:GetNext():IsRelateToEffect(e) then
		local tc=g2:GetFirst()
		-- 将2只对象怪兽返回卡组并洗牌，且特殊召唤对象怪兽仍与效果相关时继续处理。
		if Duel.SendtoDeck(g1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and tc:IsRelateToEffect(e) then
			-- 中断当前效果，使之后的特殊召唤与回卡组视为不同时处理（避免错过时点）。
			Duel.BreakEffect()
			-- 将剩下1只对象怪兽在自己场上表侧表示特殊召唤（分步处理）。
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			-- 这个效果特殊召唤的怪兽在这个回合效果无效化，不能攻击。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			tc:RegisterEffect(e2)
			local e3=e1:Clone()
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_CANNOT_ATTACK)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
			-- 完成特殊召唤（与SpecialSummonStep对应，结算特殊召唤成功）。
			Duel.SpecialSummonComplete()
		end
	end
end
-- 过滤函数：要求怪兽为炎属性的仪式·融合·同调·超量·连接怪兽，且当前攻击力与原本攻击力不同。
function s.desfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsType(TYPE_FUSION+TYPE_RITUAL+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
		and c:GetAttack()~=c:GetBaseAttack()
end
-- e2的发动条件：自己场上存在满足条件（攻击力与原本攻击力不同的炎属性仪式·融合·同调·超量·连接）的怪兽。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己怪兽区是否存在至少1只满足desfilter条件的怪兽。
	return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- e2的目标函数：连锁处理时判断场上存在可成为对象的卡，然后选择场上1张卡作为对象，并设置破坏操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 发动条件判断：场上存在至少1张可以成为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向自己发送选择提示：请选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择双方场上1张卡作为破坏对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：确定破坏那1张对象卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- e2的处理函数：取得对象卡，若其仍与效果相关则将其效果破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次连锁的对象卡（即选择要破坏的那张卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏那张对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
