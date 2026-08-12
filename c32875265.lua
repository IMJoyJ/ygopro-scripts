--傀儡葬儀－パペット・パレード
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方场上的怪兽数量比自己场上的怪兽多的场合，把最多有那个相差数量的「机关傀儡」怪兽从卡组特殊召唤（同名卡最多1张）。自己基本分比对方少2000以上的场合，可以再从卡组选1张「升阶魔法」通常魔法卡在自己的魔法与陷阱区域盖放。这张卡的发动后，直到回合结束时自己不是「机关傀儡」怪兽不能特殊召唤。
function c32875265.initial_effect(c)
	-- ①：对方场上的怪兽数量比自己场上的怪兽多的场合，把最多有那个相差数量的「机关傀儡」怪兽从卡组特殊召唤（同名卡最多1张）。自己基本分比对方少2000以上的场合，可以再从卡组选1张「升阶魔法」通常魔法卡在自己的魔法与陷阱区域盖放。这张卡的发动后，直到回合结束时自己不是「机关傀儡」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,32875265+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c32875265.target)
	e1:SetOperation(c32875265.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选可以特殊召唤的「机关傀儡」怪兽
function c32875265.spfilter(c,e,tp)
	return c:IsSetCard(0x1083) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的处理函数，用于判断是否满足发动条件
function c32875265.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断对方场上的怪兽数量比自己场上的怪兽多
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
		-- 判断自己卡组中是否存在满足条件的「机关傀儡」怪兽
		and Duel.IsExistingMatchingCard(c32875265.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理时将要特殊召唤的卡片信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 过滤函数，用于筛选可以盖放的「升阶魔法」魔法卡
function c32875265.setfilter(c)
	return c:IsSetCard(0x95) and c:GetType()==TYPE_SPELL and c:IsSSetable()
end
-- 效果发动时的处理函数，执行效果的具体处理流程
function c32875265.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 计算对方怪兽数量与自己怪兽数量的差值
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)-Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	if ft>0 and ct>0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		ct=math.min(ct,ft)
		-- 获取自己卡组中所有满足条件的「机关傀儡」怪兽
		local g=Duel.GetMatchingGroup(c32875265.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从满足条件的怪兽中选择若干张不重复卡名的怪兽
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ct)
		-- 将选中的怪兽特殊召唤到场上
		if sg and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0
			-- 判断自己基本分比对方少2000以上
			and Duel.GetLP(tp)<=Duel.GetLP(1-tp)-2000
			-- 判断自己卡组中是否存在满足条件的「升阶魔法」魔法卡
			and Duel.IsExistingMatchingCard(c32875265.setfilter,tp,LOCATION_DECK,0,1,nil)
			-- 询问玩家是否盖放「升阶魔法」魔法卡
			and Duel.SelectYesNo(tp,aux.Stringid(32875265,0)) then  --"是否盖放「升阶魔法」魔法卡？"
			-- 中断当前效果处理，使后续处理视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要盖放的魔法卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			-- 从卡组中选择一张满足条件的「升阶魔法」魔法卡
			local tg=Duel.SelectMatchingCard(tp,c32875265.setfilter,tp,LOCATION_DECK,0,1,1,nil)
			-- 将选中的魔法卡盖放到自己场上
			Duel.SSet(tp,tg)
		end
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- ①：对方场上的怪兽数量比自己场上的怪兽多的场合，把最多有那个相差数量的「机关傀儡」怪兽从卡组特殊召唤（同名卡最多1张）。自己基本分比对方少2000以上的场合，可以再从卡组选1张「升阶魔法」通常魔法卡在自己的魔法与陷阱区域盖放。这张卡的发动后，直到回合结束时自己不是「机关傀儡」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c32875265.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到场上，使自己不能特殊召唤非「机关傀儡」怪兽
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的目标，禁止特殊召唤非「机关傀儡」怪兽
function c32875265.splimit(e,c)
	return not c:IsSetCard(0x1083)
end
