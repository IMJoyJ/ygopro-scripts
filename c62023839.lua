--フィッシュボーグ－アーチャー
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在墓地存在，自己场上没有怪兽存在的场合，从手卡丢弃1只水属性怪兽才能发动。这张卡特殊召唤。这个效果特殊召唤的回合的战斗阶段开始时，水属性怪兽以外的自己场上的怪兽全部破坏。
function c62023839.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡在墓地存在，自己场上没有怪兽存在的场合，从手卡丢弃1只水属性怪兽才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62023839,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,62023839)
	e1:SetCondition(c62023839.spcon)
	e1:SetCost(c62023839.spcost)
	e1:SetTarget(c62023839.sptg)
	e1:SetOperation(c62023839.spop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：自己场上没有怪兽存在。
function c62023839.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽数量是否为0。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 过滤条件：手卡中可丢弃的水属性怪兽。
function c62023839.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsDiscardable()
end
-- 效果发动代价：从手卡丢弃1只水属性怪兽。
function c62023839.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1只可以丢弃的水属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c62023839.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃1张手卡中的水属性怪兽作为发动代价。
	Duel.DiscardHand(tp,c62023839.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果发动目标：检查自己场上是否有空位，且自身是否可以特殊召唤。
function c62023839.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示将特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：特殊召唤自身，并注册在回合结束前战斗阶段开始时触发的延迟破坏效果。
function c62023839.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果相关，则将其以表侧表示特殊召唤，并判断是否特殊召唤成功。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的回合的战斗阶段开始时，水属性怪兽以外的自己场上的怪兽全部破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
		e1:SetCountLimit(1)
		e1:SetOperation(c62023839.desop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册该全局效果，使其在当前回合生效。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 过滤条件：自己场上里侧表示的怪兽或非水属性的怪兽。
function c62023839.desfilter(c)
	return c:IsFacedown() or not c:IsAttribute(ATTRIBUTE_WATER)
end
-- 破坏效果处理：获取自己场上所有非水属性的怪兽并将其破坏。
function c62023839.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有满足破坏过滤条件（里侧表示或非水属性）的怪兽。
	local g=Duel.GetMatchingGroup(c62023839.desfilter,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()>0 then
		-- 向玩家发送提示信息，显示该卡片的效果发动动画。
		Duel.Hint(HINT_CARD,0,62023839)
		-- 因效果破坏所有选中的怪兽。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
