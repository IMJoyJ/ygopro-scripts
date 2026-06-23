--トゥーン・フリップ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「卡通世界」存在的场合才能发动。从卡组把3只卡名不同的卡通怪兽给对方观看，对方从那之中随机选1只。那1只怪兽无视召唤条件在自己场上特殊召唤。剩下的怪兽回到卡组。
function c27699122.initial_effect(c)
	-- 注册该卡牌与「卡通世界」的关联，用于效果判定
	aux.AddCodeList(c,15259703)
	-- ①：自己场上有「卡通世界」存在的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,27699122+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c27699122.con)
	e1:SetTarget(c27699122.tg)
	e1:SetOperation(c27699122.op)
	c:RegisterEffect(e1)
end
-- 检查场上是否存在表侧表示的「卡通世界」
function c27699122.ffilter(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 判断发动条件：确认场上是否存在「卡通世界」
function c27699122.con(e,tp,eg,ep,ev,re,r,rp)
	-- 判断发动条件：确认场上是否存在「卡通世界」
	return Duel.IsExistingMatchingCard(c27699122.ffilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤函数：筛选可以特殊召唤的卡通怪兽
function c27699122.filter(c,e,tp)
	return c:IsType(TYPE_TOON) and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP)
end
-- 设置效果的发动条件和目标：检查卡组中是否存在3只不同卡名的卡通怪兽且自己场上存在空位
function c27699122.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取满足条件的卡组中的卡通怪兽
		local dg=Duel.GetMatchingGroup(c27699122.filter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 判断是否满足发动条件：卡组中至少有3张不同卡名的卡通怪兽且自己场上存在空位
		return dg:GetClassCount(Card.GetCode)>=3 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
	-- 设置连锁操作信息：准备特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：从卡组选择3只不同卡名的卡通怪兽，由对方选择1只并特殊召唤
function c27699122.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的卡组中的卡通怪兽
	local g=Duel.GetMatchingGroup(c27699122.filter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 判断是否满足处理条件：自己场上没有空位或卡组中不同卡名的卡通怪兽少于3只
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or g:GetClassCount(Card.GetCode)<3 then return end
	-- 提示玩家选择要确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从满足条件的卡组中选择3张不同卡名的卡片
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
	if sg then
		-- 向对方确认所选的3张卡片
		Duel.ConfirmCards(1-tp,sg)
		local tc=sg:RandomSelect(1-tp,1):GetFirst()
		-- 将对方选择的那张卡片特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
