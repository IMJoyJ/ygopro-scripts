--超電導戦機インペリオン・マグナム
-- 效果：
-- 「磁石战士 电磁武神」＋「电磁石战士 电磁狂神」
-- 这张卡用以上记的卡为融合素材的融合召唤才能特殊召唤。
-- ①：1回合1次，对方把怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
-- ②：表侧表示的这张卡因对方的效果从场上离开的场合才能发动。「磁石战士 电磁武神」「电磁石战士 电磁狂神」各1只从手卡·卡组无视召唤条件特殊召唤。
function c4628897.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为75347539和42901635的两只怪兽作为融合素材
	aux.AddFusionProcCode2(c,75347539,42901635,false,false)
	-- 这张卡用以上记的卡为融合素材的融合召唤才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置此卡的特殊召唤条件为必须通过融合召唤方式特殊召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ①：1回合1次，对方把怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4628897,0))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c4628897.negcon)
	e2:SetTarget(c4628897.negtg)
	e2:SetOperation(c4628897.negop)
	c:RegisterEffect(e2)
	-- ②：表侧表示的这张卡因对方的效果从场上离开的场合才能发动。「磁石战士 电磁武神」「电磁石战士 电磁狂神」各1只从手卡·卡组无视召唤条件特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4628897,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c4628897.spcon)
	e3:SetTarget(c4628897.sptg)
	e3:SetOperation(c4628897.spop)
	c:RegisterEffect(e3)
end
-- 判断是否为对方发动的怪兽效果或魔法/陷阱卡，并且该连锁可以被无效
function c4628897.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if ep==tp or c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 判断对方发动的是怪兽效果或魔法/陷阱卡，并且该连锁可以被无效
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- 设置连锁处理时的操作信息，包括使发动无效和破坏目标卡片
function c4628897.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息为破坏目标卡片
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行连锁无效并破坏对应卡片的操作
function c4628897.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断连锁是否成功无效且目标卡片存在并关联到该效果
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将目标卡片以效果原因破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 判断此卡是否因对方效果离场并且处于表侧表示状态
function c4628897.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetReasonPlayer()==1-tp and c:IsReason(REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
-- 过滤函数，用于筛选可以特殊召唤的「磁石战士 电磁武神」或「电磁石战士 电磁狂神」
function c4628897.spfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 检测是否满足特殊召唤条件，包括未受青眼精灵龙影响、场上空位足够以及手卡/卡组存在符合条件的卡片
function c4628897.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检测玩家场上是否有足够的怪兽区域用于特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检测玩家手卡或卡组中是否存在「磁石战士 电磁武神」
		and Duel.IsExistingMatchingCard(c4628897.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,75347539)
		-- 检测玩家手卡或卡组中是否存在「电磁石战士 电磁狂神」
		and Duel.IsExistingMatchingCard(c4628897.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,42901635) end
	-- 设置操作信息为特殊召唤两张卡片
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 判断是否满足特殊召唤条件，包括未受青眼精灵龙影响以及场上空位足够
function c4628897.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 判断玩家场上是否有足够的怪兽区域用于特殊召唤
		or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取所有符合条件的「磁石战士 电磁武神」
	local g1=Duel.GetMatchingGroup(c4628897.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp,75347539)
	-- 获取所有符合条件的「电磁石战士 电磁狂神」
	local g2=Duel.GetMatchingGroup(c4628897.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp,42901635)
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg1=g1:Select(tp,1,1,nil)
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg2=g2:Select(tp,1,1,nil)
		sg1:Merge(sg2)
		-- 将选中的卡片无视召唤条件特殊召唤到场上
		Duel.SpecialSummon(sg1,0,tp,tp,true,false,POS_FACEUP)
	end
end
