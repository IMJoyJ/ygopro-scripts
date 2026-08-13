--炎王の結襲
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的手卡·卡组·墓地各把1只兽族·兽战士族·鸟兽族的炎属性怪兽特殊召唤（相同种族最多1只）。这个效果特殊召唤的怪兽的效果无效化，结束阶段破坏。
-- ②：把墓地的这张卡除外才能发动。这个回合，在自己的「炎王」怪兽的召唤·特殊召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
local s,id,o=GetID()
-- 注册①效果的通常魔法发动效果和②效果在墓地作为快速效果发动（除外为代价）的两个效果，均限制1回合1次
function s.initial_effect(c)
	-- ①：从自己的手卡·卡组·墓地各把1只兽族·兽战士族·鸟兽族的炎属性怪兽特殊召唤（相同种族最多1只）。这个效果特殊召唤的怪兽的效果无效化，结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。这个回合，在自己的「炎王」怪兽的召唤·特殊召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置②效果的发动代价：从墓地除外这张卡（aux.bfgcost实现）。
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
-- 过滤墓地中的候选：炎属性且种族为兽/兽战士/鸟兽，可以被特殊召唤，并且手牌还存在能与其种族不同的另一只候选。
function s.filter0(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查手牌是否存在满足filter1的怪兽，以确保能够从手牌再选1只且种族与墓地已选不同。
		and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_HAND,0,1,nil,e,tp,c:GetRace())
end
-- 过滤手牌中的候选：炎属性且种族为兽/兽战士/鸟兽，种族与墓地已选不同，可以被特殊召唤，并且卡组还存在能与前两者种族均不同的第三只候选。
function s.filter1(c,e,tp,race1)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)
		and not c:IsRace(race1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查卡组是否存在满足filter2的怪兽，以确保能够从卡组选出与前两只种族都不同的第三只。
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetRace(),race1)
end
-- 过滤卡组中的候选：炎属性且种族为兽/兽战士/鸟兽，种族与已选两只都不同，且可以被特殊召唤。
function s.filter2(c,e,tp,race1,race2)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)
		and not c:IsRace(race1) and not c:IsRace(race2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动条件判定：己方不受青眼精灵龙效果影响、怪兽区空格大于2、墓地存在至少1只符合条件的怪兽。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 要求己方怪兽区可用空格数大于2，确保能同时特殊召唤3只怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		-- 检查墓地存在至少1只满足filter0的候选怪兽。
		and Duel.IsExistingMatchingCard(s.filter0,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 登记操作信息：本效果将进行特殊召唤，预计从手卡·卡组·墓地合计3只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理：依次从墓地、手卡、卡组各选1只（种族互不相同）以表侧表示特殊召唤；对这些怪兽赋予效果无效化，并注册结束阶段破坏它们的延迟效果。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 处理时再确认己方怪兽区空格至少3个，否则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<3 then return end
	-- 获取墓地中满足filter0且不受王家长眠之谷影响的怪兽集合。
	local g1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter0),tp,LOCATION_GRAVE,0,nil,e,tp)
	if g1:GetCount()==0 then return end
	-- 向玩家弹出“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地的可选怪兽中选择1只作为第一只特殊召唤对象。
	local sg1=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter0),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc1=sg1:GetFirst()
	-- 提示玩家选择手牌中要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌选择1只与墓地所选种族不同的符合条件的怪兽作为第二只特殊召唤对象。
	local sg2=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_HAND,0,1,1,nil,e,tp,tc1:GetRace())
	local tc2=sg2:GetFirst()
	sg1:Merge(sg2)
	-- 提示玩家选择卡组中要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只与已选两只种族都不同的符合条件的怪兽作为第三只特殊召唤对象。
	local sg3=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc1:GetRace(),tc2:GetRace())
	sg1:Merge(sg3)
	local fid=c:GetFieldID()
	local tc=sg1:GetFirst()
	while tc do
		-- 将当前选中的怪兽以表侧攻击表示加入特殊召唤处理步骤。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 这个效果特殊召唤的怪兽的效果无效化，结束阶段破坏。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		tc=sg1:GetNext()
	end
	-- 完成整个特殊召唤处理，统一触发特殊召唤成功时的时点。
	Duel.SpecialSummonComplete()
	sg1:KeepAlive()
	-- 结束阶段破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCountLimit(1)
	e3:SetLabel(fid)
	e3:SetLabelObject(sg1)
	e3:SetCondition(s.descon)
	e3:SetOperation(s.desop)
	-- 将结束阶段破坏的诱发效果注册到场上，在该回合结束阶段执行。
	Duel.RegisterEffect(e3,tp)
