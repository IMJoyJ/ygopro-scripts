--七精の解門
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，把「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」的其中1只或者有那其中任意种的卡名记述的1只怪兽从卡组加入手卡。
-- ②：1回合1次，丢弃1张手卡才能发动。从自己墓地把1只攻击力和守备力是0的恶魔族怪兽特殊召唤。
-- ③：1回合1次，自己场上有10星怪兽存在的场合才能发动。从自己墓地把1张永续魔法卡加入手卡。
function c80312545.initial_effect(c)
	-- 注册卡片效果中记述了「神炎皇 乌利亚」、「降雷皇 哈蒙」、「幻魔皇 拉比艾尔」的卡片密码
	aux.AddCodeList(c,6007213,32491822,69890967)
	-- ①：作为这张卡的发动时的效果处理，把「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」的其中1只或者有那其中任意种的卡名记述的1只怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,80312545+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c80312545.target)
	e1:SetOperation(c80312545.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，丢弃1张手卡才能发动。从自己墓地把1只攻击力和守备力是0的恶魔族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(80312545,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c80312545.spcost)
	e2:SetTarget(c80312545.sptg)
	e2:SetOperation(c80312545.spop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，自己场上有10星怪兽存在的场合才能发动。从自己墓地把1张永续魔法卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(80312545,1))  --"墓地回收"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c80312545.thcon)
	e3:SetTarget(c80312545.thtg)
	e3:SetOperation(c80312545.thop)
	c:RegisterEffect(e3)
end
-- 过滤卡组中「神炎皇 乌利亚」、「降雷皇 哈蒙」、「幻魔皇 拉比艾尔」或记述了这三者任意卡名的怪兽，且能加入手卡
function c80312545.filter(c)
	return (c:IsCode(6007213,32491822,69890967)
		-- 或者是记述了这三张卡中任意卡名的怪兽，且可以加入手卡
		or ((aux.IsCodeListed(c,6007213) or aux.IsCodeListed(c,32491822) or aux.IsCodeListed(c,69890967)) and c:IsType(TYPE_MONSTER))) and c:IsAbleToHand()
end
-- 效果①（卡片发动时效果处理）的靶向/发动准备函数
function c80312545.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足检索条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c80312545.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息，表示该效果包含从卡组将1张卡加入手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①（卡片发动时效果处理）的执行函数
function c80312545.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c80312545.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动代价（Cost）函数
function c80312545.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤墓地中攻击力和守备力是0的恶魔族怪兽，且可以特殊召唤
function c80312545.spfilter(c,e,tp)
	return c:IsAttack(0) and c:IsDefense(0) and c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的靶向/发动准备函数
function c80312545.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域，且墓地中是否存在满足特殊召唤条件的怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c80312545.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁信息，表示该效果包含从墓地特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果②的执行函数
function c80312545.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否已满，若满则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从墓地选择1只满足条件的怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c80312545.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤场上表侧表示存在的10星怪兽
function c80312545.ffilter(c)
	return c:IsFaceup() and c:IsLevel(10)
end
-- 效果③的发动条件函数
function c80312545.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的10星怪兽
	return Duel.IsExistingMatchingCard(c80312545.ffilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤墓地中的永续魔法卡，且能加入手卡
function c80312545.thfilter(c)
	return c:IsType(TYPE_CONTINUOUS) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 效果③的靶向/发动准备函数
function c80312545.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地中是否存在满足回收条件的永续魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c80312545.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁信息，表示该效果包含从墓地将1张卡加入手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 效果③的执行函数
function c80312545.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从墓地选择1张满足条件的永续魔法卡（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c80312545.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
