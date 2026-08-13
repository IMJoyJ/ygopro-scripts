--サイバー・ネットワーク
-- 效果：
-- 这张卡发动后，第3次的自己准备阶段破坏。
-- ①：1回合1次，场上有「电子龙」存在的场合才能发动。从卡组把1只机械族·光属性怪兽除外。
-- ②：这张卡从场上送去墓地的场合发动。除外的自己的机械族·光属性怪兽尽可能特殊召唤，自己场上的魔法·陷阱卡全部破坏。这个效果特殊召唤的怪兽不能把效果发动。这个效果发动的回合，自己不能进行战斗阶段。
function c12670770.initial_effect(c)
	-- 这张卡发动后，第3次的自己准备阶段破坏。①：1回合1次，场上有「电子龙」存在的场合才能发动。从卡组把1只机械族·光属性怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c12670770.target1)
	e1:SetOperation(c12670770.operation)
	c:RegisterEffect(e1)
	-- ①：1回合1次，场上有「电子龙」存在的场合才能发动。从卡组把1只机械族·光属性怪兽除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12670770,2))  --"从卡组把1只机械族·光属性怪兽除外"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCondition(c12670770.condition)
	e2:SetTarget(c12670770.target2)
	e2:SetOperation(c12670770.operation)
	c:RegisterEffect(e2)
	-- ②：这张卡从场上送去墓地的场合发动。除外的自己的机械族·光属性怪兽尽可能特殊召唤，自己场上的魔法·陷阱卡全部破坏。这个效果特殊召唤的怪兽不能把效果发动。这个效果发动的回合，自己不能进行战斗阶段。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(12670770,3))  --"除外的怪兽特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c12670770.spcon)
	e3:SetCost(c12670770.spcost)
	e3:SetTarget(c12670770.sptg)
	e3:SetOperation(c12670770.spop)
	c:RegisterEffect(e3)
end
-- 过滤出场上表侧表示且卡名为「电子龙」（70095154）的怪兽，用于检查场上是否存在「电子龙」。
function c12670770.filter1(c)
	return c:IsFaceup() and c:IsCode(70095154)
