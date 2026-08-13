--D-HERO ディナイアルガイ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次，②的效果在决斗中只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。选自己的卡组·墓地·除外状态的1只「命运英雄」怪兽在卡组最上面放置。
-- ②：这张卡在墓地存在，自己的场上或墓地有「命运英雄 否定人」以外的「命运英雄」怪兽存在的场合才能发动。这张卡特殊召唤。
function c16605586.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡召唤·特殊召唤的场合才能发动。选自己的卡组·墓地·除外状态的1只「命运英雄」怪兽在卡组最上面放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16605586,0))
	e1:SetCategory(CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,16605586)
	e1:SetTarget(c16605586.tdtg)
	e1:SetOperation(c16605586.tdop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果在决斗中只能使用1次。②：这张卡在墓地存在，自己的场上或墓地有「命运英雄 否定人」以外的「命运英雄」怪兽存在的场合才能发动。这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(16605586,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,16605587+EFFECT_COUNT_CODE_DUEL)
	e3:SetCondition(c16605586.spcon)
	e3:SetTarget(c16605586.sptg)
	e3:SetOperation(c16605586.spop)
	c:RegisterEffect(e3)
end
-- 定义①效果的候选卡过滤器：要求是怪兽且属于「命运英雄」字段；从除外区选择的必须表侧表示；从卡组选择的场合，卡组数量须大于1。
function c16605586.tdfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xc008)
		and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
		-- 从卡组选择时要求卡组至少2张卡（只有1张时放到最上面无实际意义，也避免洗牌）。
		and (not c:IsLocation(LOCATION_DECK) or Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1)
end
-- ①效果的发动条件判定：检查自己的卡组·墓地·除外状态是否存在至少1张满足过滤条件的「命运英雄」怪兽。
function c16605586.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 返回是否存在满足条件的候选卡（卡组+墓地+除外区，至少1张）。
		return Duel.IsExistingMatchingCard(c16605586.tdfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,tp)
	end
end
-- ①效果处理：初始可选区域为墓地+除外区；若墓地/除外区没有可选卡，或玩家选择从卡组选，则将卡组也加入可选范围。
function c16605586.tdop(e,tp,eg,ep,ev,re,r,rp)
	local loc=LOCATION_GRAVE+LOCATION_REMOVED
	-- 检查墓地·除外区是否存在不受王家长眠之谷影响的候选「命运英雄」怪兽。
	if not Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c16605586.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,tp)
		-- 检查卡组中是否存在候选「命运英雄」怪兽。
		or Duel.IsExistingMatchingCard(c16605586.tdfilter,tp,LOCATION_DECK,0,1,nil,tp)
			-- 当墓地/除外区已有可选卡时，询问玩家是否从卡组选择；选择“是”则将卡组加入可选范围。
			and Duel.SelectYesNo(tp,aux.Stringid(16605586,3)) then  --"放置在卡组最上面的卡是否要从卡组选择？"
		loc=loc+LOCATION_DECK
	end
	-- 弹出选择提示，提示玩家“请选择要放置到卡组最上面的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(16605586,2))  --"请选择要放置到卡组最上面的卡"
	-- 从loc位置（卡组/墓地/除外区）中选择1张满足条件且不受王家长眠之谷影响的「命运英雄」怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c16605586.tdfilter),tp,loc,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		if not tc:IsLocation(LOCATION_DECK) then
			-- 将选中的卡（来自墓地或除外区）送回持有者卡组最顶端。
			Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
		if loc&LOCATION_DECK>0 then
			-- 若可选范围包含卡组，洗切卡组以隐藏卡组顺序信息。
			Duel.ShuffleDeck(tp)
		end
		if tc:IsLocation(LOCATION_DECK) then
			-- 将选中的卡移动到卡组最顶端（确保其在最上方）。
			Duel.MoveSequence(tc,SEQ_DECKTOP)
			-- 向双方玩家展示卡组最上方1张卡，确认放置的怪兽。
			Duel.ConfirmDecktop(tp,1)
		end
	end
end
-- 定义②效果的参考怪兽过滤器：表侧表示的「命运英雄」怪兽，且不是「命运英雄 否定人」自身。
function c16605586.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0xc008) and not c:IsCode(16605586)
end
-- ②效果的发动条件：我方场上或墓地存在「命运英雄 否定人」以外的「命运英雄」怪兽。
function c16605586.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回是否存在满足cfilter条件的「命运英雄」怪兽（场上或墓地）。
	return Duel.IsExistingMatchingCard(c16605586.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end
-- ②效果的发动目标判定：我方主要怪兽区有空位，且此卡能够被特殊召唤。
function c16605586.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区是否有可用区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，标明本效果将特殊召唤1只怪兽（即此卡自身），用于连锁响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：若此卡仍与效果相关，则将其特殊召唤。
function c16605586.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 以表侧表示将这张卡特殊召唤到我方场上（遵守召唤条件和苏生限制）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
