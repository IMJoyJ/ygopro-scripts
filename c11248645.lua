--ハイネス・デーモン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤的场合，从自己墓地把1张「恶魔」卡除外才能发动。从卡组把「殿下恶魔」以外的2张「恶魔」卡加入手卡。这个效果的发动后，直到回合结束时自己不是「恶魔」怪兽不能从额外卡组特殊召唤。
-- ②：这张卡在墓地存在的状态，自己的仪式怪兽被战斗破坏时才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 创建并注册两个效果：①召唤时以除外墓地1张「恶魔」卡为代价，从卡组检索2张「殿下恶魔」以外的「恶魔」卡加入手卡，并附加非「恶魔」不能从额外卡组特殊召唤的自肃；②这张卡在墓地存在时，自己的仪式怪兽被战斗破坏的场合，自身特殊召唤。
function s.initial_effect(c)
	-- ①：这张卡召唤的场合，从自己墓地把1张「恶魔」卡除外才能发动。从卡组把「殿下恶魔」以外的2张「恶魔」卡加入手卡。这个效果的发动后，直到回合结束时自己不是「恶魔」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己的仪式怪兽被战斗破坏时才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 定义①的代价过滤条件：选择自己墓地的「恶魔」字段怪兽，且该卡可以作为代价除外。
function s.costfilter(c)
	return c:IsSetCard(0x45) and c:IsAbleToRemoveAsCost()
end
-- 定义①的代价处理：发动前检查墓地存在至少1张可除外的「恶魔」卡；实际发动时从墓地将选中的1张「恶魔」卡表侧除外作为代价。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：确认自己墓地存在至少1张满足s.costfilter的「恶魔」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出选择提示，让玩家从墓地中选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张满足s.costfilter的卡作为发动代价。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡以表侧表示除外（REASON_COST），完成代价支付。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 定义检索过滤条件：卡组中卡名不是「殿下恶魔」、属于「恶魔」字段且可以加入手卡的卡。
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x45) and c:IsAbleToHand()
end
-- 定义①的发动目标判定：检查卡组存在至少2张满足检索条件的「恶魔」卡，并设置操作信息为将卡组中的卡加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动判定：确认自己卡组中存在至少2张满足s.thfilter的「恶魔」卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,2,nil) end
	-- 向系统登记本次效果处理包含“从卡组将2张卡加入手卡”的操作信息，用于效果发动检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 处理①的效果：从自己卡组选出2张「殿下恶魔」以外的「恶魔」卡加入手卡，并向对方展示；随后给自己适用“直到回合结束时，不是「恶魔」怪兽不能从额外卡组特殊召唤”的自肃效果。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有满足检索条件的「恶魔」卡的集合，用于后续选择。
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if g and g:GetCount()>1 then
		-- 弹出从卡组选择要加入手牌的卡的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,2,2,nil)
		-- 将选中的2张卡加入持有者手卡，原因是效果处理。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,sg)
	end
	-- 对应的效果原文为：①自肃部分“这个效果的发动后，直到回合结束时自己不是「恶魔」怪兽不能从额外卡组特殊召唤。”以及②“这张卡在墓地存在的状态，自己的仪式怪兽被战斗破坏时才能发动。这张卡特殊召唤。”
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果e1注册到当前玩家tp，使其在结束阶段前持续影响该玩家的特殊召唤行为。
	Duel.RegisterEffect(e1,tp)
end
-- 定义自肃效果的判定函数：当特殊召唤的怪兽不是「恶魔」字段且来自额外卡组时，禁止该特殊召唤。
function s.splimit(e,c)
	return not c:IsSetCard(0x45) and c:IsLocation(LOCATION_EXTRA)
end
-- 定义战斗破坏事件的过滤条件：被战破的怪兽在场上时的类型包含仪式怪兽，且原控制者是发动效果的一方。
function s.cfilter(c,tp)
	local rm=TYPE_RITUAL|TYPE_MONSTER
	return c:GetPreviousTypeOnField()&rm==rm and c:IsPreviousControler(tp)
end
-- 定义②的发动条件：本连锁的战斗破坏事件中存在自己的仪式怪兽被战破，且被战破的怪兽不是墓地中的这张卡自身。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 定义②的发动目标条件：自己主要怪兽区域有空位，且这张卡本身能够被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己场上存在可用的主要怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向系统登记本次效果处理包含特殊召唤这张卡的操作信息，数量1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理②的效果：若这张卡仍与发动时关联且不受王家长眠之谷影响，则将其表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 特殊召唤前确认：这张卡仍能关联当前连锁，并且未受王家长眠之谷等效果限制。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将这张卡以表侧表示特殊召唤到自己场上，召唤方式为效果召唤，不检查召唤条件与苏生限制。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