end
-- 判断卡片是否带有本次特殊召唤时登记的fid标记，用于识别需要被破坏的怪兽。
function s.desfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
-- 结束阶段条件判定：如果场上仍存在带标记的怪兽则执行破坏；否则释放该组并重置效果。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(s.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 结束阶段破坏处理：取出带标记的怪兽并全部破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(s.desfilter,nil,e:GetLabel())
	-- 以效果原因破坏这些特殊召唤的怪兽。
	Duel.Destroy(tg,REASON_EFFECT)
end
-- ②效果处理：注册通常召唤·特殊召唤成功时的监听效果，以及连锁结束时的补充效果，实现在「炎王」怪兽召唤成功时封锁对方的效果发动。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，在自己的「炎王」怪兽的召唤·特殊召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.sumcon)
	e1:SetOperation(s.sumsuc)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册通常召唤成功时的监听效果。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	-- 注册特殊召唤成功时的监听效果。
	Duel.RegisterEffect(e2,tp)
	-- 这个回合，在自己的「炎王」怪兽的召唤·特殊召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_END)
	e3:SetOperation(s.limop2)
	-- 注册连锁结束时的效果，用于在召唤成功发生时将封锁效果延续到连锁结束。
	Duel.RegisterEffect(e3,tp)
end
-- 判断怪兽是否表侧表示且属于「炎王」系列（setname 0x81）。
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x81)
end
-- 召唤成功时的处理：若当前不在连锁中，直接设置连锁限制；若在连锁中，则登记标识并在连锁结束或中断时恢复限制。
function s.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否不在任何连锁处理中（连锁序号为0）。
	if Duel.GetCurrentChain()==0 then
		-- 设置直到连锁结束为止的连锁限制：只允许己方（炎王怪兽的控制者）发动效果，即对方不能发动。
		Duel.SetChainLimitTillChainEnd(s.efun)
	-- 判断当前是否处于连锁1中（说明召唤成功发生在连锁处理最初时，需要额外处理登记）。
	elseif Duel.GetCurrentChain()==1 then
		-- 为当前玩家登记1个标识效果，表示本回合已经触发过该限制，用于连锁结束时补设限制。
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		-- 这个回合，在自己的「炎王」怪兽的召唤·特殊召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(s.resetop)
		-- 注册监听新的连锁发动的效果，用于在连锁中重置标识。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 注册监听效果处理的连锁中断的效果，用于在中断时重置标识。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 召唤成功事件的满足条件：召唤成功的怪兽中存在表侧表示的「炎王」怪兽。
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil)
end
-- 连锁限制判定函数：只有当前发动效果的玩家是己方时才允许发动（即对方不能发动效果）。
function s.efun(e,ep,tp)
	return ep==tp
end
-- 连锁结束时处理：若存在已登记的标识，则补设连锁限制直到连锁结束，然后重置标识。
function s.limop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否已登记过触发标识。
	if Duel.GetFlagEffect(tp,id)>0 then
		-- 重新设置直到连锁结束为止的连锁限制，使对方不能发动效果。
		Duel.SetChainLimitTillChainEnd(s.efun)
	end
	-- 重置回合标识，避免影响后续连锁。
	Duel.ResetFlagEffect(tp,id)
end
-- 重置标识并解除监听效果，保证限制只在对应连锁内生效。
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	-- 清除记录本次封锁的标识效果。
	Duel.ResetFlagEffect(tp,id)
	e:Reset()
end
