--ゴーティス・コスモス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：除外状态的鱼族怪兽数量的以下效果各适用。
-- ●1只以上：这个回合，自己的鱼族怪兽不会被战斗破坏。
-- ●4只以上：这个回合，自己场上的鱼族怪兽的效果的发动以及那些发动的效果不会被无效化。
-- ●8只以上：从额外卡组把1只鱼族同调怪兽当作同调召唤作特殊召唤。
local s,id,o=GetID()
-- 注册卡牌效果，设置为自由连锁发动，可以特殊召唤，限制发动次数为1次
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断除外区的鱼族怪兽是否正面表示
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH)
end
-- 判断是否满足发动条件，检查除外区鱼族怪兽数量是否大于0且小于8时，需要满足必须有同调素材的条件
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 统计除外区鱼族怪兽数量
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if chk==0 then return ct>0
		-- 当除外区鱼族怪兽数量小于8时，需要检查是否有同调素材
		and (ct<8 or aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
			-- 当除外区鱼族怪兽数量小于8时，需要检查额外卡组是否存在符合条件的鱼族同调怪兽
			and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp)) end
	if ct>=8 then
		-- 设置操作信息，提示将要特殊召唤1只鱼族同调怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	end
end
-- 过滤函数，用于筛选额外卡组中可以特殊召唤的鱼族同调怪兽
function s.filter(c,e,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_FISH)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		-- 检查额外卡组中是否有足够的召唤位置
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 发动效果，根据除外区鱼族怪兽数量分别施加不同效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 统计除外区鱼族怪兽数量
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if ct>0 then
		-- ①：除外状态的鱼族怪兽数量的以下效果各适用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		-- 设置效果目标为场上的鱼族怪兽
		e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_FISH))
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		-- 将效果注册给玩家
		Duel.RegisterEffect(e1,tp)
		-- 中断当前效果处理
		Duel.BreakEffect()
	end
	if ct>3 then
		-- ●1只以上：这个回合，自己的鱼族怪兽不会被战斗破坏。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_INACTIVATE)
		e2:SetTargetRange(LOCATION_MZONE,0)
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetValue(s.efilter)
		-- 将效果注册给玩家
		Duel.RegisterEffect(e2,tp)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_CANNOT_DISEFFECT)
		-- 将效果注册给玩家
		Duel.RegisterEffect(e3,tp)
		-- 中断当前效果处理
		Duel.BreakEffect()
	end
	-- ●4只以上：这个回合，自己场上的鱼族怪兽的效果的发动以及那些发动的效果不会被无效化。
	if ct>7 and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- ●8只以上：从额外卡组把1只鱼族同调怪兽当作同调召唤作特殊召唤。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择符合条件的鱼族同调怪兽
		local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
		tc:SetMaterial(nil)
		-- 将选中的鱼族同调怪兽特殊召唤
		if Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
			tc:CompleteProcedure()
		end
	end
end
-- 效果过滤函数，用于判断是否为鱼族怪兽发动的效果
function s.efilter(e,ct)
	local p=e:GetHandlerPlayer()
	-- 获取当前连锁的信息，包括触发效果、玩家和位置
	local te,tp,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	return p==tp and te:IsActiveType(TYPE_MONSTER) and te:GetHandler():IsRace(RACE_FISH) and loc&LOCATION_MZONE>0
end
