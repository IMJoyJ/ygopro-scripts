--雲魔物の雲核
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从手卡丢弃1只「云魔物」怪兽，以场上1只表侧表示怪兽为对象才能发动。给作为对象的怪兽放置那自身等级数量的雾指示物。
-- ②：从自己墓地把这张卡和1只「云魔物」怪兽除外才能发动。从卡组把1只「云魔物」怪兽特殊召唤。
function c88210105.initial_effect(c)
	-- ①：从手卡丢弃1只「云魔物」怪兽，以场上1只表侧表示怪兽为对象才能发动。给作为对象的怪兽放置那自身等级数量的雾指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88210105,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,88210105)
	e1:SetCost(c88210105.cost)
	e1:SetTarget(c88210105.target)
	e1:SetOperation(c88210105.operation)
	c:RegisterEffect(e1)
	-- ②：从自己墓地把这张卡和1只「云魔物」怪兽除外才能发动。从卡组把1只「云魔物」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(88210105,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,88210105)
	e2:SetCost(c88210105.spcost)
	e2:SetTarget(c88210105.sptg)
	e2:SetOperation(c88210105.spop)
	c:RegisterEffect(e2)
end
c88210105.mentioned_counter={
	[0x1019]=true,
}
-- Cost过滤条件：手牌中可丢弃的「云魔物」怪兽
function c88210105.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x18) and c:IsDiscardable()
end
-- ①效果发动Cost：从手牌丢弃1只「云魔物」怪兽
function c88210105.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌是否存在可丢弃的「云魔物」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c88210105.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手牌选择1只「云魔物」怪兽丢弃
	Duel.DiscardHand(tp,c88210105.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 目标怪兽过滤条件：场上表侧表示且持有等级可放置雾指示物的怪兽
function c88210105.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(1) and c:IsCanAddCounter(0x1019,c:GetLevel())
end
-- ①效果发动准备：选择场上1只表侧表示怪兽为对象并设置放置指示物操作信息
function c88210105.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c88210105.filter(chkc) end
	-- 检查场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c88210105.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送选择表侧表示卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示怪兽作为连锁对象
	local g=Duel.SelectTarget(tp,c88210105.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息：为目标怪兽放置其等级数量的雾指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,0x1019,g:GetFirst():GetLevel())
end
-- ①效果处理：给作为对象的怪兽放置那自身等级数量的雾指示物
function c88210105.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁指定的对象怪兽
	local tc=Duel.GetFirstTarget()
	local ct=tc:GetLevel()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and ct>0 then
		tc:AddCounter(0x1019,ct)
	end
end
-- Cost除外卡片过滤：墓地中可除外的「云魔物」怪兽
function c88210105.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x18) and c:IsAbleToRemoveAsCost()
end
-- ②效果发动Cost：从墓地把自身和1只「云魔物」怪兽除外
function c88210105.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查墓地是否存在除自身外可除外的「云魔物」怪兽
		and Duel.IsExistingMatchingCard(c88210105.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送选择要除外卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从墓地选择1只「云魔物」怪兽
	local g=Duel.SelectMatchingCard(tp,c88210105.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	g:AddCard(e:GetHandler())
	-- 把选中的「云魔物」怪兽与墓地的自身一同表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 特殊召唤目标过滤条件：卡组中可特殊召唤的「云魔物」怪兽
function c88210105.spfilter(c,e,tp)
	return c:IsSetCard(0x18) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动准备：检查怪兽区空位与卡组目标怪兽并设置操作信息
function c88210105.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区域是否有空余位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组是否存在可以特殊召唤的「云魔物」怪兽
		and Duel.IsExistingMatchingCard(c88210105.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组把1只「云魔物」怪兽表侧表示特殊召唤
function c88210105.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若怪兽区已无空位则终止特殊召唤处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送选择特殊召唤卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只「云魔物」怪兽
	local g=Duel.SelectMatchingCard(tp,c88210105.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「云魔物」怪兽表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
