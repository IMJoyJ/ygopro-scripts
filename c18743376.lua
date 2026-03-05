--メタファイズ・タイラント・ドラゴン
-- 效果：
-- ①：「玄化」怪兽的效果特殊召唤的这张卡不受陷阱卡的效果影响，可以在这张卡向怪兽攻击过的场合只再1次继续攻击。
-- ②：这张卡被除外的场合，下个回合的准备阶段让除外的这张卡回到卡组才能发动。从手卡把1只「玄化」怪兽特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段除外。
function c18743376.initial_effect(c)
	-- 效果原文内容：①：「玄化」怪兽的效果特殊召唤的这张卡不受陷阱卡的效果影响，可以在这张卡向怪兽攻击过的场合只再1次继续攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c18743376.regcon)
	e1:SetOperation(c18743376.regop)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：这张卡被除外的场合，下个回合的准备阶段让除外的这张卡回到卡组才能发动。从手卡把1只「玄化」怪兽特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18743376,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCondition(c18743376.spcon)
	e2:SetCost(c18743376.spcost)
	e2:SetTarget(c18743376.sptg)
	e2:SetOperation(c18743376.spop)
	c:RegisterEffect(e2)
end
-- 规则层面操作：判断是否为「玄化」怪兽的效果特殊召唤
function c18743376.regcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x105)
end
-- 规则层面操作：为该卡注册免疫陷阱效果、战斗时可再攻击一次的效果
function c18743376.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果原文内容：这张卡不受陷阱卡的效果影响
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c18743376.efilter)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	-- 效果原文内容：可以在这张卡向怪兽攻击过的场合只再1次继续攻击
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLED)
	e2:SetOperation(c18743376.caop1)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	-- 效果原文内容：可以在这张卡向怪兽攻击过的场合只再1次继续攻击
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetOperation(c18743376.caop2)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 规则层面操作：使效果只对陷阱卡生效
function c18743376.efilter(e,re)
	return re:IsActiveType(TYPE_TRAP)
end
-- 规则层面操作：记录攻击者是否为本卡
function c18743376.caop1(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取当前攻击的怪兽
	local a=Duel.GetAttacker()
	-- 规则层面操作：获取当前被攻击的怪兽
	local d=Duel.GetAttackTarget()
	if e:GetHandler()==a and d then e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 规则层面操作：若满足条件则使本卡再进行一次攻击
function c18743376.caop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabelObject():GetLabel()==1 and c:IsRelateToBattle() and c:IsChainAttackable() then
		-- 规则层面操作：使攻击卡可以再进行1次攻击
		Duel.ChainAttack()
	end
end
-- 规则层面操作：判断是否为下个回合的准备阶段
function c18743376.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：判断是否为下个回合的准备阶段
	return Duel.GetTurnCount()==e:GetHandler():GetTurnID()+1
end
-- 规则层面操作：将自身送入卡组作为费用
function c18743376.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
	-- 规则层面操作：将自身送入卡组作为费用
	Duel.SendtoDeck(e:GetHandler(),tp,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 规则层面操作：过滤手牌中可特殊召唤的「玄化」怪兽
function c18743376.spfilter(c,e,tp)
	return c:IsSetCard(0x105) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面操作：判断是否满足特殊召唤条件
function c18743376.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面操作：判断手牌中是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c18743376.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 规则层面操作：设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 规则层面操作：执行特殊召唤并设置其在下个回合结束时除外
function c18743376.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：判断场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 规则层面操作：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面操作：选择符合条件的怪兽
	local tc=Duel.SelectMatchingCard(tp,c18743376.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
	-- 规则层面操作：特殊召唤所选怪兽
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		tc:RegisterFlagEffect(18743376,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 效果原文内容：这个效果特殊召唤的怪兽在下个回合的结束阶段除外
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		-- 规则层面操作：设置该效果在下个回合结束时触发
		e2:SetLabel(Duel.GetTurnCount()+1)
		e2:SetLabelObject(tc)
		e2:SetCondition(c18743376.descon)
		e2:SetOperation(c18743376.desop)
		-- 规则层面操作：注册该效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 规则层面操作：判断是否为指定回合结束
function c18743376.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(18743376)~=0 then
		-- 规则层面操作：判断是否为指定回合结束
		return Duel.GetTurnCount()==e:GetLabel()
	else
		e:Reset()
		return false
	end
end
-- 效果原文内容：这个效果特殊召唤的怪兽在下个回合的结束阶段除外
function c18743376.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 规则层面操作：将怪兽除外
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end
