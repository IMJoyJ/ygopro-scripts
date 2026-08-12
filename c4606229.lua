--最後の希望
-- 效果：
-- 这个卡名在规则上也当作「银河眼」卡使用。这个卡名的卡在1回合只能发动1张。
-- ①：把基本分支付一半，以自己墓地2只怪兽为对象才能发动。那2只怪兽效果无效特殊召唤，只用那2只为素材把1只「No.」超量怪兽超量召唤。这张卡的发动后，直到回合结束时自己除这个效果的超量召唤以外只能有1次从额外卡组把怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，启用额外卡组特殊召唤次数限制并创建主效果
function s.initial_effect(c)
	-- 启用额外卡组特殊召唤次数限制的全局计数机制
	aux.EnableExtraDeckSummonCountLimit()
	-- 创建发动效果，设置为自由连锁、支付费用、选择对象、只能发动一次
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义费用函数，支付当前LP的一半
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付当前玩家当前LP的一半
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 定义墓地怪兽过滤器，用于判断是否可以作为特殊召唤对象
function s.filter(c,e,tp)
	return c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义超量怪兽过滤器，用于判断是否可以使用指定素材进行超量召唤
function s.xyzfilter(c,mg)
	return c:IsSetCard(0x48) and c:IsXyzSummonable(mg,2,2)
end
-- 定义组合检查函数，用于验证选择的墓地怪兽是否能用于超量召唤
function s.gcheck(g,exg)
	return exg:IsExists(Card.IsXyzSummonable,1,nil,g)
end
-- 定义效果目标选择函数，检测是否满足特殊召唤条件
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取玩家墓地中的可特殊召唤怪兽组
	local mg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 获取玩家额外卡组中可超量召唤的No.怪兽组
	local exg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,mg)
	-- 检查玩家是否可以特殊召唤2只怪兽
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查玩家场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and exg:GetCount()>0 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=mg:SelectSubGroup(tp,s.gcheck,false,2,2,exg)
	-- 设置当前连锁的目标卡片为已选择的墓地怪兽组
	Duel.SetTargetCard(sg)
	-- 设置操作信息，表示将特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,2,0,0)
end
-- 定义用于判断是否可以特殊召唤的过滤器函数
function s.filter2(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果发动处理函数，执行特殊召唤和超量召唤操作并设置后续限制
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if not Duel.IsPlayerAffectedByEffect(tp,59822133) and Duel.GetLocationCount(tp,LOCATION_MZONE)>=2 then
		-- 获取当前连锁的目标卡片组，并筛选出可特殊召唤的怪兽
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(s.filter2,nil,e,tp)
		if g:GetCount()==2 then
			local tc=g:GetFirst()
			while tc do
				-- 将目标怪兽特殊召唤到场上
				Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
				-- 创建使目标怪兽效果无效的效果
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				tc:RegisterEffect(e2)
				tc=g:GetNext()
			end
			-- 完成所有特殊召唤步骤，刷新场地状态
			Duel.SpecialSummonComplete()
			-- 调整所有场上状态
			Duel.AdjustAll()
			if g:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)==2 then
				-- 获取玩家额外卡组中符合超量召唤条件的No.怪兽组
				local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,g)
				if xyzg:GetCount()>0 then
					-- 提示玩家选择要特殊召唤的卡
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
					local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
					xyz:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1)
					-- 执行XYZ召唤操作
					Duel.XyzSummon(tp,xyz,g)
				end
			end
		end
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 创建禁止从额外卡组特殊召唤的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册禁止从额外卡组特殊召唤的效果到玩家场上
	Duel.RegisterEffect(e1,tp)
	-- 创建监听特殊召唤成功的持续效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(s.checkop)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册监听特殊召唤成功的持续效果到玩家场上
	Duel.RegisterEffect(e2,tp)
	-- 创建用于限制额外卡组特殊召唤次数的函数
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(92345028)
	e3:SetTargetRange(1,0)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册第三个效果到玩家场上
	Duel.RegisterEffect(e3,tp)
end
-- 定义限制额外卡组特殊召唤次数的函数
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	-- 返回是否禁止从额外卡组特殊召唤
	return c:IsLocation(LOCATION_EXTRA) and aux.ExtraDeckSummonCountLimit[sump]<=0
end
-- 定义判断是否为来自额外卡组的召唤的过滤器
function s.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsPreviousLocation(LOCATION_EXTRA) and c:GetFlagEffect(id)==0
end
-- 定义处理特殊召唤成功事件的函数，减少额外卡组召唤次数
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.cfilter,1,nil,tp) then
		-- 减少当前玩家的额外卡组特殊召唤次数
		aux.ExtraDeckSummonCountLimit[tp]=aux.ExtraDeckSummonCountLimit[tp]-1
	end
	if eg:IsExists(s.cfilter,1,nil,1-tp) then
		-- 减少对方玩家的额外卡组特殊召唤次数
		aux.ExtraDeckSummonCountLimit[1-tp]=aux.ExtraDeckSummonCountLimit[1-tp]-1
	end
end
