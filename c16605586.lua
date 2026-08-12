--D-HERO ディナイアルガイ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次，②的效果在决斗中只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。选自己的卡组·墓地·除外状态的1只「命运英雄」怪兽在卡组最上面放置。
-- ②：这张卡在墓地存在，自己的场上或墓地有「命运英雄 否定人」以外的「命运英雄」怪兽存在的场合才能发动。这张卡特殊召唤。
function c16605586.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。
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
	-- ②：这张卡在墓地存在，自己的场上或墓地有「命运英雄 否定人」以外的「命运英雄」怪兽存在的场合才能发动。
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
-- 过滤函数，用于筛选满足条件的「命运英雄」怪兽
function c16605586.tdfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xc008)
		and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
		-- 确保卡组中至少有两张卡，避免将卡组唯一一张卡移出
		and (not c:IsLocation(LOCATION_DECK) or Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1)
end
-- 效果的发动条件判断，检查是否存在满足条件的「命运英雄」怪兽
function c16605586.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查以玩家tp来看的卡组·墓地·除外区是否存在至少1张满足条件的「命运英雄」怪兽
		return Duel.IsExistingMatchingCard(c16605586.tdfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,tp)
	end
end
-- 处理选择放置位置的逻辑，决定是否从卡组中选择卡片
function c16605586.tdop(e,tp,eg,ep,ev,re,r,rp)
	local loc=LOCATION_GRAVE+LOCATION_REMOVED
	-- 检查在墓地或除外区是否存在满足条件的「命运英雄」怪兽
	if not Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c16605586.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,tp)
		-- 检查卡组中是否存在满足条件的「命运英雄」怪兽
		or Duel.IsExistingMatchingCard(c16605586.tdfilter,tp,LOCATION_DECK,0,1,nil,tp)
			-- 询问玩家是否要从卡组中选择卡片
			and Duel.SelectYesNo(tp,aux.Stringid(16605586,3)) then  --"放置在卡组最上面的卡是否要从卡组选择？"
		loc=loc+LOCATION_DECK
	end
	-- 提示玩家选择要放置到卡组最上面的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(16605586,2))  --"请选择要放置到卡组最上面的卡"
	-- 选择满足条件的1张「命运英雄」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c16605586.tdfilter),tp,loc,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		if not tc:IsLocation(LOCATION_DECK) then
			-- 将选中的怪兽送入卡组最上方
			Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
		if loc&LOCATION_DECK>0 then
			-- 洗切玩家的卡组
			Duel.ShuffleDeck(tp)
		end
		if tc:IsLocation(LOCATION_DECK) then
			-- 将卡片移动到卡组最上方
			Duel.MoveSequence(tc,SEQ_DECKTOP)
			-- 确认卡组最上方的1张卡
			Duel.ConfirmDecktop(tp,1)
		end
	end
end
-- 过滤函数，用于筛选「命运英雄」怪兽（不包括否定人）
function c16605586.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0xc008) and not c:IsCode(16605586)
end
-- 判断是否满足特殊召唤的条件
function c16605586.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以玩家tp来看的场上或墓地中是否存在至少1张「命运英雄」怪兽（不包括否定人）
	return Duel.IsExistingMatchingCard(c16605586.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end
-- 设置特殊召唤效果的目标
function c16605586.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function c16605586.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以正面表示特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
