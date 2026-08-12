--アビスフィアー
-- 效果：
-- 从卡组把1只名字带有「水精鳞」的怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。此外，只要这张卡在场上存在，自己不能把魔法卡发动。这张卡从场上离开时，那只怪兽破坏。这张卡发动后，下次的对方的结束阶段时破坏。
function c60202749.initial_effect(c)
	-- 从卡组把1只名字带有「水精鳞」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMING_MAIN_END)
	e1:SetTarget(c60202749.target)
	e1:SetOperation(c60202749.operation)
	c:RegisterEffect(e1)
	-- 此外，只要这张卡在场上存在，自己不能把魔法卡发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,0)
	e2:SetValue(c60202749.aclimit)
	c:RegisterEffect(e2)
	-- 这张卡从场上离开时，那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetOperation(c60202749.desop)
	c:RegisterEffect(e3)
	-- 这个效果特殊召唤的怪兽的效果无效化。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_TARGET)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e4)
end
-- 过滤卡组中可以特殊召唤的「水精鳞」怪兽
function c60202749.filter(c,e,tp)
	return c:IsSetCard(0x74) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的对象/区域检测与自毁效果的注册
function c60202749.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在可以特殊召唤的「水精鳞」怪兽
		and Duel.IsExistingMatchingCard(c60202749.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 这张卡发动后，下次的对方的结束阶段时破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c60202749.sdescon)
	e1:SetOperation(c60202749.sdesop)
	-- 检查当前是否已经是对方回合的结束阶段
	if Duel.GetCurrentPhase()==PHASE_END and Duel.GetTurnPlayer()~=tp then
		-- 将当前回合数记录在效果的Label中，用于后续判断是否是“下次”的结束阶段
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
	else
		e1:SetLabel(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	end
	e:GetHandler():RegisterEffect(e1)
	-- 设置特殊召唤的操作信息，表示将从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组特殊召唤1只「水精鳞」怪兽，并将其与这张卡建立对象关联
function c60202749.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍在场上，以及自己场上是否有空余的怪兽区域，若不满足则不处理
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组选择1只满足条件的「水精鳞」怪兽
	local g=Duel.SelectMatchingCard(tp,c60202749.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若选择成功，则将该怪兽以表侧表示特殊召唤，并将其设为这张卡的对象（用于无效化和离场破坏效果）
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		c:SetCardTarget(tc)
	end
	-- 完成特殊召唤的流程
	Duel.SpecialSummonComplete()
end
-- 检查是否为对方回合，且不是发动时的那个回合的结束阶段（即“下次的对方的结束阶段”）
function c60202749.sdescon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前是对方回合，且回合数不等于发动时的回合数（防止在发动当回合的对方结束阶段直接破坏）
	return Duel.GetTurnPlayer()~=tp and Duel.GetTurnCount()~=e:GetLabel()
end
-- 破坏自身的效果处理
function c60202749.sdesop(e,tp,eg,ep,ev,re,r,rp)
	-- 因规则/效果限制破坏这张卡自身
	Duel.Destroy(e:GetHandler(),REASON_RULE)
end
-- 过滤玩家想要发动的卡，如果是魔法卡的发动则予以限制
function c60202749.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL)
end
-- 这张卡离场时，破坏与其关联的（特殊召唤的）怪兽
function c60202749.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 因效果破坏该怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
