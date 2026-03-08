--カオス・インフィニティ
-- 效果：
-- ①：场上的守备表示怪兽全部变成表侧攻击表示。那之后，从自己的卡组·墓地选1只「机皇」怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段破坏。
function c4081825.initial_effect(c)
	-- ①：场上的守备表示怪兽全部变成表侧攻击表示。那之后，从自己的卡组·墓地选1只「机皇」怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c4081825.target)
	e1:SetOperation(c4081825.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断是否为「机皇」卡且可以特殊召唤
function c4081825.spfilter(c,e,tp)
	return c:IsSetCard(0x13) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的发动条件判断，检查场上是否存在守备表示怪兽、是否有特殊召唤区域、卡组或墓地是否存在「机皇」怪兽
function c4081825.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在守备表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 检查自己场上是否有特殊召唤区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组或墓地是否存在「机皇」怪兽
		and Duel.IsExistingMatchingCard(c4081825.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果处理时要特殊召唤的卡的类型和数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果的处理函数，执行将守备表示怪兽变为攻击表示并特殊召唤「机皇」怪兽的操作
function c4081825.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有守备表示怪兽的集合
	local g=Duel.GetMatchingGroup(Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return end
	-- 将所有守备表示怪兽变为攻击表示
	Duel.ChangePosition(g,POS_FACEUP_ATTACK)
	-- 检查是否还有特殊召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组或墓地选择一只「机皇」怪兽进行特殊召唤
	local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c4081825.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=sg:GetFirst()
	if tc then
		-- 中断当前效果，使之后的效果处理视为不同时处理
		Duel.BreakEffect()
		-- 特殊召唤选定的怪兽
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 使特殊召唤的怪兽效果无效
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 使特殊召唤的怪兽效果无效化
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		-- 完成特殊召唤步骤
		Duel.SpecialSummonComplete()
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(4081825,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 注册结束阶段破坏效果
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetLabel(fid)
		e3:SetLabelObject(tc)
		e3:SetCondition(c4081825.descon)
		e3:SetOperation(c4081825.desop)
		e3:SetCountLimit(1)
		-- 将破坏效果注册给玩家
		Duel.RegisterEffect(e3,tp)
	end
end
-- 判断是否为该效果特殊召唤的怪兽
function c4081825.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(4081825)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
-- 执行破坏操作
function c4081825.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将目标怪兽以效果原因破坏
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
