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
-- 初始化卡片效果：注册指示物许可、代码/系列关联列表、发动效果、放置指示物效果以及5种去除指示物发动的效果
function s.initial_effect(c)
	c:EnableCounterPermit(0x25)
	-- 注册关联卡名列表：「于贝尔」(78371393)
	aux.AddCodeList(c,78371393)
	-- 注册关联字段怪兽列表：「于贝尔」字段(0x1a5)
	aux.AddSetNameMonsterList(c,0x1a5)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①效果：每次「于贝尔」怪兽或者有「于贝尔」的卡名记载的怪兽特殊召唤，给这张卡放置1个年代记指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.counter)
	c:RegisterEffect(e2)
	-- ②效果●1：把1个年代记指示物取除才能发动。从自己墓地把1只「于贝尔」特殊召唤。
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
	-- ②效果●2：把2个年代记指示物取除才能发动。自己的除外状态的1张卡加入手牌。
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
	-- ②效果●3：把3个年代记指示物取除才能发动。从卡组选1张卡除外。
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
	-- ②效果●4：把4个年代记指示物取除才能发动。场地1张卡破坏。
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
	-- ②效果●5：把5个年代记指示物取除才能发动。从卡组把1张「超融合」加入手牌。
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
s.mentioned_counter={
	[0x25]=true,
}
-- 放置指示物特召怪兽过滤条件：属于「于贝尔」字段或记载「于贝尔」卡名的怪兽
function s.cfilter(c)
	-- 判断怪兽是否属于「于贝尔」字段或文本记载有「于贝尔」卡名
	return c:IsSetCard(0x1a5) or aux.IsCodeListed(c,78371393)
end
-- ①效果处理：若有符合条件的怪兽特殊召唤成功，为自身放置1个年代记指示物
function s.counter(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.cfilter,1,nil) then
		e:GetHandler():AddCounter(0x25,1)
	end
end
-- ②效果●1 Cost：取除1个年代记指示物
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：判断自己场上是否能取除1个年代记指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x25,1,REASON_COST) end
	-- 向对方显示选中的分支效果提示
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 取除1个年代记指示物
	Duel.RemoveCounter(tp,1,0,0x25,1,REASON_COST)
end
-- ●1特召过滤条件：墓地中的「于贝尔」
function s.filter1(c,e,tp)
	return c:IsCode(78371393) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ●1发动准备与目标确认
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在可特召的「于贝尔」
		and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息：从墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ●1效果处理：从墓地选择1只「于贝尔」表侧表示特殊召唤
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从墓地选择1只「于贝尔」（受王家长眠之谷过滤）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter1),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽忽略条件表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
	end
end
-- ②效果●2 Cost：取除2个年代记指示物
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：判断是否能取除2个年代记指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x25,2,REASON_COST) end
	-- 向对方显示选中的分支效果提示
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 取除2个年代记指示物
	Duel.RemoveCounter(tp,1,0,0x25,2,REASON_COST)
end
-- ●2回收过滤条件：自己除外状态且可加入手牌的卡
function s.filter2(c,e,tp)
	return c:IsAbleToHand()
end
-- ●2发动准备与目标确认
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true
		-- 检查除外区是否存在可加入手牌的卡
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置连锁操作信息：将除外区的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
-- ●2效果处理：从除外区选择1张卡加入手牌
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从除外区选择1张卡
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if g:GetCount()>0 then
		-- 高亮显示选中的卡片
		Duel.HintSelection(g)
		-- 将选中的除外卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ②效果●3 Cost：取除3个年代记指示物
function s.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：判断是否能取除3个年代记指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x25,3,REASON_COST) end
	-- 向对方显示选中的分支效果提示
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 取除3个年代记指示物
	Duel.RemoveCounter(tp,1,0,0x25,3,REASON_COST)
end
-- ●3发动准备与目标确认
function s.tg3(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在可除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：从卡组除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- ●3效果处理：从卡组选择1张卡表侧表示除外
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从卡组选择1张卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_DECK,0,1,1,nil)
	local tg=g:GetFirst()
	if tg==nil then return end
	-- 将选中的卡表侧表示除外
	Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
end
-- ②效果●4 Cost：取除4个年代记指示物
function s.cost4(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：判断是否能取除4个年代记指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x25,4,REASON_COST) end
	-- 向对方显示选中的分支效果提示
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 取除4个年代记指示物
	Duel.RemoveCounter(tp,1,0,0x25,4,REASON_COST)
end
-- ●4发动准备与目标确认
function s.tg4(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在卡片
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取场上所有卡片
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息：破坏场上1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ●4效果处理：选择场上1张卡破坏
function s.op4(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从场上选择1张卡
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		-- 高亮显示选中的卡片
		Duel.HintSelection(g)
		-- 破坏选中的卡
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- ②效果●5 Cost：取除5个年代记指示物
function s.cost5(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：判断是否能取除5个年代记指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x25,5,REASON_COST) end
	-- 向对方显示选中的分支效果提示
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 取除5个年代记指示物
	Duel.RemoveCounter(tp,1,0,0x25,5,REASON_COST)
end
-- ●5检索过滤条件：「超融合」(48130397)且能加入手牌
function s.filter5(c,e,tp)
	return c:IsAbleToHand() and c:IsCode(48130397)
end
-- ●5发动准备与目标确认
function s.tg5(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true
		-- 检查卡组是否存在可检索的「超融合」
		and Duel.IsExistingMatchingCard(s.filter5,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：从卡组将1张「超融合」加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ●5效果处理：从卡组选1张「超融合」加入手牌并确认
function s.op5(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张「超融合」
	local g=Duel.SelectMatchingCard(tp,s.filter5,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将「超融合」加入手牌
		Duel.SendtoHand(g:GetFirst(),nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
