--HSR－GOMガン
-- 效果：
-- 风属性怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。进行1只风属性怪兽的召唤。这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
-- ②：从额外卡组把1只风属性同调怪兽除外才能发动。等级合计直到变成和除外的怪兽相同为止，从卡组把2只卡名不同的「疾行机人」怪兽给对方观看，对方从那之中随机选1只。那1只怪兽加入自己手卡，剩余送去墓地。
function c72813401.initial_effect(c)
	-- 设置连接召唤手续：风属性怪兽2只
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_WIND),2,2)
	c:EnableReviveLimit()
	-- ①：自己主要阶段才能发动。进行1只风属性怪兽的召唤。这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72813401,0))  --"召唤"
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,72813401)
	e1:SetTarget(c72813401.sumtg)
	e1:SetOperation(c72813401.sumop)
	c:RegisterEffect(e1)
	-- ②：从额外卡组把1只风属性同调怪兽除外才能发动。等级合计直到变成和除外的怪兽相同为止，从卡组把2只卡名不同的「疾行机人」怪兽给对方观看，对方从那之中随机选1只。那1只怪兽加入自己手卡，剩余送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(72813401,1))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,72813402)
	e2:SetTarget(c72813401.thtg)
	e2:SetOperation(c72813401.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：手牌或场上可以进行通常召唤的风属性怪兽
function c72813401.sumfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsSummonable(true,nil)
end
-- 效果①的发动准备与可行性检查（Target函数）
function c72813401.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌或场上是否存在可以进行通常召唤的风属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c72813401.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置连锁处理中的操作信息：包含召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果①的执行函数（Operation函数），处理召唤风属性怪兽及添加额外卡组特召限制
function c72813401.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 玩家选择1只手牌或场上的风属性怪兽
	local g=Duel.SelectMatchingCard(tp,c72813401.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 忽略每回合通常召唤次数限制，对选中的怪兽进行通常召唤
		Duel.Summon(tp,tc,true,nil)
	end
	-- 这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。②：从额外卡组把1只风属性同调怪兽除外才能发动。等级合计直到变成和除外的怪兽相同为止，从卡组把2只卡名不同的「疾行机人」怪兽给对方观看，对方从那之中随机选1只。那1只怪兽加入自己手卡，剩余送去墓地。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c72813401.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能从额外卡组特殊召唤同调怪兽以外怪兽的玩家效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制函数：限制从额外卡组特殊召唤非同调怪兽
function c72813401.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤函数：用于作为Cost除外的额外卡组风属性同调怪兽，且卡组中存在2只等级合计等于其等级且卡名不同的「疾行机人」怪兽
function c72813401.costfilter(c,g)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_SYNCHRO) and c:IsAbleToRemoveAsCost()
		and g:IsExists(c72813401.thfilter1,1,nil,g,c:GetLevel())
end
-- 过滤函数：检查卡组中是否存在另一只卡名不同且等级合计等于目标等级的「疾行机人」怪兽
function c72813401.thfilter1(c,g,lv)
	return g:IsExists(c72813401.thfilter2,1,c,c,lv)
end
-- 过滤函数：匹配卡名不同且等级合计等于目标等级的第二只「疾行机人」怪兽
function c72813401.thfilter2(c,mc,lv)
	return not c:IsCode(mc:GetCode()) and c:GetLevel()+mc:GetLevel()==lv
end
-- 过滤函数：卡组中的「疾行机人」怪兽
function c72813401.thfilter(c)
	return c:IsSetCard(0x2016) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果②的发动准备、Cost处理与可行性检查（Target函数）
function c72813401.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取卡组中所有满足条件的「疾行机人」怪兽
	local g=Duel.GetMatchingGroup(c72813401.thfilter,tp,LOCATION_DECK,0,nil)
	-- 检查额外卡组是否存在可以作为Cost除外的风属性同调怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c72813401.costfilter,tp,LOCATION_EXTRA,0,1,nil,g) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择1只额外卡组的风属性同调怪兽
	local sg=Duel.SelectMatchingCard(tp,c72813401.costfilter,tp,LOCATION_EXTRA,0,1,1,nil,g)
	e:SetLabel(sg:GetFirst():GetLevel())
	-- 将选中的怪兽表侧表示除外作为发动的代价
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
	-- 设置连锁处理中的操作信息：包含从卡组将1张卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的执行函数（Operation函数），处理展示卡片、对方随机选择、加入手牌及送去墓地
function c72813401.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足条件的「疾行机人」怪兽
	local g=Duel.GetMatchingGroup(c72813401.thfilter,tp,LOCATION_DECK,0,nil)
	local lv=e:GetLabel()
	-- 提示玩家选择第一只加入手牌候选的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local sg=g:FilterSelect(tp,c72813401.thfilter1,1,1,nil,g,lv)
	if #sg>0 then
		-- 提示玩家选择第二只加入手牌候选的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg2=g:FilterSelect(tp,c72813401.thfilter2,1,1,sg:GetFirst(),sg:GetFirst(),lv)
		sg:Merge(sg2)
		-- 给对方玩家确认选中的2只「疾行机人」怪兽
		Duel.ConfirmCards(1-tp,sg)
		-- 提示对方玩家选择要加入自己手牌的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tg=sg:RandomSelect(1-tp,1)
		tg:GetFirst():SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
		-- 将对方随机选中的那1只怪兽加入自己手牌
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		sg:Sub(tg)
		-- 将剩余的另1只怪兽送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
