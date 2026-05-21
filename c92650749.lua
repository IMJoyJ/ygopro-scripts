--マチュア・クロニクル
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：每次「于贝尔」怪兽或者有「于贝尔」的卡名记述的怪兽特殊召唤，给这张卡放置1个年代记指示物。
-- ②：可以把自己场上的年代记指示物的以下数量取除，那个效果发动。
-- ●1：从自己墓地把1只「于贝尔」特殊召唤。
-- ●2：自己的除外状态的1张卡加入手卡。
-- ●3：从卡组选1张卡除外。
-- ●4：场上1张卡破坏。
-- ●5：从卡组把1张「超融合」加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包括允许放置指示物、注册卡名/系列关联、发动效果、放置指示物的诱发效果以及5个不同指示物数量的起动效果。
function s.initial_effect(c)
	c:EnableCounterPermit(0x25)
	-- 注册卡片效果中记述了「于贝尔」（卡号78371393）的卡名。
	aux.AddCodeList(c,78371393)
	-- 注册卡片效果中记述了「于贝尔」系列（系列号0x1a5）的怪兽。
	aux.AddSetNameMonsterList(c,0x1a5)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：每次「于贝尔」怪兽或者有「于贝尔」的卡名记述的怪兽特殊召唤，给这张卡放置1个年代记指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.counter)
	c:RegisterEffect(e2)
	-- ②：可以把自己场上的年代记指示物的以下数量取除，那个效果发动。 ●1：从自己墓地把1只「于贝尔」特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetDescription(aux.Stringid(id,0))  --"1：从自己墓地把1只「于贝尔」特殊召唤"
	e3:SetCountLimit(1,id)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCost(s.cost1)
	e3:SetTarget(s.tg1)
	e3:SetOperation(s.op1)
	c:RegisterEffect(e3)
	-- ②：可以把自己场上的年代记指示物的以下数量取除，那个效果发动。 ●2：自己的除外状态的1张卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetDescription(aux.Stringid(id,1))  --"2：自己的除外状态的1张卡加入手卡"
	e4:SetCountLimit(1,id)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCost(s.cost2)
	e4:SetTarget(s.tg2)
	e4:SetOperation(s.op2)
	c:RegisterEffect(e4)
	-- ②：可以把自己场上的年代记指示物的以下数量取除，那个效果发动。 ●3：从卡组选1张卡除外。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_REMOVE)
	e5:SetDescription(aux.Stringid(id,2))  --"3：从卡组选1张卡除外"
	e5:SetCountLimit(1,id)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCost(s.cost3)
	e5:SetTarget(s.tg3)
	e5:SetOperation(s.op3)
	c:RegisterEffect(e5)
	-- ②：可以把自己场上的年代记指示物的以下数量取除，那个效果发动。 ●4：场上1张卡破坏。
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_DESTROY)
	e6:SetDescription(aux.Stringid(id,3))  --"4：场上1张卡破坏"
	e6:SetCountLimit(1,id)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCost(s.cost4)
	e6:SetTarget(s.tg4)
	e6:SetOperation(s.op4)
	c:RegisterEffect(e6)
	-- ②：可以把自己场上的年代记指示物的以下数量取除，那个效果发动。 ●5：从卡组把1张「超融合」加入手卡。
	local e7=Effect.CreateEffect(c)
	e7:SetCategory(CATEGORY_TOHAND)
	e7:SetDescription(aux.Stringid(id,4))  --"5：从卡组把1张「超融合」加入手卡"
	e7:SetCountLimit(1,id)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetRange(LOCATION_SZONE)
	e7:SetCost(s.cost5)
	e7:SetTarget(s.tg5)
	e7:SetOperation(s.op5)
	c:RegisterEffect(e7)
end
-- 过滤函数：检查卡片是否属于「于贝尔」系列，或者其效果文本中是否记述了「于贝尔」卡名。
function s.cfilter(c)
	-- 判断卡片是否属于「于贝尔」系列，或者其效果文本中是否记述了「于贝尔」卡名。
	return c:IsSetCard(0x1a5) or aux.IsCodeListed(c,78371393)
end
-- 放置指示物的效果处理：若特殊召唤的怪兽中存在「于贝尔」怪兽或记述了「于贝尔」卡名的怪兽，则给这张卡放置1个年代记指示物。
function s.counter(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.cfilter,1,nil) then
		e:GetHandler():AddCounter(0x25,1)
	end
end
-- 效果①（去除1个指示物）的消耗：检查并去除自己场上的1个年代记指示物，并向对方玩家提示发动的效果。
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否能以消耗为原因去除1个年代记指示物。
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x25,1,REASON_COST) end
	-- 向对方玩家提示当前选择发动的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 以消耗为原因去除自己场上的1个年代记指示物。
	Duel.RemoveCounter(tp,1,0,0x25,1,REASON_COST)
