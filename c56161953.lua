--スクリプトン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己墓地把「隐藏脚本氪灯人」以外的1只电子界族怪兽除外才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡作为电子界族连接怪兽的连接素材送去墓地的场合，以除外的1只自己或者对方的怪兽为对象才能发动。那只怪兽回到持有者卡组。
function c56161953.initial_effect(c)
	-- ①：从自己墓地把「隐藏脚本氪灯人」以外的1只电子界族怪兽除外才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56161953,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,56161953)
	e1:SetCost(c56161953.spcost)
	e1:SetTarget(c56161953.sptg)
	e1:SetOperation(c56161953.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡作为电子界族连接怪兽的连接素材送去墓地的场合，以除外的1只自己或者对方的怪兽为对象才能发动。那只怪兽回到持有者卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56161953,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,56161954)
	e2:SetCondition(c56161953.tdcon)
	e2:SetTarget(c56161953.tdtg)
	e2:SetOperation(c56161953.tdop)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地中「隐藏脚本氪灯人」以外的、可以作为代价除外的电子界族怪兽
function c56161953.cfilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsAbleToRemoveAsCost() and not c:IsCode(56161953)
end
-- ①号效果的cost（发动代价）处理函数：从自己墓地把「隐藏脚本氪灯人」以外的1只电子界族怪兽除外
function c56161953.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c56161953.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家发送“请选择要除外的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择1张自己墓地中满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c56161953.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的卡作为发动代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①号效果的target（发动准备/检查）处理函数：检查怪兽区域是否有空位以及自身是否能特殊召唤，并设置特殊召唤的操作信息
function c56161953.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息为“特殊召唤这张卡”
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①号效果的operation（效果处理）函数：将这张卡从手卡特殊召唤
function c56161953.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②号效果的发动条件：这张卡作为电子界族连接怪兽的连接素材送去墓地
function c56161953.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_LINK and c:GetReasonCard():IsRace(RACE_CYBERSE)
end
-- 过滤除外状态的、可以回到卡组的表侧表示怪兽
function c56161953.tdfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- ②号效果的target（发动准备/选择对象）处理函数：选择除外的1只自己或者对方的怪兽为对象，并设置回到卡组的操作信息
function c56161953.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and c56161953.tdfilter(chkc) end
	-- 检查双方除外状态的卡中是否存在可以作为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(c56161953.tdfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	-- 给玩家发送“请选择要返回卡组的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择除外的1只自己或者对方的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c56161953.tdfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)
	-- 设置当前连锁的操作信息为“将选中的卡送回卡组”
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- ②号效果的operation（效果处理）函数：使作为对象的怪兽回到持有者卡组
function c56161953.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽送回持有者卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
