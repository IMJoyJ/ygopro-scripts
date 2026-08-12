--ヒーローズルール1 ファイブ・フリーダムス
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以自己·对方的墓地的卡合计最多5张为对象才能发动。那些卡除外。
-- ②：把这个回合没有送去墓地的这张卡从墓地除外，以自己的除外状态的1只「元素英雄」怪兽为对象才能发动。那只怪兽无视召唤条件特殊召唤。
local s,id,o=GetID()
-- 注册两个效果：e1为①的发动效果，自由时点发动，取对象为分类除外；e2为②的墓地诱发即时效果，以除外状态的「元素英雄」怪兽为对象特殊召唤，1回合只能使用1次，以把这张卡从墓地除外为代价
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
	-- 这个卡名的②的效果1回合只能使用1次。②：把这个回合没有送去墓地的这张卡从墓地除外，以自己的除外状态的1只「元素英雄」怪兽为对象才能发动。那只怪兽无视召唤条件特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	-- 设置发动条件：这张卡送去墓地的回合不能发动这个效果（除非是被弹回等原因）
	e2:SetCondition(aux.exccon)
	-- 设置发动代价：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- ①效果的对象选择处理：检查对象合法性，确认墓地存在可除外的卡，提示并选择双方墓地合计1～5张卡作为对象，并设置除外操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToRemove() end
	-- 发动条件检查：双方墓地中至少存在1张可以除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 向玩家发送「请选择要除外的卡」的选择提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让自己选择双方墓地中1～5张可以除外的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,5,nil)
	-- 设置连锁操作信息：确定将所选数量的墓地卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),PLAYER_ALL,LOCATION_GRAVE)
end
-- ①效果的处理：取得与本连锁关联的对象卡，过滤掉受王家长眠之谷影响的卡，将剩余的卡正面表示除外
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得与本连锁关联的对象卡，并过滤出不受王家长眠之谷影响的卡
	local sg=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	-- 将筛选后的卡以正面表示因效果除外
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end
-- 特殊召唤对象的过滤条件：除外状态的正面表示的「元素英雄」怪兽，且可以无视召唤条件特殊召唤
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x3008) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ②效果的对象选择前置检查：对象需在除外状态且满足过滤条件并为自己控制；发动条件为自己主要怪兽区有空位且除外状态存在可特殊召唤的「元素英雄」怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and s.spfilter(chkc,e,tp) and chkc:IsControler(tp) end
	-- 检查自己主要怪兽区是否有可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的除外状态是否存在可以作为对象特殊召唤的「元素英雄」怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向玩家发送「请选择要特殊召唤的卡」的选择提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让自己选择自己的除外状态的1只「元素英雄」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置连锁操作信息：确定将所选的1只怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果的处理：取得效果对象，若其仍与本连锁关联且不受王家长眠之谷影响，则将其无视召唤条件以正面表示特殊召唤到自己场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡是否仍与本连锁关联，且不受王家长眠之谷的影响
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将对象怪兽无视召唤条件以正面攻击表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
