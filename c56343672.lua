--レスキューフェレット
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：让场上的这张卡回到持有者卡组才能发动。等级合计直到变成6星为止从卡组选「救援雪貂」以外的怪兽任意数量在作为连接怪兽所连接区的自己场上特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段破坏。
function c56343672.initial_effect(c)
	-- ①：让场上的这张卡回到持有者卡组才能发动。等级合计直到变成6星为止从卡组选「救援雪貂」以外的怪兽任意数量在作为连接怪兽所连接区的自己场上特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56343672,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,56343672)
	e1:SetCost(c56343672.spcost)
	e1:SetTarget(c56343672.sptg)
	e1:SetOperation(c56343672.spop)
	c:RegisterEffect(e1)
end
-- 定义发动代价函数：检测自身是否能回到卡组，并执行回到卡组的操作
function c56343672.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
	-- 作为发动代价，将场上的这张卡送回持有者的卡组并洗牌
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 定义过滤函数：过滤卡组中等级大于0、卡名非「救援雪貂」且可以特殊召唤的怪兽
function c56343672.spfilter(c,e,tp)
	return c:GetLevel()>0 and not c:IsCode(56343672) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义发动条件与效果目标函数：检测自己场上连接区可用怪兽区域数量，并确认卡组中是否存在等级合计为6的怪兽组合
function c56343672.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取当前玩家场上所有连接怪兽所连接的区域
		local zone=Duel.GetLinkedZone(tp)
		-- 计算当前玩家场上连接区内可用的怪兽区域数量
		local ct=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)
		local seq=e:GetHandler():GetSequence()
		if seq<5 and bit.extract(zone,seq)~=0 then ct=ct+1 end
		if ct<=0 then return false end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
		-- 获取卡组中所有满足过滤条件的怪兽
		local g=Duel.GetMatchingGroup(c56343672.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		return g:CheckWithSumEqual(Card.GetLevel,6,1,ct)
	end
	-- 设置特殊召唤的操作信息，表示该效果会从卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义效果处理函数：从卡组选择等级合计为6的怪兽，在连接区特殊召唤，并使其效果无效化，注册结束阶段破坏的效果
function c56343672.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前玩家场上所有连接怪兽所连接的区域
	local zone=Duel.GetLinkedZone(tp)
	-- 计算当前玩家场上连接区内可用的怪兽区域数量
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)
	if ct<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 获取卡组中所有满足过滤条件的怪兽
	local g=Duel.GetMatchingGroup(c56343672.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:CheckWithSumEqual(Card.GetLevel,6,1,ct) then
		local fid=c:GetFieldID()
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:SelectWithSumEqual(tp,Card.GetLevel,6,1,ct)
		local tc=sg:GetFirst()
		while tc do
			-- 将选中的怪兽以表侧表示特殊召唤到连接区（单步处理）
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP,zone)
			-- 这个效果特殊召唤的怪兽的效果无效化
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 这个效果特殊召唤的怪兽的效果无效化
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			tc:RegisterFlagEffect(56343672,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			tc=sg:GetNext()
		end
		-- 完成所有单步特殊召唤的处理
		Duel.SpecialSummonComplete()
		sg:KeepAlive()
		-- 结束阶段破坏。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetCountLimit(1)
		e3:SetLabel(fid)
		e3:SetLabelObject(sg)
		e3:SetCondition(c56343672.descon)
		e3:SetOperation(c56343672.desop)
		-- 注册全局延迟效果，用于在结束阶段破坏特殊召唤的怪兽
		Duel.RegisterEffect(e3,tp)
	end
end
-- 定义过滤函数：过滤出带有当前特殊召唤标记（fid）的怪兽
function c56343672.desfilter(c,fid)
	return c:GetFlagEffectLabel(56343672)==fid
end
-- 定义结束阶段破坏效果的发动条件：检查被特殊召唤的怪兽是否还存在于场上，若不存在则重置该效果
function c56343672.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c56343672.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 定义结束阶段破坏效果的处理：过滤并破坏所有依然存在于场上的被特殊召唤的怪兽
function c56343672.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c56343672.desfilter,nil,e:GetLabel())
	-- 因效果将目标怪兽破坏
	Duel.Destroy(tg,REASON_EFFECT)
end
