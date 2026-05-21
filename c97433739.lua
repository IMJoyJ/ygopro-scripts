--未来への思い
-- 效果：
-- 选择自己墓地3只等级不同的怪兽才能发动。选择的3只怪兽特殊召唤。这个效果特殊召唤的怪兽的攻击力变成0，效果无效化。那之后，自己没有进行超量召唤的场合，这个回合的结束阶段时自己失去4000基本分。此外，这张卡发动的回合，自己不能作超量召唤以外的特殊召唤。
function c97433739.initial_effect(c)
	-- 选择自己墓地3只等级不同的怪兽才能发动。选择的3只怪兽特殊召唤。这个效果特殊召唤的怪兽的攻击力变成0，效果无效化。那之后，自己没有进行超量召唤的场合，这个回合的结束阶段时自己失去4000基本分。此外，这张卡发动的回合，自己不能作超量召唤以外的特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c97433739.cost)
	e1:SetTarget(c97433739.target)
	e1:SetOperation(c97433739.operation)
	c:RegisterEffect(e1)
	-- 注册一个自定义活动计数器，用于记录本回合玩家进行非超量召唤的特殊召唤次数
	Duel.AddCustomActivityCounter(97433739,ACTIVITY_SPSUMMON,c97433739.counterfilter)
end
-- 过滤函数，用于判断特殊召唤的怪兽是否为超量怪兽
function c97433739.counterfilter(c)
	return c:IsSummonType(SUMMON_TYPE_XYZ)
end
-- 发动代价函数，检查本回合是否未进行过非超量召唤的特殊召唤，并注册限制本回合只能进行超量召唤以外的特殊召唤的效果
function c97433739.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动前检测，确保本回合在此卡发动前没有进行过超量召唤以外的特殊召唤
	if chk==0 then return Duel.GetCustomActivityCount(97433739,tp,ACTIVITY_SPSUMMON)==0 end
	-- 此外，这张卡发动的回合，自己不能作超量召唤以外的特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	e1:SetTarget(c97433739.sumlimit)
	-- 给发动玩家注册不能进行超量召唤以外的特殊召唤的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的过滤函数，阻止非超量召唤的特殊召唤（此卡自身的效果除外）
function c97433739.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return sumtype~=SUMMON_TYPE_XYZ and e:GetLabelObject()~=se
end
-- 墓地怪兽的过滤条件：等级在1以上、可以被特殊召唤、且可以成为效果对象
function c97433739.spfilter(c,e,tp)
	return c:IsLevelAbove(1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsCanBeEffectTarget(e)
end
-- 效果发动时的目标选择函数，进行合法性检测并选择墓地3只等级不同的怪兽作为对象
function c97433739.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己墓地中所有满足特殊召唤过滤条件的怪兽
	local g=Duel.GetMatchingGroup(c97433739.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检测自己场上的怪兽区域空位数是否大于2（因为需要特殊召唤3只怪兽）
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		and g:GetClassCount(Card.GetLevel)>=3 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从满足条件的怪兽中选择3只等级互不相同的怪兽
	local g1=g:SelectSubGroup(tp,aux.dlvcheck,false,3,3)
	-- 将选择的3只怪兽设为当前连锁的效果处理对象
	Duel.SetTargetCard(g1)
	-- 设置连锁的操作信息，表明此效果包含特殊召唤这3只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,3,0,0)
end
-- 效果处理函数，执行特殊召唤、攻击力变0、效果无效化，并注册结束阶段失去基本分的检测效果
function c97433739.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 获取当前连锁中仍与此卡效果相关的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()~=3 then return end
	-- 如果自己场上的怪兽区域空位数小于要特殊召唤的怪兽数量，则不进行处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<g:GetCount() then return end
	local c=e:GetHandler()
	local tc=g:GetFirst()
	while tc do
		-- 尝试将目标怪兽以表侧表示特殊召唤到自己场上（分步处理）
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 这个效果特殊召唤的怪兽的攻击力变成0
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 效果无效化
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			-- 效果无效化
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			e3:SetValue(RESET_TURN_SET)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
		tc=g:GetNext()
	end
	-- 完成所有分步特殊召唤怪兽的最终确定处理
	Duel.SpecialSummonComplete()
	-- 那之后，自己没有进行超量召唤的场合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(c97433739.checkop2)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册一个全局事件监听效果，用于检测玩家在本回合之后是否成功进行了超量召唤
	Duel.RegisterEffect(e1,tp)
	-- 这个回合的结束阶段时自己失去4000基本分
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetOperation(c97433739.lpop)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册一个在结束阶段触发的效果，用于扣除玩家4000基本分（若未进行超量召唤，该效果不会被重置）
	Duel.RegisterEffect(e2,tp)
	e1:SetLabelObject(e2)
end
-- 超量召唤检测函数，一旦玩家成功进行超量召唤，就重置（取消）结束阶段扣除基本分的效果
function c97433739.checkop2(e,tp,eg,ep,ev,re,r,rp)
	if eg:GetFirst():IsSummonType(SUMMON_TYPE_XYZ) then
		e:GetLabelObject():Reset()
		e:Reset()
	end
end
-- 结束阶段扣除基本分的效果处理函数
function c97433739.lpop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家当前的生命值（LP）
	local lp=Duel.GetLP(tp)
	-- 将玩家的生命值减少4000点
	Duel.SetLP(tp,lp-4000)
end