end
-- 过滤函数：检查墓地中是否存在卡名为「于贝尔」且可以特殊召唤的怪兽。
function s.filter1(c,e,tp)
	return c:IsCode(78371393) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①（去除1个指示物）的靶向/合法性检查：检查怪兽区域是否有空位，且自己墓地是否存在可以特殊召唤的「于贝尔」，并设置特殊召唤的操作信息。
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足特殊召唤条件的「于贝尔」。
		and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息：从自己墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果①（去除1个指示物）的效果处理：从自己墓地选择1只「于贝尔」特殊召唤（受王家长眠之谷影响）。
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足条件的「于贝尔」（适用王家长眠之谷的过滤）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter1),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤，无视召唤条件和苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
	end
end
-- 效果②（去除2个指示物）的消耗：检查并去除自己场上的2个年代记指示物，并向对方玩家提示发动的效果。
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否能以消耗为原因去除2个年代记指示物。
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x25,2,REASON_COST) end
	-- 向对方玩家提示当前选择发动的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 以消耗为原因去除自己场上的2个年代记指示物。
	Duel.RemoveCounter(tp,1,0,0x25,2,REASON_COST)
end
-- 过滤函数：检查卡片是否可以加入手牌。
function s.filter2(c,e,tp)
	return c:IsAbleToHand()
end
-- 效果②（去除2个指示物）的靶向/合法性检查：检查自己除外状态的卡中是否存在可以加入手牌的卡，并设置加入手牌的操作信息。
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true
		-- 检查自己除外状态的卡中是否存在可以加入手牌的卡。
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置连锁操作信息：将1张除外状态的卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
-- 效果②（去除2个指示物）的效果处理：选择自己除外状态的1张卡加入手牌。
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己除外状态的卡中选择1张卡。
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if g:GetCount()>0 then
		-- 显式展示选中的卡片。
		Duel.HintSelection(g)
		-- 将选中的卡因效果加入手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 效果③（去除3个指示物）的消耗：检查并去除自己场上的3个年代记指示物，并向对方玩家提示发动的效果。
function s.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否能以消耗为原因去除3个年代记指示物。
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x25,3,REASON_COST) end
	-- 向对方玩家提示当前选择发动的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 以消耗为原因去除自己场上的3个年代记指示物。
	Duel.RemoveCounter(tp,1,0,0x25,3,REASON_COST)
end
-- 效果③（去除3个指示物）的靶向/合法性检查：检查自己卡组中是否存在可以除外的卡，并设置除外的操作信息。
function s.tg3(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在可以除外的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：从卡组除外1张卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 效果③（去除3个指示物）的效果处理：从自己卡组选择1张卡除外。
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己卡组中选择1张可以除外的卡。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_DECK,0,1,1,nil)
	local tg=g:GetFirst()
	if tg==nil then return end
	-- 将选中的卡因效果表侧表示除外。
	Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
end
-- 效果④（去除4个指示物）的消耗：检查并去除自己场上的4个年代记指示物，并向对方玩家提示发动的效果。
function s.cost4(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否能以消耗为原因去除4个年代记指示物。
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x25,4,REASON_COST) end
	-- 向对方玩家提示当前选择发动的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 以消耗为原因去除自己场上的4个年代记指示物。
	Duel.RemoveCounter(tp,1,0,0x25,4,REASON_COST)
end
-- 效果④（去除4个指示物）的靶向/合法性检查：检查场上是否存在卡片，并设置破坏的操作信息。
function s.tg4(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在任意卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取场上所有的卡片。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息：破坏场上的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果④（去除4个指示物）的效果处理：选择场上1张卡破坏。
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从场上选择1张卡。
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		-- 显式展示选中的卡片。
		Duel.HintSelection(g)
		-- 将选中的卡因效果破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 效果⑤（去除5个指示物）的消耗：检查并去除自己场上的5个年代记指示物，并向对方玩家提示发动的效果。
function s.cost5(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否能以消耗为原因去除5个年代记指示物。
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x25,5,REASON_COST) end
	-- 向对方玩家提示当前选择发动的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 以消耗为原因去除自己场上的5个年代记指示物。
	Duel.RemoveCounter(tp,1,0,0x25,5,REASON_COST)
end
-- 过滤函数：检查卡片是否可以加入手牌，且卡名为「超融合」（卡号48130397）。
function s.filter5(c,e,tp)
	return c:IsAbleToHand() and c:IsCode(48130397)
end
-- 效果⑤（去除5个指示物）的靶向/合法性检查：检查自己卡组中是否存在可以加入手牌的「超融合」，并设置加入手牌的操作信息。
function s.tg5(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true
		-- 检查自己卡组中是否存在可以加入手牌的「超融合」。
		and Duel.IsExistingMatchingCard(s.filter5,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果⑤（去除5个指示物）的效果处理：从卡组把1张「超融合」加入手牌。
function s.op5(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组中选择1张「超融合」。
	local g=Duel.SelectMatchingCard(tp,s.filter5,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入手牌。
		Duel.SendtoHand(g:GetFirst(),nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
