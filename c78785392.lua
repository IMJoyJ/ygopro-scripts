--花合わせ
-- 效果：
-- 「花合」在1回合只能发动1张，这张卡发动的回合，自己不是「花札卫」怪兽不能召唤·特殊召唤。
-- ①：从卡组把4只攻击力100的「花札卫」怪兽攻击表示特殊召唤（同名卡最多1张）。这个效果特殊召唤的怪兽的效果无效化，不能为上级召唤而解放。
function c78785392.initial_effect(c)
	-- 「花合」在1回合只能发动1张，这张卡发动的回合，自己不是「花札卫」怪兽不能召唤·特殊召唤。①：从卡组把4只攻击力100的「花札卫」怪兽攻击表示特殊召唤（同名卡最多1张）。这个效果特殊召唤的怪兽的效果无效化，不能为上级召唤而解放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,78785392+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c78785392.cost)
	e1:SetTarget(c78785392.target)
	e1:SetOperation(c78785392.activate)
	c:RegisterEffect(e1)
	-- 注册用于检测本回合是否进行过「花札卫」怪兽以外的通常召唤的自定义计数器。
	Duel.AddCustomActivityCounter(78785392,ACTIVITY_SUMMON,c78785392.counterfilter)
	-- 注册用于检测本回合是否进行过「花札卫」怪兽以外的特殊召唤的自定义计数器。
	Duel.AddCustomActivityCounter(78785392,ACTIVITY_SPSUMMON,c78785392.counterfilter)
end
-- 计数器过滤函数，用于判定召唤·特殊召唤的怪兽是否为「花札卫」怪兽。
function c78785392.counterfilter(c)
	return c:IsSetCard(0xe6)
end
-- 发动代价（Cost）判定与执行函数，检查本回合发动前是否只召唤·特殊召唤过「花札卫」怪兽。
function c78785392.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合发动前是否未进行过「花札卫」怪兽以外的通常召唤。
	if chk==0 then return Duel.GetCustomActivityCount(78785392,tp,ACTIVITY_SUMMON)==0
		-- 检查本回合发动前是否未进行过「花札卫」怪兽以外的特殊召唤。
		and Duel.GetCustomActivityCount(78785392,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡发动的回合，自己不是「花札卫」怪兽不能召唤·特殊召唤。①：从卡组把4只攻击力100的「花札卫」怪兽攻击表示特殊召唤（同名卡最多1张）。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c78785392.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册不能召唤「花札卫」以外怪兽的限制效果。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	-- 给玩家注册不能特殊召唤「花札卫」以外怪兽的限制效果。
	Duel.RegisterEffect(e2,tp)
end
-- 限制召唤·特殊召唤的怪兽过滤函数，判定是否为非「花札卫」怪兽。
function c78785392.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0xe6)
end
-- 过滤卡组中攻击力100且可以攻击表示特殊召唤的「花札卫」怪兽。
function c78785392.filter(c,e,tp)
	return c:IsAttack(100) and c:IsSetCard(0xe6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果发动时的目标选择与合法性检测函数。
function c78785392.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上的怪兽区域空位数是否大于3（至少需要4个空位）。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>3
		-- 检查卡组中是否存在至少4种卡名不同的满足条件的「花札卫」怪兽。
		and Duel.GetMatchingGroup(c78785392.filter,tp,LOCATION_DECK,0,nil,e,tp):GetClassCount(Card.GetCode)>3 end
	-- 设置特殊召唤的操作信息，声明将从卡组特殊召唤4只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,4,tp,LOCATION_DECK)
end
-- 效果处理（Resolution）函数，执行从卡组特殊召唤4只不同名「花札卫」怪兽并施加限制。
function c78785392.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前怪兽区域空位数与4的较小值，确定最大可特殊召唤数量。
	local ct=math.min(4,(Duel.GetLocationCount(tp,LOCATION_MZONE)))
	-- 获取卡组中所有满足条件的「花札卫」怪兽。
	local g=Duel.GetMatchingGroup(c78785392.filter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and ct>3 and g:GetClassCount(Card.GetCode)>3 then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 设置组选卡附加检查函数，确保选出的卡片卡名各不相同。
		aux.GCheckAdditional=aux.dncheck
		-- 让玩家从满足条件的怪兽中选择4张卡名不同的卡。
		local g1=g:SelectSubGroup(tp,aux.TRUE,false,4,4)
		-- 重置组选卡附加检查函数。
		aux.GCheckAdditional=nil
		local tc=g1:GetFirst()
		while tc do
			-- 尝试将选出的怪兽以表侧攻击表示特殊召唤到场上。
			if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
				-- 这个效果特殊召唤的怪兽的效果无效化
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1,true)
				-- 这个效果特殊召唤的怪兽的效果无效化
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e2,true)
				-- 不能为上级召唤而解放。
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
				e3:SetCode(EFFECT_UNRELEASABLE_SUM)
				e3:SetRange(LOCATION_MZONE)
				e3:SetValue(1)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e3,true)
			end
			tc=g1:GetNext()
		end
		-- 完成特殊召唤的流程，刷新场上状态。
		Duel.SpecialSummonComplete()
	end
end
