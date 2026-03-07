--ヒーローズルール1 ファイブ・フリーダムス
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以自己·对方的墓地的卡合计最多5张为对象才能发动。那些卡除外。
-- ②：把这个回合没有送去墓地的这张卡从墓地除外，以自己的除外状态的1只「元素英雄」怪兽为对象才能发动。那只怪兽无视召唤条件特殊召唤。
local s,id,o=GetID()
-- 注册两个效果：①除外效果和②特殊召唤效果
function s.initial_effect(c)
	-- ①：以自己·对方的墓地的卡合计最多5张为对象才能发动。那些卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把这个回合没有送去墓地的这张卡从墓地除外，以自己的除外状态的1只「元素英雄」怪兽为对象才能发动。那只怪兽无视召唤条件特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	-- 效果发动条件：这张卡在本回合没有送去墓地
	e2:SetCondition(aux.exccon)
	-- 效果发动费用：将此卡从墓地除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 选择目标：从双方墓地选择1~5张可除外的卡
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToRemove() end
	-- 检查是否满足选择目标的条件：墓地存在可除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1~5张墓地的卡作为除外对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,5,nil)
	-- 设置效果处理信息：将选择的卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),PLAYER_ALL,LOCATION_GRAVE)
end
-- 处理效果：将选择的卡除外
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选择的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	-- 筛选出与连锁相关的、未受王家长眠之谷影响的卡
	local sg=g:Filter(aux.NecroValleyFilter(Card.IsRelateToChain),nil)
	-- 将筛选出的卡除外
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end
-- 特殊召唤的过滤条件：除外状态的元素英雄怪兽
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x3008) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 选择目标：选择1只可特殊召唤的除外状态的元素英雄怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and s.spfilter(chkc,e,tp) and chkc:IsControler(tp) end
	-- 检查是否满足选择目标的条件：场上存在可特殊召唤的卡且有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否满足选择目标的条件：存在符合条件的除外怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1只除外状态的元素英雄怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置效果处理信息：将选择的卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果：将选择的卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选择的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否与连锁相关且未受王家长眠之谷影响
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将目标卡特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
