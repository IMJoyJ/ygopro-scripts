--ボンディング－DHO
-- 效果：
-- ①：从自己的手卡·墓地让「氘素龙」「氢素龙」「氧素龙」各1只回到卡组才能发动。从自己的手卡·墓地选1只「水龙-团簇」特殊召唤。
-- ②：把墓地的这张卡除外才能发动。从自己的卡组·墓地选1只「水龙」或者「水龙-团簇」加入手卡。
function c6890729.initial_effect(c)
	-- 注册本卡效果中涉及到的相关卡片密码列表（氘素龙、氢素龙、氧素龙、水龙-团簇、水龙）
	aux.AddCodeList(c,43017476,22587018,58071123,6022371,85066822)
	-- ①：从自己的手卡·墓地让「氘素龙」「氢素龙」「氧素龙」各1只回到卡组才能发动。从自己的手卡·墓地选1只「水龙-团簇」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c6890729.cost)
	e1:SetTarget(c6890729.target)
	e1:SetOperation(c6890729.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从自己的卡组·墓地选1只「水龙」或者「水龙-团簇」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置把墓地的这张卡除外作为发动代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c6890729.thtg)
	e2:SetOperation(c6890729.thop)
	c:RegisterEffect(e2)
end
-- 创建用于检查是否包含「氘素龙」「氢素龙」「氧素龙」各1张的条件检查函数数组
c6890729.spchecks=aux.CreateChecks(Card.IsCode,{43017476,22587018,58071123})
-- 过滤手卡·墓地中可以作为代价回到卡组的「氘素龙」「氢素龙」「氧素龙」
function c6890729.spcostfilter(c)
	return c:IsAbleToDeckAsCost() and c:IsCode(43017476,22587018,58071123)
end
-- ①号效果的发动代价与可行性检查函数
function c6890729.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己手卡·墓地中满足条件的「氘素龙」「氢素龙」「氧素龙」卡片组
	local g=Duel.GetMatchingGroup(c6890729.spcostfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and g:CheckSubGroupEach(c6890729.spchecks) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:SelectSubGroupEach(tp,c6890729.spchecks)
	-- 给对方玩家确认选中的卡片
	Duel.ConfirmCards(1-tp,sg)
	-- 将选中的卡片作为代价送回卡组并洗牌
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 过滤手卡·墓地中可以特殊召唤的「水龙-团簇」
function c6890729.filter(c,e,tp)
	return c:IsCode(6022371) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- ①号效果的发动目标检查与操作信息设置
function c6890729.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·墓地是否存在至少1只可以特殊召唤的「水龙-团簇」
		and Duel.IsExistingMatchingCard(c6890729.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从手卡·墓地特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ①号效果的效果处理（特殊召唤「水龙-团簇」）
function c6890729.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域空格，若无可用空格则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 过滤并选择1只手卡·墓地中不受王家长眠之谷影响的「水龙-团簇」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c6890729.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽无视召唤条件和苏生限制以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
		g:GetFirst():CompleteProcedure()
	end
end
-- 过滤卡组·墓地中可以加入手卡的「水龙」或「水龙-团簇」
function c6890729.thfilter(c)
	return c:IsCode(6022371,85066822) and c:IsAbleToHand()
end
-- ②号效果的发动目标检查与操作信息设置
function c6890729.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组·墓地是否存在至少1只可以加入手卡的「水龙」或「水龙-团簇」
	if chk==0 then return Duel.IsExistingMatchingCard(c6890729.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置加入手卡的操作信息（从卡组·墓地将1张卡加入手卡）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ②号效果的效果处理（检索或回收「水龙」或「水龙-团簇」）
function c6890729.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 过滤并选择1张卡组·墓地中不受王家长眠之谷影响的「水龙」或「水龙-团簇」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c6890729.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
