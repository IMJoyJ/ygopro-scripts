--ファイナル・ギアス
-- 效果：
-- ①：原本等级是7星以上的怪兽从自己以及对方的场上各有1只以上被送去墓地的回合才能发动。双方墓地的怪兽全部除外。那之后，可以把这个效果除外的怪兽之内等级最高的1只魔法师族怪兽在自己场上特殊召唤。
function c16832845.initial_effect(c)
	-- ①：原本等级是7星以上的怪兽从自己以及对方的场上各有1只以上被送去墓地的回合才能发动。双方墓地的怪兽全部除外。那之后，可以把这个效果除外的怪兽之内等级最高的1只魔法师族怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMING_TOGRAVE)
	e1:SetCondition(c16832845.condition)
	e1:SetTarget(c16832845.target)
	e1:SetOperation(c16832845.activate)
	c:RegisterEffect(e1)
	if not c16832845.global_check then
		c16832845.global_check=true
		c16832845[0]=false
		c16832845[1]=false
		-- 双方墓地的怪兽全部除外。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(c16832845.checkop)
		-- 注册效果ge1，使其在场上的怪兽被送去墓地时触发检查。
		Duel.RegisterEffect(ge1,0)
		-- 注册效果ge2，使其在抽卡阶段开始时触发清空标记。
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(c16832845.clear)
		-- 注册效果ge2，使其在场上的怪兽被送去墓地时触发检查。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 当怪兽被送去墓地时，检查其是否为7星以上且来自怪兽区域，若是则标记对应玩家。
function c16832845.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:GetOriginalLevel()>=7 and tc:IsPreviousLocation(LOCATION_MZONE) then
			c16832845[tc:GetPreviousControler()]=true
		end
		tc=eg:GetNext()
	end
end
-- 在抽卡阶段开始时，将两个玩家的标记清空。
function c16832845.clear(e,tp,eg,ep,ev,re,r,rp)
	c16832845[0]=false
	c16832845[1]=false
end
-- 判断是否满足发动条件，即双方均有7星以上怪兽被送去墓地。
function c16832845.condition(e,tp,eg,ep,ev,re,r,rp)
	return c16832845[0] and c16832845[1]
end
-- 定义过滤函数，用于筛选墓地中的怪兽。
function c16832845.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 设置连锁处理信息，确定要除外的墓地怪兽。
function c16832845.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，即墓地存在至少1张怪兽卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c16832845.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 获取满足条件的墓地怪兽组。
	local g=Duel.GetMatchingGroup(c16832845.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	-- 设置操作信息，表示将要除外这些怪兽。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 定义过滤函数，用于筛选除外区中的魔法师族怪兽。
function c16832845.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsLocation(LOCATION_REMOVED) and c:GetLevel()>0
end
-- 主效果处理函数，执行除外和特殊召唤操作。
function c16832845.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的墓地怪兽组。
	local g=Duel.GetMatchingGroup(c16832845.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	-- 将墓地中的怪兽除外。
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
		-- 获取实际被除外的怪兽中符合特殊召唤条件的魔法师族怪兽。
		local og=Duel.GetOperatedGroup():Filter(c16832845.spfilter,nil,e,tp)
		-- 判断是否有符合条件的魔法师族怪兽，并询问玩家是否发动特殊召唤。
		if og:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(16832845,0)) then  --"是否把魔法师族怪兽在自己场上特殊召唤？"
			-- 中断当前效果处理，使后续效果视为不同时处理。
			Duel.BreakEffect()
			local sg=og:GetMaxGroup(Card.GetLevel)
			if sg:GetCount()>1 then
				-- 提示玩家选择要特殊召唤的魔法师族怪兽。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				sg=sg:Select(tp,1,1,nil)
			end
			-- 将符合条件的魔法师族怪兽特殊召唤到场上。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