end
-- 过滤出卡组中满足机械族·光属性且可以被除外的怪兽，作为①效果从卡组除外的候选对象。
function c12670770.filter2(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToRemove()
end
-- ①效果的发动条件：检查双方场上是否存在至少1张表侧表示且卡名为「电子龙」的怪兽。
function c12670770.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 若场上存在至少1张满足filter1（表侧表示「电子龙」）的卡，则①效果的发动条件成立。
	return Duel.IsExistingMatchingCard(c12670770.filter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 魔法卡发动处理：先确认可以发动；随后给「电子网络」注册一个不得无效的自爆倒计时效果并将回合计数器归零（每次自己准备阶段计数+1到3时破坏）；若此时场上有「电子龙」且卡组存在可除外的机械族·光属性怪兽，则询问玩家是否立即使用①效果，选择是则设置除外操作信息并标记本回合已使用①。
function c12670770.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 这张卡发动后，第3次的自己准备阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12670770,4))  --"回合计数"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetCondition(c12670770.sdescon)
	e1:SetOperation(c12670770.sdesop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,3)
	c:RegisterEffect(e1)
	c:SetTurnCounter(0)
	-- 判断场上是否存在表侧表示「电子龙」，作为发动时能否选择立即使用①效果的条件之一。
	if Duel.IsExistingMatchingCard(c12670770.filter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		-- 判断卡组中是否存在机械族·光属性且可以除外的怪兽，作为发动时能否选择立即使用①效果的条件之一。
		and Duel.IsExistingMatchingCard(c12670770.filter2,tp,LOCATION_DECK,0,1,nil)
		-- 弹窗询问玩家是否现在使用「电子网络」的①效果，只有选择是才会设置后续的除外处理。
		and Duel.SelectYesNo(tp,aux.Stringid(12670770,0)) then  --"是否现在使用「电子网络」的效果？"
		-- 设置连锁处理信息为从卡组除外1张卡（对象不确定所以targets为nil），使系统知道本次效果涉及除外卡牌。
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
		c:RegisterFlagEffect(12670770,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		c:RegisterFlagEffect(0,RESET_CHAIN,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(12670770,1))  --"使用效果"
	end
end
-- ①效果的合法性检查：当「电子网络」本回合尚未发动过①（无12670770标志）且卡组中存在可除外的机械族·光属性怪兽时，才允许发动①。
function c12670770.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(12670770)==0
		-- 同时要求卡组中存在至少1只机械族·光属性且可以除外的怪兽，作为①效果的发动前提。
		and Duel.IsExistingMatchingCard(c12670770.filter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息为从卡组除外1张卡，供效果处理及后续连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
	e:GetHandler():RegisterFlagEffect(12670770,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- ①效果的除外处理：先确认卡仍与连锁相关且已取得本回合使用标志，然后由玩家从卡组选择1只机械族·光属性且可以除外的怪兽，表侧表示除外。
function c12670770.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(12670770)==0 or not e:GetHandler():IsRelateToEffect(e) then return end
	-- 显示“请选择要除外的卡”的选卡提示，并把选择消息类型设为除外。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从己方卡组选择1张满足filter2（机械族·光属性且可除外）的怪兽，作为本次除外对象。
	local g=Duel.SelectMatchingCard(tp,c12670770.filter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以表侧表示除外，除外原因为效果（REASON_EFFECT）。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
-- 自爆倒计时效果的触发条件：仅在「电子网络」控制者自己的准备阶段才进行计数。
function c12670770.sdescon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为这张卡的控制者，确保只在控制者自己的准备阶段计数。
	return tp==Duel.GetTurnPlayer()
end
-- 自爆倒计时处理：每次触发将回合计数器加1；当计数达到3时，以规则原因（REASON_RULE）将「电子网络」自身破坏。
function c12670770.sdesop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==3 then
		-- 以规则理由（REASON_RULE）破坏「电子网络」，该破坏不进入连锁、不受免疫效果影响且不能被代破。
		Duel.Destroy(c,REASON_RULE)
	end
end
-- ②效果的触发条件：这张卡从场上区域（怪兽区/魔陷区/场地）送去墓地时触发，从其他区域送去墓地不触发。
function c12670770.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤除外区中表侧表示的机械族·光属性怪兽，并且该怪兽能够被当前效果特殊召唤。
function c12670770.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动代价：先确认本回合尚未进行过战斗阶段；发动时给己方设置一个本回合不能进行战斗阶段的誓约效果（EFFECT_CANNOT_BP）。
function c12670770.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：要求本回合己方尚未进行过战斗阶段（ACTIVITY_BATTLE_PHASE次数为0），才能发动②效果。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_BATTLE_PHASE)==0 end
	-- ②：这张卡从场上送去墓地的场合发动。除外的自己的机械族·光属性怪兽尽可能特殊召唤，自己场上的魔法·陷阱卡全部破坏。这个效果发动的回合，自己不能进行战斗阶段。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能进行战斗阶段”的誓约效果注册给发动玩家tp，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- ②效果的目标处理：发动本身总是合法（chk==0返回true）；处理时设置操作信息为从除外区特殊召唤1只怪兽。
function c12670770.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理信息为从除外区特殊召唤怪兽（数量未定，targets为nil），供系统检测与提示。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
-- 过滤己方场上的魔法·陷阱卡，作为②效果中“自己场上的魔法·陷阱卡全部破坏”的处理对象。
function c12670770.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ②效果处理：获取可用怪兽区域和除外区可特殊召唤的机械族·光属性怪兽；若无空位或没有可召唤怪兽则终止。若「青眼精灵龙」效果适用则最多只能特殊召唤1只；玩家选择召唤对象后逐只特殊召唤，并给每只召唤成功的怪兽附加“不能发动效果”的永续状态；最后破坏己方场上的全部魔法·陷阱卡。
function c12670770.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方场上的可用怪兽区域数量，用于决定本次最多能特殊召唤几只怪兽。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取除外区中满足spfilter（表侧机械族·光属性且可被效果特殊召唤）的怪兽集合。
	local tg=Duel.GetMatchingGroup(c12670770.spfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
	if ft<=0 or tg:GetCount()==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 显示“请选择要特殊召唤的卡”的提示，供玩家从可特殊召唤怪兽中选择处理对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=tg:Select(tp,ft,ft,nil)
	local tc=g:GetFirst()
	while tc do
		-- 将选中的怪兽以表侧表示逐只进行特殊召唤（配合SpecialSummonComplete在全部处理完毕后统一完成召唤）。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽不能把效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
	-- 完成连锁特殊召唤处理，确认所有通过SpecialSummonStep特殊召唤的怪兽最终召唤成功。
	Duel.SpecialSummonComplete()
	-- 获取己方场上的全部魔法·陷阱卡，作为②效果中“自己场上的魔法·陷阱卡全部破坏”的处理对象。
	local dg=Duel.GetMatchingGroup(c12670770.desfilter,tp,LOCATION_ONFIELD,0,nil)
	-- 以效果原因（REASON_EFFECT）破坏选中的己方场上的魔法·陷阱卡（全部破坏）。
	Duel.Destroy(dg,REASON_EFFECT)
end
