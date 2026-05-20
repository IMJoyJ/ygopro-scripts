--毒の魔妖－土蜘蛛
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：「毒之魔妖-土蜘蛛」在自己场上只能有1只表侧表示存在。
-- ②：这张卡在墓地存在，原本等级是7星的自己的同调怪兽被战斗或者对方的效果破坏的场合才能发动。从自己墓地把1只其他的不死族怪兽除外，这张卡特殊召唤。
-- ③：这张卡从墓地的特殊召唤成功的场合才能发动。从双方卡组上面把3张卡送去墓地。
function c77092311.initial_effect(c)
	c:SetUniqueOnField(1,0,77092311)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这张卡从墓地的特殊召唤成功的场合才能发动。从双方卡组上面把3张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77092311,0))
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,77092311)
	e1:SetCondition(c77092311.condition)
	e1:SetTarget(c77092311.target)
	e1:SetOperation(c77092311.operation)
	c:RegisterEffect(e1)
	-- 这张卡在墓地存在，原本等级是7星的自己的同调怪兽被战斗或者对方的效果破坏的场合才能发动。从自己墓地把1只其他的不死族怪兽除外，这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(77092311,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,77092312)
	e2:SetCondition(c77092311.spcon)
	e2:SetTarget(c77092311.sptg)
	e2:SetOperation(c77092311.spop)
	c:RegisterEffect(e2)
end
-- 检查这张卡是否是从墓地特殊召唤成功的
function c77092311.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- 效果③（从双方卡组送墓）的发动准备与合法性检查
function c77092311.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方玩家是否都能从卡组上面把3张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) and Duel.IsPlayerCanDiscardDeck(1-tp,3) end
	-- 设置当前连锁的操作信息为“双方玩家从卡组送去墓地3张卡”
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,PLAYER_ALL,3)
end
-- 效果③（从双方卡组送墓）的效果处理
function c77092311.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组最上方的3张卡
	local g1=Duel.GetDecktopGroup(tp,3)
	-- 获取对方卡组最上方的3张卡
	local g2=Duel.GetDecktopGroup(1-tp,3)
	g1:Merge(g2)
	-- 使接下来的送墓操作不触发系统自动洗牌检测
	Duel.DisableShuffleCheck()
	-- 将双方卡组最上方的共6张卡因效果送去墓地
	Duel.SendtoGrave(g1,REASON_EFFECT)
end
-- 过滤满足“原本等级是7星的自己的同调怪兽被战斗或者对方的效果破坏”条件的卡片
function c77092311.spfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:GetPreviousTypeOnField()&TYPE_SYNCHRO~=0
		and c:GetOriginalLevel()==7 and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 检查被破坏的怪兽中是否存在满足条件的原本等级7星的自己同调怪兽，且自身不在其中
function c77092311.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c77092311.spfilter,1,nil,tp)
end
-- 过滤自己墓地中可以除外的不死族怪兽
function c77092311.rmfilter(c)
	return c:IsAbleToRemove() and c:IsRace(RACE_ZOMBIE)
end
-- 效果②（墓地特召）的发动准备与合法性检查
function c77092311.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己墓地是否存在除这张卡以外的可以除外的不死族怪兽
		and Duel.IsExistingMatchingCard(c77092311.rmfilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 设置当前连锁的操作信息为“特殊召唤自身”
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置当前连锁的操作信息为“从自己墓地除外1张卡”
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
-- 效果②（墓地特召）的效果处理
function c77092311.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只除这张卡以外的不死族怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c77092311.rmfilter),tp,LOCATION_GRAVE,0,1,1,c)
	-- 如果成功除外了选择的怪兽，且这张卡仍存在于墓地
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		-- 将这张卡在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
