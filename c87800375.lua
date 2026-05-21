--聖剣の導く未来
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：把自己场上的「圣剑」装备魔法卡数量的卡从自己卡组上面翻开。从那之中选1张加入手卡，剩下的卡用喜欢的顺序回到卡组上面。
-- ②：把墓地的这张卡除外才能发动。同名卡不在自己的场上·墓地存在的1只「圣骑士」怪兽从卡组特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
function c87800375.initial_effect(c)
	-- ①：把自己场上的「圣剑」装备魔法卡数量的卡从自己卡组上面翻开。从那之中选1张加入手卡，剩下的卡用喜欢的顺序回到卡组上面。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c87800375.target)
	e1:SetOperation(c87800375.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。同名卡不在自己的场上·墓地存在的1只「圣骑士」怪兽从卡组特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,87800375)
	-- 设置该效果在这张卡送去墓地的回合不能发动
	e2:SetCondition(aux.exccon)
	-- 将墓地的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c87800375.sptg)
	e2:SetOperation(c87800375.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「圣剑」装备魔法卡
function c87800375.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP) and c:IsSetCard(0x207a)
end
-- ①号效果的发动准备
function c87800375.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算自己场上表侧表示的「圣剑」装备魔法卡数量
	local ct=Duel.GetMatchingGroupCount(c87800375.filter,tp,LOCATION_ONFIELD,0,nil)
	-- 检查场上是否存在「圣剑」装备魔法卡，且自己卡组上方的卡片数量不小于该数量
	if chk==0 then return ct>0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=ct end
end
-- ①号效果的处理
function c87800375.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 计算自己场上表侧表示的「圣剑」装备魔法卡数量
	local ct=Duel.GetMatchingGroupCount(c87800375.filter,tp,LOCATION_ONFIELD,0,nil)
	if ct==0 then return end
	-- 确认自己卡组最上方对应数量的卡
	Duel.ConfirmDecktop(tp,ct)
	-- 获取自己卡组最上方对应数量的卡片组
	local g=Duel.GetDecktopGroup(tp,ct)
	if #g==0 then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local sg=g:Select(tp,1,1,nil)
	-- 设置接下来的操作不进行洗牌检测
	Duel.DisableShuffleCheck()
	-- 将选中的卡加入手牌，并判断是否成功
	if Duel.SendtoHand(sg,nil,REASON_EFFECT)~=0 then
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,sg)
		ct=ct-1
	end
	-- 洗切玩家的手牌
	Duel.ShuffleHand(tp)
	-- 如果还有剩下的卡，让玩家以喜欢的顺序放回卡组最上方
	if ct>0 then Duel.SortDecktop(tp,tp,ct) end
end
-- 过滤条件：场上表侧表示或墓地中存在的同名卡
function c87800375.eqfilter(c,cd)
	return c:IsCode(cd) and (c:IsFaceup() or not c:IsOnField())
end
-- 过滤条件：卡组中可以特殊召唤，且同名卡不在自己场上或墓地存在的「圣骑士」怪兽
function c87800375.spfilter(c,e,tp)
	return c:IsSetCard(0x107a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己场上（表侧表示）和墓地中是否不存在该怪兽的同名卡
		and not Duel.IsExistingMatchingCard(c87800375.eqfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil,c:GetCode())
end
-- ②号效果的发动准备
function c87800375.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域，且卡组中是否存在满足条件的「圣骑士」怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c87800375.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从卡组特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②号效果的处理
function c87800375.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足特殊召唤条件的「圣骑士」怪兽
	local g=Duel.SelectMatchingCard(tp,c87800375.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
