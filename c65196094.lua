--バラエティ・アウト
-- 效果：
-- 让自己场上表侧表示存在的1只同调怪兽回到额外卡组发动。直到等级合计和那只同调怪兽的等级相同，选择自己墓地存在的调整在自己场上特殊召唤。这张卡发动的回合，自己不能同调召唤。
function c65196094.initial_effect(c)
	-- 让自己场上表侧表示存在的1只同调怪兽回到额外卡组发动。直到等级合计和那只同调怪兽的等级相同，选择自己墓地存在的调整在自己场上特殊召唤。这张卡发动的回合，自己不能同调召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c65196094.cost)
	e1:SetTarget(c65196094.target)
	e1:SetOperation(c65196094.activate)
	c:RegisterEffect(e1)
	-- 注册一个自定义活动计数器，用于检测本回合玩家特殊召唤过的怪兽
	Duel.AddCustomActivityCounter(65196094,ACTIVITY_SPSUMMON,c65196094.counterfilter)
end
-- 计数器的过滤函数，用于筛选非同调召唤的特殊召唤
function c65196094.counterfilter(c)
	return not c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果发动成本与誓约限制处理函数
function c65196094.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 在发动前检测本回合是否进行过同调召唤
	if chk==0 then return Duel.GetCustomActivityCount(65196094,tp,ACTIVITY_SPSUMMON)==0 end
	-- 让自己场上表侧表示存在的1只同调怪兽回到额外卡组发动。直到等级合计和那只同调怪兽的等级相同，选择自己墓地存在的调整在自己场上特殊召唤。这张卡发动的回合，自己不能同调召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c65196094.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能同调召唤的玩家效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤类型的过滤函数，禁止进行同调召唤
function c65196094.splimit(e,c,tp,sumtp,sumpos)
	return bit.band(sumtp,SUMMON_TYPE_SYNCHRO)==SUMMON_TYPE_SYNCHRO
end
-- 过滤作为Cost回到额外卡组的同调怪兽，要求其等级能被墓地的调整怪兽等级合计组合达成
function c65196094.cfilter(c,e,tp,g,maxc)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsAbleToExtraAsCost()
		and g:CheckWithSumEqual(Card.GetLevel,c:GetLevel(),1,maxc)
end
-- 过滤墓地中可以作为效果对象且可以特殊召唤的调整怪兽
function c65196094.spfilter(c,e,tp)
	return c:IsType(TYPE_TUNER) and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与合法性检测函数
function c65196094.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local maxc=ft+1
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if maxc>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then maxc=1 end
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		if maxc<=0 then return end
		-- 获取自己墓地中所有满足条件的调整怪兽
		local spg=Duel.GetMatchingGroup(c65196094.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
		-- 检查自己场上是否存在可以作为Cost回到额外卡组的同调怪兽
		return Duel.IsExistingMatchingCard(c65196094.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,spg,maxc)
	end
	e:SetLabel(0)
	-- 再次获取自己墓地中所有满足条件的调整怪兽
	local spg=Duel.GetMatchingGroup(c65196094.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 提示玩家选择要返回额外卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择1只自己场上的同调怪兽
	local cg=Duel.SelectMatchingCard(tp,c65196094.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,spg,maxc)
	local lv=cg:GetFirst():GetLevel()
	-- 将选中的同调怪兽作为Cost送回额外卡组
	Duel.SendtoDeck(cg,nil,SEQ_DECKTOP,REASON_COST)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=spg:SelectWithSumEqual(tp,Card.GetLevel,lv,1,maxc)
	-- 将选中的调整怪兽群注册为效果处理的对象
	Duel.SetTargetCard(sg)
	-- 设置特殊召唤的操作信息，包含特殊召唤的卡片组和数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,sg:GetCount(),0,0)
end
-- 效果处理函数
function c65196094.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在场上且仍与此效果相关的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local ct=g:GetCount()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ct==0 or (ct>1 and Duel.IsPlayerAffectedByEffect(tp,59822133))
		-- 如果要特殊召唤的怪兽数量超过当前可用怪兽区域数量，则不进行特殊召唤
		or ct>Duel.GetLocationCount(tp,LOCATION_MZONE) then return end
	-- 将目标怪兽以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
