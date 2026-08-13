--斬機ナブラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1只电子界族怪兽解放才能发动。从卡组把1只「斩机」怪兽特殊召唤。
-- ②：这张卡被送去墓地的场合，以额外怪兽区域1只自己的电子界族怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中最多2次可以向怪兽攻击。
function c53577438.initial_effect(c)
	-- ①：把自己场上1只电子界族怪兽解放才能发动。从卡组把1只「斩机」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53577438,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,53577438)
	e1:SetCost(c53577438.cost)
	e1:SetTarget(c53577438.target)
	e1:SetOperation(c53577438.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合，以额外怪兽区域1只自己的电子界族怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,53577439)
	-- 设置②效果的发动条件为当前可进入战斗阶段或正处于战斗阶段，即该效果只能在主要阶段或战斗阶段发动。
	e2:SetCondition(aux.bpcon)
	e2:SetTarget(c53577438.datg)
	e2:SetOperation(c53577438.daop)
	c:RegisterEffect(e2)
end
-- ①效果的解放代价筛选函数：选择场上1只电子界族怪兽作为解放候选，并确认解放后自己场上仍有空余的怪兽区可供后续特殊召唤。
function c53577438.costfilter(c,tp)
	-- 返回真当且仅当c是电子界族怪兽，且解放c后自己场上有可用的怪兽区（为特殊召唤留出格子）。
	return c:IsRace(RACE_CYBERSE) and Duel.GetMZoneCount(tp,c,tp)>0
end
-- ①效果的代价处理函数：在效果发动时先检查能否解放电子界族怪兽，若可以则选择1只解放作为发动代价。
function c53577438.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果合法性检查阶段：检查自己场上是否存在至少1只满足costfilter（电子界族且解放后有空位）的可解放怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c53577438.costfilter,1,nil,tp) end
	-- 效果发动时，让玩家从自己场上选择1只满足costfilter的电子界族怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,c53577438.costfilter,1,1,nil,tp)
	-- 将选中的怪兽以“代价”形式解放（作为发动①效果所需支付的成本）。
	Duel.Release(g,REASON_COST)
end
-- 特殊召唤筛选函数：选择卡组中卡名带有「斩机」字段、并且可以被当前效果正常特殊召唤的怪兽。
function c53577438.filter(c,e,tp)
	return c:IsSetCard(0x132) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的目标设定函数：确认卡组中存在可特殊召唤的「斩机」怪兽，并设置特殊召唤的操作信息。
function c53577438.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：检查卡组中是否存在至少1只满足filter的「斩机」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c53577438.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记本次连锁将进行特殊召唤的操作信息：从卡组特殊召唤1只怪兽，供其他卡（如星尘龙等）进行对应检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理函数：先确认自己场上有空位，然后从卡组选择1只「斩机」怪兽以表侧表示特殊召唤。
function c53577438.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上有可用的怪兽区，若没有则特殊召唤不进行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的选择提示，引导玩家从卡组选择怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1张满足filter条件的「斩机」怪兽。
	local g=Duel.SelectMatchingCard(tp,c53577438.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「斩机」怪兽以表侧攻击表示特殊召唤到自己场上（不检查召唤条件与苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的取对象筛选函数：选择自己额外怪兽区域中表侧表示、电子界族、且尚未获得额外攻击次数效果的怪兽作为对象。
function c53577438.dafilter(c)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE) and not c:IsHasEffect(EFFECT_EXTRA_ATTACK) and c:GetSequence()>=5
end
-- ②效果的目标设定函数：在发动时确认存在符合条件的对象，并选择1只额外怪兽区域的表侧电子界族怪兽作为效果对象。
function c53577438.datg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c53577438.dafilter(chkc) end
	-- 效果发动合法性检查：确认自己额外怪兽区域存在至少1只满足dafilter的电子界族怪兽可取为对象。
	if chk==0 then return Duel.IsExistingTarget(c53577438.dafilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示“请选择表侧表示的卡”的选择提示，用于选择额外怪兽区域的表侧电子界族怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择1只自己额外怪兽区域表侧表示的电子界族怪兽，并将其登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,c53577438.dafilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果处理函数：取得对象怪兽，若仍与效果相关，则赋予其本回合最多可向怪兽攻击2次的效果，并在回合结束时重置。
function c53577438.daop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，那只怪兽在同1次的战斗阶段中最多2次可以向怪兽攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
