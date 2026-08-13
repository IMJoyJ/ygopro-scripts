--最後の希望
-- 效果：
-- 这个卡名在规则上也当作「银河眼」卡使用。这个卡名的卡在1回合只能发动1张。
-- ①：把基本分支付一半，以自己墓地2只怪兽为对象才能发动。那2只怪兽效果无效特殊召唤，只用那2只为素材把1只「No.」超量怪兽超量召唤。这张卡的发动后，直到回合结束时自己除这个效果的超量召唤以外只能有1次从额外卡组把怪兽特殊召唤。
local s,id,o=GetID()
-- 定义卡片的初始化效果函数：创建发动效果e1并注册，使『最后的希望』获得其①效果及同名卡1回合1次的发动限制。
function s.initial_effect(c)
	-- 全局启用额外卡组特殊召唤次数限制的计数器系统，用于本卡发动后对从额外卡组特殊召唤次数的限制。
	aux.EnableExtraDeckSummonCountLimit()
	-- 这个卡名的卡在1回合只能发动1张。①：把基本分支付一半，以自己墓地2只怪兽为对象才能发动。那2只怪兽效果无效特殊召唤，只用那2只为素材把1只「No.」超量怪兽超量召唤。这张卡的发动后，直到回合结束时自己除这个效果的超量召唤以外只能有1次从额外卡组把怪兽特殊召唤。
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
-- 定义发动代价函数：支付基本分一半作为发动代价。chk==0时表示可支付条件确认，直接返回true。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付当前LP一半（向下取整）作为发动代价。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 墓地怪兽的筛选条件：怪兽必须能够成为本效果的对象且能够被特殊召唤（不检查苏生限制）。
function s.filter(c,e,tp)
	return c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 额外卡组超量怪兽的筛选条件：卡名属于『No.』字段，且能用2只怪兽作为素材进行超量召唤。
function s.xyzfilter(c,mg)
	return c:IsSetCard(0x48) and c:IsXyzSummonable(mg,2,2)
end
-- 素材组合法性判断：额外卡组中存在至少1只『No.』超量怪兽可以用该素材组g作为素材进行超量召唤。
function s.gcheck(g,exg)
	return exg:IsExists(Card.IsXyzSummonable,1,nil,g)
end
-- 发动效果的目标选择与条件判断：从自己墓地选出2只可对象且可特殊召唤的怪兽，并从额外卡组选出能以其为素材的『No.』超量怪兽；在chk==0时确认发动条件是否满足。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己墓地中满足s.filter（能成为对象且可特殊召唤）的怪兽集合。
	local mg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 获取额外卡组中满足s.xyzfilter（『No.』字段且可用mg中怪兽超量召唤）的超量怪兽集合。
	local exg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,mg)
	-- 检查己方本回合是否还能进行至少2次特殊召唤（因为本效果需要特殊召唤2只素材怪兽）。
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己主要怪兽区域的可空格数必须大于1，以容纳2只素材怪兽同时特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and exg:GetCount()>0 end
	-- 提示玩家选择要特殊召唤的怪兽卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=mg:SelectSubGroup(tp,s.gcheck,false,2,2,exg)
	-- 将选中的2只墓地怪兽设置为当前连锁的效果对象，使它们与效果建立关联。
	Duel.SetTargetCard(sg)
	-- 设置操作信息：将预计特殊召唤的2只对象怪兽告诉系统，用于后续特殊召唤相关检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,2,0,0)
end
-- 效果处理时的对象再筛选条件：怪兽仍与本效果关联（未因离场而解除关系）且能够被特殊召唤。
function s.filter2(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理函数：先按条件将对象2只怪兽特殊召唤并使其效果无效，再用它们进行『No.』超量怪兽的超量召唤；随后对发动者附加直到回合结束的额外卡组特殊召唤次数限制。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if not Duel.IsPlayerAffectedByEffect(tp,59822133) and Duel.GetLocationCount(tp,LOCATION_MZONE)>=2 then
		-- 从当前连锁的目标卡中筛选出仍然满足s.filter2（仍关联且可特殊召唤）的怪兽。
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(s.filter2,nil,e,tp)
		if g:GetCount()==2 then
			local tc=g:GetFirst()
			while tc do
				-- 以表侧表示将怪兽逐步特殊召唤（作为连锁处理中的一个步骤）。
				Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
				-- 那2只怪兽效果无效特殊召唤。
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
			-- 完成连锁中的特殊召唤步骤，结束SpecialSummonStep过程并统一处理特殊召唤成功。
			Duel.SpecialSummonComplete()
			-- 立即刷新场地信息，确保新特殊召唤的怪兽状态被系统正确更新。
			Duel.AdjustAll()
			if g:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)==2 then
				-- 根据已成功特殊召唤的2只怪兽（仍位于怪兽区域）检索额外卡组中可用它们超量召唤的『No.』超量怪兽。
				local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,g)
				if xyzg:GetCount()>0 then
					-- 提示玩家选择要超量召唤的『No.』超量怪兽。
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
					local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
					xyz:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1)
					-- 将玩家选择的那只『No.』超量怪兽以g中的2只怪兽作为素材进行超量召唤。
					Duel.XyzSummon(tp,xyz,g)
				end
			end
		end
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 这张卡的发动后，直到回合结束时自己除这个效果的超量召唤以外只能有1次从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能从额外卡组特殊召唤的限制效果注册给玩家tp，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
	-- 这张卡的发动后，直到回合结束时自己除这个效果的超量召唤以外只能有1次从额外卡组把怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(s.checkop)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册特殊召唤成功时的计数效果，在回合结束前监听并记录双方从额外卡组的特殊召唤次数。
	Duel.RegisterEffect(e2,tp)
	-- 这张卡的发动后，直到回合结束时自己除这个效果的超量召唤以外只能有1次从额外卡组把怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(92345028)
	e3:SetTargetRange(1,0)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册e3自定义限制效果，用于在回合结束前标记并限制自己从额外卡组的特殊召唤次数。
	Duel.RegisterEffect(e3,tp)
end
-- 限制效果的判断函数：被尝试特殊召唤的卡来自额外卡组，且该玩家剩余的额外卡组特殊召唤次数已为0时，禁止特殊召唤。
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	-- 返回是否禁止：c位于额外卡组且sump玩家剩余可特殊召唤次数<=0。
	return c:IsLocation(LOCATION_EXTRA) and aux.ExtraDeckSummonCountLimit[sump]<=0
end
-- 特殊召唤计数过滤条件：召唤玩家是目标玩家、之前位置是额外卡组、且该卡没有本卡设置的特殊标记（即不是本卡效果的超量召唤）。
function s.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsPreviousLocation(LOCATION_EXTRA) and c:GetFlagEffect(id)==0
end
-- 特殊召唤成功时的计数处理：对己方和对方的额外卡组特殊召唤进行分别计数，若触发计数条件则对应玩家的剩余次数减1。
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.cfilter,1,nil,tp) then
		-- 将tp玩家的额外卡组特殊召唤剩余次数减1。
		aux.ExtraDeckSummonCountLimit[tp]=aux.ExtraDeckSummonCountLimit[tp]-1
	end
	if eg:IsExists(s.cfilter,1,nil,1-tp) then
		-- 将对方玩家（1-tp）的额外卡组特殊召唤剩余次数减1。
		aux.ExtraDeckSummonCountLimit[1-tp]=aux.ExtraDeckSummonCountLimit[1-tp]-1
	end
end
