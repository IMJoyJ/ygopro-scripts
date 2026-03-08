--オーバー・ザ・レインボー
-- 效果：
-- ①：原本卡名是「究极宝玉神 虹龙」或者「究极宝玉神 虹暗龙」的怪兽在自己场上把效果发动的回合才能发动。从卡组把「宝玉兽」怪兽任意数量特殊召唤（同名卡最多1张）。
function c40854824.initial_effect(c)
	-- 效果原文内容：①：原本卡名是「究极宝玉神 虹龙」或者「究极宝玉神 虹暗龙」的怪兽在自己场上把效果发动的回合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c40854824.condition)
	e1:SetTarget(c40854824.target)
	e1:SetOperation(c40854824.activate)
	c:RegisterEffect(e1)
	-- 设置一个计数器，用于记录玩家在该回合中是否发动过怪兽效果
	Duel.AddCustomActivityCounter(40854824,ACTIVITY_CHAIN,c40854824.chainfilter)
end
-- 过滤函数，用于判断是否为「究极宝玉神 虹龙」或「究极宝玉神 虹暗龙」的怪兽效果
function c40854824.chainfilter(re,tp,cid)
	return not (re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsOriginalCodeRule(79407975,79856792))
end
-- 条件函数，判断该回合是否发动过怪兽效果
function c40854824.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查该玩家在本回合是否发动过怪兽效果
	return Duel.GetCustomActivityCount(40854824,tp,ACTIVITY_CHAIN)~=0
end
-- 过滤函数，用于筛选「宝玉兽」怪兽且可以特殊召唤
function c40854824.filter(c,e,tp)
	return c:IsSetCard(0x1034) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标函数，判断是否满足发动条件
function c40854824.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c40854824.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 发动函数，执行特殊召唤操作
function c40854824.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c40854824.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()==0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从满足条件的怪兽组中选择不重复卡名的怪兽
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ft)
	-- 将选中的怪兽特殊召唤到场上
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end
