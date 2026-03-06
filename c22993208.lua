--炎王の急襲
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：只有对方场上才有怪兽存在的场合才能发动。从卡组把1只兽族·兽战士族·鸟兽族的炎属性怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段破坏。
function c22993208.initial_effect(c)
	-- 效果定义：发动时满足条件才能发动，特殊召唤1只符合条件的怪兽，结束阶段破坏，效果无效化
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,22993208+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c22993208.condition)
	e1:SetTarget(c22993208.target)
	e1:SetOperation(c22993208.activate)
	c:RegisterEffect(e1)
end
-- 只有对方场上才有怪兽存在的场合才能发动
function c22993208.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否有怪兽存在
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		-- 检查自己场上是否有怪兽存在
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 过滤函数：检索满足条件的怪兽（炎属性、兽族/兽战士族/鸟兽族、可特殊召唤）
function c22993208.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理前的确认：确认场上是否有空位且卡组中是否存在符合条件的怪兽
function c22993208.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认卡组中是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c22993208.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息：准备特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：选择并特殊召唤符合条件的怪兽，设置效果无效和结束阶段破坏
function c22993208.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c22993208.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	local c=e:GetHandler()
	-- 执行特殊召唤操作
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 使特殊召唤的怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 使特殊召唤的怪兽效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		tc:RegisterFlagEffect(22993208,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 设置结束阶段破坏效果
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetCountLimit(1)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetLabelObject(tc)
		e3:SetCondition(c22993208.descon)
		-- 设置破坏操作
		e3:SetOperation(aux.EPDestroyOperation)
		-- 注册结束阶段破坏效果
		Duel.RegisterEffect(e3,tp)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 结束阶段破坏的判断条件：检查怪兽是否拥有标记
function c22993208.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(22993208)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
