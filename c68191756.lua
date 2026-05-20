--星遺物の機憶
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡·卡组把1只「机界骑士」怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到持有者手卡。这张卡的发动后，直到回合结束时自己不是「机界骑士」怪兽不能特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：从手卡·卡组把1只「机界骑士」怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到持有者手卡。这张卡的发动后，直到回合结束时自己不是「机界骑士」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：手卡·卡组中可以守备表示特殊召唤的「机界骑士」怪兽
function s.filter(c,e,tp)
	return c:IsSetCard(0x10c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动的目标检查与准备函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或卡组是否存在满足特殊召唤条件的「机界骑士」怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，预估从手卡或卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果发动的处理函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时自己不是「机界骑士」怪兽不能特殊召唤。①：从手卡·卡组把1只「机界骑士」怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到持有者手卡。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册限制玩家不能特殊召唤「机界骑士」以外怪兽的效果
		Duel.RegisterEffect(e1,tp)
	end
	-- 若此时自己场上没有空余的怪兽区域，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组选择1只满足条件的「机界骑士」怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若成功选择怪兽，则尝试将其以表侧守备表示特殊召唤（分步处理）
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		local fid=c:GetFieldID()
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果特殊召唤的怪兽在结束阶段回到持有者手卡。这张卡的发动后，直到回合结束时自己不是「机界骑士」怪兽不能特殊召唤。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetCountLimit(1)
		e3:SetLabel(fid)
		e3:SetLabelObject(tc)
		e3:SetCondition(s.thcon)
		e3:SetOperation(s.thop)
		-- 注册在结束阶段将该怪兽送回手卡的时点效果
		Duel.RegisterEffect(e3,tp)
	end
	-- 完成特殊召唤的处理
	Duel.SpecialSummonComplete()
end
-- 限制条件：不能特殊召唤「机界骑士」以外的怪兽
function s.splimit(e,c)
	return not c:IsSetCard(0x10c)
end
-- 结束阶段回到手卡效果的触发条件：检查怪兽是否仍带有对应的标记
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
-- 结束阶段回到手卡效果的具体操作
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 展示卡片发动提示
	Duel.Hint(HINT_CARD,0,id)
	local tc=e:GetLabelObject()
	-- 将目标怪兽送回持有者手卡
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
end
