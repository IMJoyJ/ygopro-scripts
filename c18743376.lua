--メタファイズ・タイラント・ドラゴン
-- 效果：
-- ①：「玄化」怪兽的效果特殊召唤的这张卡不受陷阱卡的效果影响，可以在这张卡向怪兽攻击过的场合只再1次继续攻击。
-- ②：这张卡被除外的场合，下个回合的准备阶段让除外的这张卡回到卡组才能发动。从手卡把1只「玄化」怪兽特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段除外。
function c18743376.initial_effect(c)
	-- ①：「玄化」怪兽的效果特殊召唤的这张卡不受陷阱卡的效果影响，可以在这张卡向怪兽攻击过的场合只再1次继续攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c18743376.regcon)
	e1:SetOperation(c18743376.regop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合，下个回合的准备阶段让除外的这张卡回到卡组才能发动。从手卡把1只「玄化」怪兽特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段除外。
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
-- 判定触发该特殊召唤成功的效果是否是由「玄化」怪兽的效果发动的：若效果来源为怪兽效果且发动者为「玄化」怪兽，则条件成立。
function c18743376.regcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x105)
end
-- 特殊召唤成功时，给这张卡注册免疫陷阱卡效果的效果、记录是否攻击过怪兽的效果以及在伤害步骤结束时追加攻击的效果。
function c18743376.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 不受陷阱卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c18743376.efilter)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	-- 可以在这张卡向怪兽攻击过的场合只再1次继续攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLED)
	e2:SetOperation(c18743376.caop1)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	-- 可以在这张卡向怪兽攻击过的场合只再1次继续攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetOperation(c18743376.caop2)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 免疫效果的过滤函数：判断要无效的效果是否为陷阱卡的效果。
function c18743376.efilter(e,re)
	return re:IsActiveType(TYPE_TRAP)
end
-- 在伤害计算后记录本卡是否攻击过怪兽：若攻击者是本卡且存在攻击目标，则标记为1，否则标记为0。
function c18743376.caop1(e,tp,eg,ep,ev,re,r,rp)
	-- 取得此次战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 取得此次战斗的攻击目标（直接攻击时为nil）。
	local d=Duel.GetAttackTarget()
	if e:GetHandler()==a and d then e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 伤害步骤结束时，若此前标记本卡攻击过怪兽且本卡仍与战斗相关并可以攻击，则让本卡再追加一次攻击。
function c18743376.caop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabelObject():GetLabel()==1 and c:IsRelateToBattle() and c:IsChainAttackable() then
		-- 使当前攻击卡可以再进行1次攻击。
		Duel.ChainAttack()
	end
end
-- 判断是否处于这张卡被除外后的下个回合的准备阶段：当前回合数等于这张卡的回合编号加1时条件成立。
function c18743376.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合数等于这张卡被除外时的回合数加1，即下个回合。
	return Duel.GetTurnCount()==e:GetHandler():GetTurnID()+1
end
-- 发动代价：将除外的这张卡返回卡组并洗牌，作为发动效果的代价。
function c18743376.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
	-- 将除外的这张卡返回持有者卡组并洗牌，作为发动代价。
	Duel.SendtoDeck(e:GetHandler(),tp,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 选择手卡中满足「玄化」字段且可以被效果特殊召唤的怪兽。
function c18743376.spfilter(c,e,tp)
	return c:IsSetCard(0x105) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时确认自己场上存在可用的主要怪兽区空格，且手卡中存在至少1只符合条件的「玄化」怪兽。
function c18743376.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查自己场上是否有可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且手卡中存在至少1只可特殊召唤的「玄化」怪兽。
		and Duel.IsExistingMatchingCard(c18743376.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 将本次效果处理信息设定为从手卡特殊召唤1只怪兽，供后续时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理时从手卡选择1只「玄化」怪兽特殊召唤，若成功则给其设置在下个回合结束阶段除外的效果。
function c18743376.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若自己场上没有可用主要怪兽区空格，则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1只符合条件的「玄化」怪兽。
	local tc=Duel.SelectMatchingCard(tp,c18743376.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
	-- 将选择的怪兽表侧攻击表示特殊召唤到自己场上，若特殊召唤成功则继续后续处理。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		tc:RegisterFlagEffect(18743376,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 这个效果特殊召唤的怪兽在下个回合的结束阶段除外。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		-- 记录需要除外的回合数：当前回合数加1，即下个回合。
		e2:SetLabel(Duel.GetTurnCount()+1)
		e2:SetLabelObject(tc)
		e2:SetCondition(c18743376.descon)
		e2:SetOperation(c18743376.desop)
		-- 将结束阶段除外的效果注册到当前玩家，使其在指定回合结束时生效。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 判断是否到了需要除外的回合：特殊召唤的怪兽仍存在且带有标记，并且当前回合数等于预设的回合数；若怪兽已离场则重置该效果。
function c18743376.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(18743376)~=0 then
		-- 当前回合数等于预设的回合数时，除外的条件成立。
		return Duel.GetTurnCount()==e:GetLabel()
	else
		e:Reset()
		return false
	end
end
-- 将特殊召唤的怪兽表侧表示除外。
function c18743376.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 以效果原因将那只怪兽表侧表示除外。
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end
