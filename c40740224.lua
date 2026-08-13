--クロス・キーパー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡·场上的这张卡送去墓地才能发动。从自己的手卡·墓地选1只「元素英雄」怪兽或者「新空间侠」怪兽特殊召唤。这个效果从墓地特殊召唤的怪兽的效果无效化。
-- ②：这张卡在墓地存在的状态，自己对「元素英雄」融合怪兽的特殊召唤成功的场合，把这张卡除外才能发动。自己从卡组抽2张，那之后选1张手卡回到卡组最下面。
local s,id,o=GetID()
-- 初始化卡片效果函数，为这张卡注册①效果（送去墓地特召元素英雄/新空间侠）和②效果（元素英雄融合召唤成功时除外自身抽2回1）所需的全部效果对象及参数。
function s.initial_effect(c)
	-- 注册“此卡已在墓地”的标记检测效果，用于②效果在墓地存在状态的判定。
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：把手卡·场上的这张卡送去墓地才能发动。从自己的手卡·墓地选1只「元素英雄」怪兽或者「新空间侠」怪兽特殊召唤。这个效果从墓地特殊召唤的怪兽的效果无效化。
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
	-- 设置②效果的发动代价为将这张卡除外（aux.bfgcost是“把这张卡除外”的cost函数简单写法）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
-- 定义①效果的代价函数：判定这张卡能否作为cost从手卡/场上送去墓地，并执行送墓。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 执行代价：将这张卡送去墓地（REASON_COST）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 定义特殊召唤的过滤条件：选择持有「元素英雄」或「新空间侠」字段且能够被特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x3008,0x1f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义①效果的发动目标判定：确认自己怪兽区有空位，并且手卡/墓地存在1只符合条件的「元素英雄」或「新空间侠」怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认自己场上存在可用的怪兽区空格（计算这张卡作为cost送墓后腾出的空位）。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 发动时确认手卡/墓地存在至少1张满足特殊召唤条件的「元素英雄」或「新空间侠」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果将进行特殊召唤，数量为1，候选来源为手卡/墓地。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 定义①效果的实际处理：选择1只符合条件的怪兽以表侧表示特殊召唤；若该怪兽从墓地特殊召唤，则使其效果无效化。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查怪兽区是否还有空位，若没有空位则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 弹出选择提示，让玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡/墓地选择1只满足条件且不受王家长眠之谷影响的「元素英雄」或「新空间侠」怪兽（获取选中的第一张）。
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	-- 若成功选择怪兽，则将其以表侧表示进行特殊召唤（作为特殊召唤流程的一步）。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		and tc:IsPreviousLocation(LOCATION_GRAVE) then
		-- 这个效果从墓地特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果从墓地特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤流程，将之前用SpecialSummonStep累积的怪兽一同特殊召唤成功。
	Duel.SpecialSummonComplete()
end
-- 定义②效果的触发过滤器：检测是否有自己控制的表侧表示「元素英雄」融合怪兽特殊召唤成功，且该特殊召唤不是由本卡②效果自身引发。
function s.cfilter(c,tp,se)
	return c:IsFaceup() and c:IsSetCard(0x3008) and c:IsType(TYPE_FUSION) and c:IsSummonPlayer(tp)
		and (se==nil or c:GetReasonEffect()~=se)
end
-- 定义②效果的发动条件：当这张卡在墓地存在时，若有满足条件的「元素英雄」融合怪兽特殊召唤成功，则满足发动条件。
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.cfilter,1,nil,tp,se)
end
-- 定义②效果的发动目标：确认玩家可以抽2张卡，并设置抽2张、之后将1张手卡返回卡组的操作信息。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认玩家是否可以抽2张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将本次效果处理的对象玩家设置为发动者（抽卡玩家）。
	Duel.SetTargetPlayer(tp)
	-- 将本次效果处理的目标参数设置为2（抽卡数量）。
	Duel.SetTargetParam(2)
	-- 设置操作信息：将进行抽2张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	-- 设置操作信息：之后将把1张手卡返回卡组（来源为手卡）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 定义②效果的实际处理：抽取2张卡，若成功抽出2张，则洗切手卡并选择1张手卡返回卡组最下面。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时设置的目标玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡，若实际抽了2张才继续后续处理。
	if Duel.Draw(p,d,REASON_EFFECT)==2 then
		-- 洗切玩家手卡，确保接下来选择返回卡组的手卡是随机状态。
		Duel.ShuffleHand(p)
		-- 弹出选择提示，让玩家选择要返回卡组的卡。
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 从手卡中选择1张可以返回卡组的卡。
		local sg=Duel.SelectMatchingCard(p,Card.IsAbleToDeck,p,LOCATION_HAND,0,1,1,nil)
		if #sg>0 then
			-- 中断当前效果处理，使抽卡与回卡组视为不同时处理，避免错过时点。
			Duel.BreakEffect()
			-- 将选中的手卡返回持有者的卡组最下面（SEQ_DECKBOTTOM）。
			Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
