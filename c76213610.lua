--Officiator of Doom Samuel
-- 效果：
-- 6星怪兽×2
-- 主要阶段（诱发即时效果）：可以把这张卡1个超量素材取除，以自己墓地1只不死族怪兽为对象；那只怪兽特殊召唤，那之后，可以把持有那只怪兽攻击力以下攻击力的对方场上1只怪兽的效果无效化。
-- 这张卡被送去墓地的场合：可以以自己·对方墓地1只怪兽为对象；那只怪兽回到卡组。
-- 「死萨缪尔的尸会者」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 注册“死萨缪尔的尸会者”的卡片效果：注册XYZ召唤手续，主要阶段去除超量素材特召墓地不死族怪兽并可能无效对方怪兽效果的诱发即时效果①，以及被送去墓地时使双方墓地1只怪兽回到卡组的触发效果②。
function s.initial_effect(c)
	-- 为卡片添加XYZ召唤手续：需要2只6星怪兽作为超量素材。
	aux.AddXyzProcedure(c,nil,6,2)
	c:EnableReviveLimit()
	-- 「死萨缪尔的尸会者」的每个效果1回合各能使用1次。主要阶段（诱发即时效果）：可以把这张卡1个超量素材取除，以自己墓地1只不死族怪兽为对象；那只怪兽特殊召唤，那之后，可以把持有那只怪兽攻击力以下攻击力的对方场上1只怪兽的效果无效化。
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
	-- 「死萨缪尔的尸会者」的每个效果1回合各能使用1次。这张卡被送去墓地的场合：可以以自己·对方墓地1只怪兽为对象；那只怪兽回到卡组。
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
-- 效果①的发动条件判断：只能在主要阶段发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为主要阶段（主要阶段1或主要阶段2）。
	return Duel.IsMainPhase()
end
-- 效果①的发动代价（Cost）：取除这张卡的1个超量素材。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数：检索己方墓地中是不死族且可以特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备（Target）：检查己方怪兽区域是否有空位、己方墓地是否存在可作为对象特召的不死族怪兽；选择墓地中的1只不死族怪兽作为效果对象，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 效果发动判定：检查己方主要怪兽区域是否还有可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动判定：检查自己墓地中是否存在至少1张可成为效果对象且符合特召条件的不死族怪兽。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 给玩家显示“选择要特殊召唤的卡”的系统提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择自己墓地中1只符合条件的怪兽作为效果对象，同时将其设置为当前连锁的对象卡。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：特殊召唤选中的对象怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 过滤函数：检索对方场上符合效果无效条件，且攻击力在指定攻击力以下的表侧表示效果怪兽。
function s.disfilter(c,atk)
	-- 判断怪兽是否是表侧表示且未被无效的效果怪兽，且攻击力小于等于给定的数值。
	return aux.NegateMonsterFilter(c) and c:IsAttackBelow(atk)
end
-- 效果①的效果处理（Operation）：若对象卡仍在墓地且不受“王家长眠之谷”影响，将其特殊召唤；若特殊召唤成功，且对方场上存在持有该怪兽攻击力以下攻击力的表侧表示怪兽，则可以让玩家选择是否将其效果无效化。若选择是，则使选中的对方怪兽在本连锁中及之后无效化。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁的发动阶段所选择的特召对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查该怪兽是否仍与连锁相关，且在不受“王家长眠之谷”影响的情况下执行后续效果。
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc)
		-- 尝试将选中的墓地怪兽以表侧表示特殊召唤到场上，并确认特殊召唤成功。
		and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查对方场上是否存在持有这只被召唤怪兽攻击力以下的表侧表示效果怪兽。
		and Duel.IsExistingMatchingCard(s.disfilter,tp,0,LOCATION_MZONE,1,nil,tc:GetAttack())
		-- 让玩家选择是否将对方场上1只符合条件的怪兽效果无效化。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否让怪兽无效？"
		-- 中断效果处理，使后续的无效化处理与前面的特殊召唤处理不视为同时进行。
		Duel.BreakEffect()
		-- 给玩家显示“选择要无效的卡”的系统提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		-- 让玩家从对方场上选择1只持有该召唤怪兽攻击力以下的表侧表示效果怪兽。
		local g=Duel.SelectMatchingCard(tp,s.disfilter,tp,0,LOCATION_MZONE,1,1,nil,tc:GetAttack())
		-- 给选中的要无效的怪兽显示对应的视觉提示动画效果。
		Duel.HintSelection(g)
		local nc=g:GetFirst()
		-- 使与目标怪兽相关的连锁在解析时全部无效化，当目标怪兽变为里侧表示时重置此无效化。
		Duel.NegateRelatedChain(nc,RESET_TURN_SET)
		-- 可以把持有那只怪兽攻击力以下攻击力的对方场上1只怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		nc:RegisterEffect(e1)
		-- 可以把持有那只怪兽攻击力以下攻击力的对方场上1只怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		nc:RegisterEffect(e2)
	end
end
-- 过滤函数：检索双方墓地中是怪兽卡且可以回到卡组的卡片。
function s.tdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 效果②的发动准备（Target）：检查双方墓地是否存在怪兽卡；选择自己或对方墓地的1只怪兽作为效果对象，并设置回到卡组的操作信息。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.tdfilter(chkc) end
	-- 效果发动判定：检查双方墓地中是否存在至少1张可以回到卡组的怪兽卡。
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 给玩家显示“选择要返回卡组的卡”的系统提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从双方墓地中选择1只符合条件的怪兽作为效果对象，同时将其设置为当前连锁的对象卡。
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	-- 设置操作信息：将选中的对象怪兽卡回到卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果②的效果处理（Operation）：若对象怪兽仍在墓地且不受“王家长眠之谷”影响，将其送回持有者的卡组并洗牌。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动阶段所选择的回到卡组的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查该怪兽是否仍与连锁相关，且在不受“王家长眠之谷”影响的情况下执行后续效果。
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 以效果原因将目标怪兽送回卡组并洗牌。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
