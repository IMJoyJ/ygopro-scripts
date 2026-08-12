--プチラノドン
-- 效果：
-- ①：这张卡被效果破坏送去墓地的场合发动。从卡组把1只4星以上的恐龙族怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
function c82946847.initial_effect(c)
	-- ①：这张卡被效果破坏送去墓地的场合发动。从卡组把1只4星以上的恐龙族怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82946847,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c82946847.spcon)
	e1:SetTarget(c82946847.sptg)
	e1:SetOperation(c82946847.spop)
	c:RegisterEffect(e1)
end
-- 检查发动条件：此卡是否因效果破坏并送去墓地。
function c82946847.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsReason(REASON_DESTROY)
end
-- 过滤卡组中满足条件的卡：4星以上的恐龙族怪兽，且可以特殊召唤。
function c82946847.filter(c,e,tp)
	return c:IsRace(RACE_DINOSAUR) and c:IsLevelAbove(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的处理：设置特殊召唤的操作信息。
function c82946847.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行：从卡组特殊召唤1只4星以上的恐龙族怪兽，并使其在本回合不能攻击。
function c82946847.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽区域是否有空位，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c82946847.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 如果成功选择怪兽，则尝试将其以表侧表示特殊召唤（分步处理）。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽在这个回合不能攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤的流程。
	Duel.SpecialSummonComplete()
end
