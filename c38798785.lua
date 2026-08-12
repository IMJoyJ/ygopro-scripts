--炎王の結襲
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的手卡·卡组·墓地各把1只兽族·兽战士族·鸟兽族的炎属性怪兽特殊召唤（相同种族最多1只）。这个效果特殊召唤的怪兽的效果无效化，结束阶段破坏。
-- ②：把墓地的这张卡除外才能发动。这个回合，在自己的「炎王」怪兽的召唤·特殊召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
local s,id,o=GetID()
-- 注册卡牌的两个效果：①效果为通常魔法卡发动效果，②效果为墓地发动的诱发即时效果
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
	-- 效果发动时需要将此卡从墓地除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数：满足条件的怪兽必须为炎属性、兽族/兽战士族/鸟兽族、可以特殊召唤，并且在手牌中存在满足条件的其他怪兽
function s.filter0(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查手牌中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_HAND,0,1,nil,e,tp,c:GetRace())
end
-- 过滤函数：满足条件的怪兽必须为炎属性、兽族/兽战士族/鸟兽族、种族与已选怪兽不同、可以特殊召唤，并且在卡组中存在满足条件的其他怪兽
function s.filter1(c,e,tp,race1)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)
		and not c:IsRace(race1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetRace(),race1)
end
-- 过滤函数：满足条件的怪兽必须为炎属性、兽族/兽战士族/鸟兽族、种族与已选怪兽不同、可以特殊召唤
function s.filter2(c,e,tp,race1,race2)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)
		and not c:IsRace(race1) and not c:IsRace(race2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的检查条件：未受青眼精灵龙影响、场上空位大于等于3、墓地存在满足条件的怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查场上空位是否大于等于3
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		-- 检查墓地是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.filter0,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息：准备特殊召唤3只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果发动时的处理流程：检查是否受青眼精灵龙影响、检查场上空位、检索满足条件的怪兽并特殊召唤
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查场上空位是否小于3
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<3 then return end
	-- 获取满足条件的墓地怪兽组
	local g1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter0),tp,LOCATION_GRAVE,0,nil,e,tp)
	if g1:GetCount()==0 then return end
	-- 提示玩家选择要特殊召唤的墓地怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地满足条件的怪兽
	local sg1=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter0),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc1=sg1:GetFirst()
	-- 提示玩家选择要特殊召唤的手牌怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择手牌满足条件的怪兽
	local sg2=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_HAND,0,1,1,nil,e,tp,tc1:GetRace())
	local tc2=sg2:GetFirst()
	sg1:Merge(sg2)
	-- 提示玩家选择要特殊召唤的卡组怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择卡组满足条件的怪兽
	local sg3=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc1:GetRace(),tc2:GetRace())
	sg1:Merge(sg3)
	local fid=c:GetFieldID()
	local tc=sg1:GetFirst()
	while tc do
		-- 特殊召唤一张怪兽
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 特殊召唤的怪兽效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 特殊召唤的怪兽效果无效化并设置结束阶段破坏
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
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
	sg1:KeepAlive()
	-- 注册结束阶段破坏效果
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCountLimit(1)
	e3:SetLabel(fid)
	e3:SetLabelObject(sg1)
	e3:SetCondition(s.descon)
	e3:SetOperation(s.desop)
	-- 注册结束阶段破坏效果
	Duel.RegisterEffect(e3,tp)
end
-- 过滤函数：判断怪兽是否为本次特殊召唤的怪兽
function s.desfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
-- 结束阶段破坏效果的触发条件
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(s.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 结束阶段破坏效果的处理流程
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(s.desfilter,nil,e:GetLabel())
	-- 将满足条件的怪兽破坏
	Duel.Destroy(tg,REASON_EFFECT)
end
-- ②效果发动时注册连锁效果：限制对方在召唤/特殊召唤成功时发动效果
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 注册召唤成功时的连锁效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.sumcon)
	e1:SetOperation(s.sumsuc)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册召唤成功时的连锁效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	-- 注册特殊召唤成功时的连锁效果
	Duel.RegisterEffect(e2,tp)
	-- 注册连锁结束时的连锁效果
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_END)
	e3:SetOperation(s.limop2)
	-- 注册连锁结束时的连锁效果
	Duel.RegisterEffect(e3,tp)
end
-- 过滤函数：判断怪兽是否为炎王族
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x81)
end
-- 召唤成功时的处理流程：设置连锁限制
function s.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 当前连锁为0时设置连锁限制
	if Duel.GetCurrentChain()==0 then
		-- 设置连锁限制
		Duel.SetChainLimitTillChainEnd(s.efun)
	-- 当前连锁为1时设置连锁限制
	elseif Duel.GetCurrentChain()==1 then
		-- 注册标记效果
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		-- 注册连锁中和打断效果的处理
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(s.resetop)
		-- 注册连锁中效果
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 注册打断效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 召唤成功时的触发条件
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil)
end
-- 连锁限制函数
function s.efun(e,ep,tp)
	return ep==tp
end
-- 连锁结束时的处理流程
function s.limop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否注册标记效果
	if Duel.GetFlagEffect(tp,id)>0 then
		-- 设置连锁限制
		Duel.SetChainLimitTillChainEnd(s.efun)
	end
	-- 重置标记效果
	Duel.ResetFlagEffect(tp,id)
end
-- 重置标记效果并清除效果
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	-- 重置标记效果
	Duel.ResetFlagEffect(tp,id)
	e:Reset()
end
