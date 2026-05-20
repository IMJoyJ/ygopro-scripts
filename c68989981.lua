--堕ち武者
-- 效果：
-- ①：这张卡召唤成功时才能发动。从卡组把1只不死族怪兽送去墓地。
-- ②：表侧表示的这张卡因对方的效果从场上离开的场合才能发动。从卡组把「堕武者」以外的1只4星以下的不死族怪兽特殊召唤。
function c68989981.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从卡组把1只不死族怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68989981,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c68989981.tgtg)
	e1:SetOperation(c68989981.tgop)
	c:RegisterEffect(e1)
	-- ②：表侧表示的这张卡因对方的效果从场上离开的场合才能发动。从卡组把「堕武者」以外的1只4星以下的不死族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68989981,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCondition(c68989981.spcon)
	e2:SetTarget(c68989981.sptg)
	e2:SetOperation(c68989981.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：卡组中可以送去墓地的不死族怪兽
function c68989981.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_ZOMBIE) and c:IsAbleToGrave()
end
-- 效果①的发动准备：检查卡组中是否存在满足条件的不死族怪兽，并设置送去墓地的操作信息
function c68989981.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身卡组是否存在至少1只可以送去墓地的不死族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c68989981.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息为从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组选择1只不死族怪兽送去墓地
function c68989981.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1只满足条件的不死族怪兽
	local g=Duel.SelectMatchingCard(tp,c68989981.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 效果②的发动条件：表侧表示的这张卡因对方的效果从场上离开
function c68989981.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
end
-- 过滤条件：卡组中「堕武者」以外的4星以下、可以特殊召唤的不死族怪兽
function c68989981.spfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsLevelBelow(4) and not c:IsCode(68989981) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备：检查怪兽区域空位和卡组中是否存在满足条件的怪兽，并设置特殊召唤的操作信息
function c68989981.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
		-- 检查自身卡组是否存在至少1只满足特殊召唤条件的怪兽
		Duel.IsExistingMatchingCard(c68989981.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息为从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理：从卡组选择1只「堕武者」以外的4星以下的不死族怪兽特殊召唤
function c68989981.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身场上是否仍有可用的怪兽区域空位，若无则结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足特殊召唤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c68989981.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自身场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
