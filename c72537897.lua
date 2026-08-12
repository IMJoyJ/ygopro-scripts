--魔獣の懐柔
-- 效果：
-- ①：自己场上没有怪兽存在的场合才能发动。把3只卡名不同的2星以下的兽族效果怪兽从卡组特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段破坏。这张卡的发动后，直到回合结束时自己不是兽族怪兽不能特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合才能发动。把3只卡名不同的2星以下的兽族效果怪兽从卡组特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：自己场上没有怪兽存在
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 过滤卡组中满足条件的怪兽：2星以下的兽族效果怪兽，且可以特殊召唤
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_BEAST) and c:IsLevelBelow(2) and c:IsType(TYPE_EFFECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标选择与合法性检测（包括检测场上空格、卡组中是否有3种不同卡名的怪兽，以及精灵龙等特殊召唤限制）
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取卡组中所有满足条件的怪兽
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 检查自己场上是否有3个以上的怪兽区域空位，且卡组中满足条件的怪兽卡名种类是否在3种以上
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>2 and g:GetClassCount(Card.GetCode)>=3 end
	-- 设置连锁处理的操作信息：从卡组特殊召唤3只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_DECK)
end
-- 效果处理的核心逻辑：从卡组特殊召唤3只卡名不同的怪兽，并对其进行效果无效化、结束阶段破坏以及后续特殊召唤限制的注册
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时，再次获取卡组中满足条件的怪兽
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上是否有3个以上的怪兽区域空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		and g:GetClassCount(Card.GetCode)>=3 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从满足条件的怪兽中选择3只卡名不同的怪兽
		local sg1=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
		local fid=c:GetFieldID()
		local tc=sg1:GetFirst()
		while tc do
			-- 将选中的怪兽以表侧表示特殊召唤（单步处理）
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
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
			tc=sg1:GetNext()
		end
		sg1:KeepAlive()
		-- 结束阶段破坏。这张卡的发动后，直到回合结束时自己不是兽族怪兽不能特殊召唤。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCountLimit(1)
		e3:SetLabel(fid)
		e3:SetLabelObject(sg1)
		e3:SetCondition(s.descon)
		e3:SetOperation(s.desop)
		-- 注册在结束阶段破坏这些怪兽的全局延迟效果
		Duel.RegisterEffect(e3,tp)
		-- 完成特殊召唤的最终处理
		Duel.SpecialSummonComplete()
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时自己不是兽族怪兽不能特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册玩家在回合结束前不能特殊召唤兽族以外怪兽的限制效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制特殊召唤的过滤函数：非兽族怪兽不能特殊召唤
function s.splimit(e,c)
	return c:GetRace()~=RACE_BEAST
end
-- 过滤出带有当前效果标识（fid）的怪兽，用于结束阶段的破坏
function s.desfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
-- 结束阶段破坏效果的发动条件：检查被特殊召唤的怪兽是否还存在于场上，若不存在则重置该效果
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(s.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 结束阶段破坏效果的具体执行：将依然存在于场上的对应怪兽破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 在场上展示该卡片，提示玩家正在处理该卡的效果
	Duel.Hint(HINT_CARD,0,id)
	local g=e:GetLabelObject()
	local tg=g:Filter(s.desfilter,nil,e:GetLabel())
	-- 因效果将目标怪兽破坏
	Duel.Destroy(tg,REASON_EFFECT)
end
