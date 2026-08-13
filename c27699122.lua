--トゥーン・フリップ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「卡通世界」存在的场合才能发动。从卡组把3只卡名不同的卡通怪兽给对方观看，对方从那之中随机选1只。那1只怪兽无视召唤条件在自己场上特殊召唤。剩下的怪兽回到卡组。
function c27699122.initial_effect(c)
	-- 将卡通世界（15259703）登记为本卡记载的卡名，用于处理与卡通世界相关的规则判定。
	aux.AddCodeList(c,15259703)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「卡通世界」存在的场合才能发动。从卡组把3只卡名不同的卡通怪兽给对方观看，对方从那之中随机选1只。那1只怪兽无视召唤条件在自己场上特殊召唤。剩下的怪兽回到卡组。
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
-- 判断该卡是否为表侧表示且卡号为15259703（卡通世界）。
function c27699122.ffilter(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 效果发动条件：检查自己场上是否存在表侧表示的「卡通世界」。
function c27699122.con(e,tp,eg,ep,ev,re,r,rp)
	-- 检索自己场上是否存在至少1张表侧表示且卡号为15259703的「卡通世界」。
	return Duel.IsExistingMatchingCard(c27699122.ffilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 筛选条件：卡是卡通怪兽，且能够无视召唤条件以表侧表示特殊召唤。
function c27699122.filter(c,e,tp)
	return c:IsType(TYPE_TOON) and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP)
end
-- 发动时合法检测：卡组中不同卡名的卡通怪兽不少于3只，且自己主要怪兽区有空位；同时登记特殊召唤的操作信息。
function c27699122.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 取得自己卡组中所有满足特殊召唤条件的卡通怪兽的集合。
		local dg=Duel.GetMatchingGroup(c27699122.filter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 判断卡组中卡通怪兽的不同卡名数量是否达到3种，且自己主要怪兽区有空位。
		return dg:GetClassCount(Card.GetCode)>=3 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
	-- 设置操作信息：本次效果处理将从卡组特殊召唤1只卡通怪兽，用于规则连锁等的判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选出3只不同卡名的卡通怪兽给对方确认，由对方随机选1只，将其无视召唤条件特殊召唤到自己场上；其余怪兽仍留在卡组，相当于回到卡组。
function c27699122.op(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时再次取得卡组中符合特殊召唤条件的卡通怪兽集合。
	local g=Duel.GetMatchingGroup(c27699122.filter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 若自己主要怪兽区无空位或卡组中不同卡名的卡通怪兽不足3只，则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or g:GetClassCount(Card.GetCode)<3 then return end
	-- 提示玩家选择要展示给对方确认的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家从卡组中选出3只卡名互不相同的卡通怪兽（不可取消），用于展示。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
	if sg then
		-- 将选出的3只卡通怪兽展示给对方玩家。
		Duel.ConfirmCards(1-tp,sg)
		local tc=sg:RandomSelect(1-tp,1):GetFirst()
		-- 将对方随机选中的那只卡通怪兽无视召唤条件，以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
