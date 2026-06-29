--ヒーローズルール1 ファイブ・フリーダムス
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以自己·对方的墓地的卡合计最多5张为对象才能发动。那些卡除外。
-- ②：把这个回合没有送去墓地的这张卡从墓地除外，以自己的除外状态的1只「元素英雄」怪兽为对象才能发动。那只怪兽无视召唤条件特殊召唤。
local s,id,o=GetID()
-- 注册除外双方墓地最多5张卡的效果、以及从墓地除外自身特召被除外的元素英雄怪兽的效果
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
	-- 使用系统预设的辅助函数，确保此卡不是在送入墓地的当前回合发动
	e2:SetCondition(aux.exccon)
	-- 使用系统预设的辅助函数，将墓地的此卡除外作为效果发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 墓地卡片除外效果的发动准备与对象选择
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToRemove() end
	-- 检查双方墓地是否存在可以被除外的卡片
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 向玩家发送提示，请选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从双方墓地中选择合计最多5张卡片作为除外对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,5,nil)
	-- 设置操作信息为将选中的墓地卡片除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),PLAYER_ALL,LOCATION_GRAVE)
end
-- 墓地卡片除外效果的执行
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发连锁且依然存在于墓地的作为对象的卡片
	local sg=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	-- 将选中的卡片以表侧表示除外
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end
-- 除外状态的可特殊召唤的「元素英雄」怪兽过滤条件
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x3008) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 被除外元素英雄怪兽无视条件特召效果的发动准备与对象选择
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and s.spfilter(chkc,e,tp) and chkc:IsControler(tp) end
	-- 检查自己场上是否有空闲的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己被除外的卡片中是否存在可特殊召唤的的「元素英雄」怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向玩家发送提示，请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己被除外的卡片中选择1只「元素英雄」怪兽作为特召对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置操作信息为特殊召唤被选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 被除外元素英雄怪兽无视条件特召效果的执行
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中关联的作为对象的被除外怪兽
	local tc=Duel.GetFirstTarget()
	-- 若该怪兽依然处于被除外状态且未受无效影响，则继续处理
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将选中的怪兽无视召唤条件以表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
