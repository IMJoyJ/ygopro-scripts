--ゴーティスの双角アスカーン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合，以自己场上1只鱼族怪兽和对方场上1张卡为对象才能发动。那些卡除外。
-- ②：这张卡被除外的场合，从自己墓地把1只鱼族怪兽除外才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化效果，设置该卡的同调召唤手续并注册两个诱发效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为该卡添加同调召唤手续，要求必须是调整+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	-- 效果①：这张卡同调召唤成功的场合发动，以自己场上1只鱼族怪兽和对方场上1张卡为对象将它们除外
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.rmcon)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- 效果②：这张卡被除外的场合发动，从自己墓地把1只鱼族怪兽除外才能将这张卡特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 判断是否为同调召唤成功触发的效果
function s.rmcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤满足条件的鱼族怪兽（正面表示且能除外）
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH) and c:IsAbleToRemove()
end
-- 设置效果①的目标选择函数，检查自己场上是否存在鱼族怪兽和对方场上的卡
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在满足条件的鱼族怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在可除外的卡
		and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己场上的鱼族怪兽作为对象
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上的卡作为对象
	local g2=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	g:Merge(g2)
	-- 设置操作信息，表示将要除外2张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,0,0)
end
-- 执行效果①的操作，将目标卡除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if g then
		local rg=g:Filter(Card.IsRelateToEffect,nil,e)
		-- 将目标卡组中的卡以正面表示的形式除外
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	end
end
-- 过滤满足条件的鱼族怪兽（类型为怪兽且能除外作为费用）
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_FISH) and c:IsAbleToRemoveAsCost()
end
-- 设置效果②的费用选择函数，检查墓地是否存在满足条件的鱼族怪兽
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地是否存在满足条件的鱼族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择墓地中的鱼族怪兽作为费用
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡以正面表示的形式除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置效果②的目标选择函数，检查是否可以特殊召唤该卡
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上是否有足够的位置进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将要特殊召唤该卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行效果②的操作，将该卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断该卡是否仍存在于连锁中并进行特殊召唤
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
