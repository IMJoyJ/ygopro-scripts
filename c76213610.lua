--死宰 サムエル
-- 效果：
-- 6星怪兽×2
-- 主要阶段（诱发即时效果）：可以把这张卡1个超量素材取除，以自己墓地1只不死族怪兽为对象；那只怪兽特殊召唤，那之后，可以把持有那只怪兽攻击力以下攻击力的对方场上1只怪兽的效果无效化。
-- 这张卡被送去墓地的场合：可以以自己·对方墓地1只怪兽为对象；那只怪兽回到卡组。
-- 「死萨缪尔的尸会者」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 初始化卡片效果：注册超量召唤手续、①去除素材特召墓地不死族怪兽并可无效对方怪兽效果、②被送去墓地时将双方墓地怪兽回收卡组效果
function s.initial_effect(c)
	-- 注册超量召唤手续：6星怪兽×2
	aux.AddXyzProcedure(c,nil,6,2)
	c:EnableReviveLimit()
	-- 主要阶段（诱发即时效果）：可以把这张卡1个超量素材去除，以自己墓地1只不死族怪兽为对象才能发动。那只怪兽特殊召唤，那之后，可以把持有那只怪兽攻击力以下攻击力的对方场上1只怪兽的效果无效化。
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
	-- 这张卡被送去墓地的场合：可以以自己·对方墓地1只怪兽为对象才能发动。那只怪兽回到卡组。
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
-- ①效果发动条件：双方的主要阶段
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为主要阶段
	return Duel.IsMainPhase()
end
-- ①效果发动Cost：去除这张卡的1个超量素材
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ①效果目标过滤条件：墓地的不死族怪兽且可以特殊召唤
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果发动准备：选择自己墓地1只不死族怪兽为对象并设置特召操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 发动条件检查：怪兽区域有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可特召的不死族怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只不死族怪兽作为对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息：特殊召唤1只对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 无效化过滤条件：对方场上攻击力在指定数值以下且效果未被无效的表侧表示怪兽
function s.disfilter(c,atk)
	-- 检查怪兽是否表侧表示、效果未无效且攻击力不超过特召怪兽攻击力
	return aux.NegateMonsterFilter(c) and c:IsAttackBelow(atk)
end
-- ①效果处理：特殊召唤墓地的对象怪兽，随后可选择对方场上1只符合攻击力条件的怪兽将其效果无效
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁中的特召对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍关联连锁且不受王谷影响
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc)
		-- 将对象怪兽表侧表示特殊召唤
		and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查对方场上是否存在攻击力在该怪兽以下且可被无效的怪兽
		and Duel.IsExistingMatchingCard(s.disfilter,tp,0,LOCATION_MZONE,1,nil,tc:GetAttack())
		-- 询问玩家是否选择无效对方怪兽效果
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否让怪兽无效？"
		-- 连接效果块（分隔特殊召唤与效果无效处理）
		Duel.BreakEffect()
		-- 提示玩家选择要无效效果的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		-- 从对方场上选择1只攻击力不高于特召怪兽的怪兽
		local g=Duel.SelectMatchingCard(tp,s.disfilter,tp,0,LOCATION_MZONE,1,1,nil,tc:GetAttack())
		-- 高亮显示要无效的怪兽
		Duel.HintSelection(g)
		local nc=g:GetFirst()
		-- 中断该怪兽已发动的连锁效果
		Duel.NegateRelatedChain(nc,RESET_TURN_SET)
		-- 使其效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		nc:RegisterEffect(e1)
		-- 使其发动的效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		nc:RegisterEffect(e2)
	end
end
-- ②效果目标过滤条件：墓地的怪兽且可以回到卡组
function s.tdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- ②效果发动准备：选择双方墓地1只怪兽为对象并设置返回卡组的操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.tdfilter(chkc) end
	-- 发动条件检查：双方墓地是否存在可以回到卡组的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择双方墓地1只怪兽作为对象
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	-- 设置连锁操作信息：将对象怪兽1只返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- ②效果处理：将选择的对象怪兽洗回卡组
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍关联连锁且不受王谷影响
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将对象怪兽洗回卡组
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
