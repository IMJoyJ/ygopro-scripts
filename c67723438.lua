--緊急テレポート
-- 效果：
-- ①：从手卡·卡组把1只3星以下的念动力族怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合的结束阶段除外。
function c67723438.initial_effect(c)
	-- ①：从手卡·卡组把1只3星以下的念动力族怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合的结束阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c67723438.target)
	e1:SetOperation(c67723438.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：等级3以下且可以特殊召唤的念动力族怪兽
function c67723438.filter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsRace(RACE_PSYCHO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的可行性检测：检查怪兽区域是否有空位，以及手卡或卡组是否存在满足过滤条件的怪兽
function c67723438.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可以用于特殊召唤的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡或卡组是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c67723438.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息，表示该效果包含从手卡或卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK+LOCATION_HAND)
end
-- 效果处理：从手卡或卡组特殊召唤1只满足条件的怪兽，并注册在结束阶段将其除外的效果
function c67723438.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上已无可用怪兽区域空位，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	-- 给玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡或卡组中选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c67723438.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(67723438,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		-- 这个效果特殊召唤的怪兽在这个回合的结束阶段除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c67723438.rmcon)
		e1:SetOperation(c67723438.rmop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将用于在结束阶段除外该怪兽的延迟效果注册给玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 检查目标怪兽是否仍带有对应的标记，以确定是否满足除外条件
function c67723438.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:GetFlagEffectLabel(67723438)==e:GetLabel()
end
-- 结束阶段除外效果的具体执行操作
function c67723438.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 因效果将目标怪兽表侧表示除外
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end
