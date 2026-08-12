--クロス・キーパー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡·场上的这张卡送去墓地才能发动。从自己的手卡·墓地选1只「元素英雄」怪兽或者「新空间侠」怪兽特殊召唤。这个效果从墓地特殊召唤的怪兽的效果无效化。
-- ②：这张卡在墓地存在的状态，自己对「元素英雄」融合怪兽的特殊召唤成功的场合，把这张卡除外才能发动。自己从卡组抽2张，那之后选1张手卡回到卡组最下面。
local s,id,o=GetID()
-- 注册卡片的两个效果，分别是手牌/场上的特殊召唤效果和墓地的抽卡效果
function s.initial_effect(c)
	-- 注册卡片进入墓地时的监听效果，用于标记卡片是否已进入墓地
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- ①：把手卡·场上的这张卡送去墓地才能发动。从自己的手卡·墓地选1只「元素英雄」怪兽或者「新空间侠」怪兽特殊召唤。这个效果从墓地特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己对「元素英雄」融合怪兽的特殊召唤成功的场合，把这张卡除外才能发动。自己从卡组抽2张，那之后选1张手卡回到卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetLabelObject(e0)
	e2:SetCondition(s.drcon)
	-- 效果发动时需要将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
-- 效果发动时将此卡送去墓地作为费用
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 特殊召唤的过滤条件，筛选「元素英雄」或「新空间侠」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x3008,0x1f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否可以发动特殊召唤效果，检查是否有满足条件的怪兽以及场上是否有空位
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查手牌或墓地是否有满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 处理特殊召唤效果，选择并特殊召唤符合条件的怪兽，并对从墓地特殊召唤的怪兽施加效果无效化
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	-- 执行特殊召唤步骤
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		and tc:IsPreviousLocation(LOCATION_GRAVE) then
		-- 使从墓地特殊召唤的怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使从墓地特殊召唤的怪兽的召唤效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 判断是否为「元素英雄」融合怪兽的过滤条件
function s.cfilter(c,tp,se)
	return c:IsFaceup() and c:IsSetCard(0x3008) and c:IsType(TYPE_FUSION) and c:IsSummonPlayer(tp)
		and (se==nil or c:GetReasonEffect()~=se)
end
-- 判断是否满足墓地效果发动条件，即是否有「元素英雄」融合怪兽被特殊召唤
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.cfilter,1,nil,tp,se)
end
-- 设置抽卡和回卡组效果的操作信息
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以发动抽卡效果
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置抽卡效果的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡效果的目标数量
	Duel.SetTargetParam(2)
	-- 设置抽卡效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	-- 设置回卡组效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 处理抽卡和回卡组效果，抽2张卡并选择1张手卡返回卡组最底端
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和目标数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果并判断是否成功抽到2张
	if Duel.Draw(p,d,REASON_EFFECT)==2 then
		-- 洗切玩家手牌
		Duel.ShuffleHand(p)
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 选择要返回卡组的卡
		local sg=Duel.SelectMatchingCard(p,Card.IsAbleToDeck,p,LOCATION_HAND,0,1,1,nil)
		if #sg>0 then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将选中的卡返回卡组最底端
			Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
