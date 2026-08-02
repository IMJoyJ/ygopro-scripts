--死宰 サムエル
-- 效果：
-- 6星怪兽×2
-- 主要阶段（诱发即时效果）：可以把这张卡1个超量素材取除，以自己墓地1只不死族怪兽为对象；那只怪兽特殊召唤，那之后，可以把持有那只怪兽攻击力以下攻击力的对方场上1只怪兽的效果无效化。
-- 这张卡被送去墓地的场合：可以以自己·对方墓地1只怪兽为对象；那只怪兽回到卡组。
-- 「死萨缪尔的尸会者」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 初始化效果：添加超量召唤手续并注册怪兽效果
function s.initial_effect(c)
	-- 设置超量召唤手续：2只6星怪兽
	aux.AddXyzProcedure(c,nil,6,2)
	c:EnableReviveLimit()
	-- 主要阶段（诱发即时效果）：可以把这张卡1个超量素材取除，以自己墓地1只不死族怪兽为对象；那只怪兽特殊召唤，那之后，可以把持有那只怪兽攻击力以下攻击力的对方场上1只怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 这张卡被送去墓地的场合：可以以自己·对方墓地1只怪兽为对象；那只怪兽回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回到卡组"
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 判断当前是否是主要阶段
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为主要阶段
	return Duel.IsMainPhase()
end
-- 判断并取除1个超量素材作为Cost
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：不死族且可以被特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 若是对象选择操作则判断对象卡是否满足条件；若是效果发动条件判定：
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 判断自己场上是否有空余的主要怪兽区
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己墓地存在满足条件的不死族怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择自己墓地1只满足条件的不死族怪兽作为对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：包含特殊召唤操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 过滤条件：对方场上攻击力在指定值以下且可以被无效的表侧表示效果怪兽
function s.disfilter(c,atk)
	-- 判断卡片是否为未被无效的表侧表示效果怪兽，且攻击力在指定值以下
	return aux.NegateMonsterFilter(c) and c:IsAttackBelow(atk)
end
-- ①效果的操作：特殊召唤墓地怪兽，并可选择无效对方场上怪兽的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取被选择的墓地不死族怪兽对象
	local tc=Duel.GetFirstTarget()
	-- 判断该卡是否因相关原因仍在有效范围内且不受王家长眠之谷影响
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc)
		-- 将该怪兽特殊召唤，若成功则继续
		and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 判断对方场上是否存在攻击力在该怪兽攻击力以下的可无效的怪兽
		and Duel.IsExistingMatchingCard(s.disfilter,tp,0,LOCATION_MZONE,1,nil,tc:GetAttack())
		-- 提示玩家是否要无效怪兽的效果
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否让怪兽无效？"
		-- 中断当前效果，使前后的效果处理视为不同时点处理
		Duel.BreakEffect()
		-- 提示玩家选择要无效的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		-- 让玩家选择对方场上1只满足条件的怪兽
		local g=Duel.SelectMatchingCard(tp,s.disfilter,tp,0,LOCATION_MZONE,1,1,nil,tc:GetAttack())
		-- 显示被选中怪兽的动画效果
		Duel.HintSelection(g)
		local nc=g:GetFirst()
		-- 使和该怪兽有关的连锁都无效化
		Duel.NegateRelatedChain(nc,RESET_TURN_SET)
		-- 将其效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		nc:RegisterEffect(e1)
		-- 将其发动和效果的处理无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		nc:RegisterEffect(e2)
	end
end
-- 过滤条件：墓地中可以回到卡组的怪兽
function s.tdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- ②效果的对象选择及操作信息设置：选择墓地1只怪兽回到卡组
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.tdfilter(chkc) end
	-- 判断双方墓地是否存在可以回到卡组的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择双方墓地1只满足条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	-- 设置操作信息：包含回卡组操作
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- ②效果的操作：将对象怪兽洗回卡组
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选择的墓地怪兽对象
	local tc=Duel.GetFirstTarget()
	-- 判断该怪兽是否有效且不受王家长眠之谷影响
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将该怪兽洗回卡组
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
