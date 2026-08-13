--海晶乙女スプリンガール
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己墓地把1只「海晶少女」怪兽除外才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡作为水属性连接怪兽的连接素材送去墓地的场合才能发动。把自己场上的「海晶少女」怪兽数量的卡从自己卡组上面送去墓地。这个效果让「海晶少女」卡被送去墓地的场合，再给与对方那些「海晶少女」卡数量×200伤害。
function c21057444.initial_effect(c)
	-- ①：从自己墓地把1只「海晶少女」怪兽除外才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21057444,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,21057444)
	e1:SetCost(c21057444.spcost)
	e1:SetTarget(c21057444.sptg)
	e1:SetOperation(c21057444.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡作为水属性连接怪兽的连接素材送去墓地的场合才能发动。把自己场上的「海晶少女」怪兽数量的卡从自己卡组上面送去墓地。这个效果让「海晶少女」卡被送去墓地的场合，再给与对方那些「海晶少女」卡数量×200伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21057444,1))
	e2:SetCategory(CATEGORY_DECKDES+CATEGORY_TOGRAVE+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,21057445)
	e2:SetCondition(c21057444.tgcon)
	e2:SetTarget(c21057444.tgtg)
	e2:SetOperation(c21057444.tgop)
	c:RegisterEffect(e2)
end
-- 筛选可作为代价除外、且为怪兽、属于「海晶少女」字段的墓地卡片，作为①的代价素材。
function c21057444.cfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x12b)
end
-- ①的代价处理：从自己墓地把1只符合条件的「海晶少女」怪兽表侧除外作为发动代价。
function c21057444.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：自己墓地是否存在至少1张符合条件的「海晶少女」怪兽可以除外。
	if chk==0 then return Duel.IsExistingMatchingCard(c21057444.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1张满足条件的「海晶少女」怪兽作为代价对象。
	local sg=Duel.SelectMatchingCard(tp,c21057444.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的怪兽表侧表示除外，作为代价处理。
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- ①的发动目标检查：自己主要怪兽区有空位，且这张卡可以被特殊召唤。
function c21057444.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用于特殊召唤的主要怪兽区空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，标明本效果将特殊召唤这张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①的效果处理：这张卡仍与效果相关时，将其从手卡特殊召唤。
function c21057444.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 实际执行特殊召唤，将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②的发动条件：这张卡作为水属性连接怪兽的连接素材被送去墓地且当前在墓地。
function c21057444.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_LINK and c:GetReasonCard():IsAttribute(ATTRIBUTE_WATER)
end
-- 筛选自己场上表侧表示且属于「海晶少女」字段的怪兽，用于计算从卡组送墓的数量。
function c21057444.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12b)
end
-- ②的发动目标：统计自己场上「海晶少女」怪兽数量，检查能否从卡组顶送墓相应数量，并设置操作信息。
function c21057444.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 统计自己场上表侧表示「海晶少女」怪兽的数量。
	local ct=Duel.GetMatchingGroupCount(c21057444.ctfilter,tp,LOCATION_MZONE,0,nil)
	-- 发动可行性检查：场上存在「海晶少女」怪兽且卡组顶至少可以送墓对应数量的卡。
	if chk==0 then return ct>0 and Duel.IsPlayerCanDiscardDeck(tp,ct) end
	-- 设置操作信息，标明本效果将把卡组顶部的对应数量卡牌送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,ct)
end
-- 筛选被送去墓地的卡中属于「海晶少女」字段的卡，用于后续伤害计算。
function c21057444.ctfilter2(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsSetCard(0x12b)
end
-- ②的效果处理：再次统计自己场上「海晶少女」怪兽数量，从卡组顶送墓等量卡，并计算其中「海晶少女」卡的数量给与对方伤害。
function c21057444.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次获取当前自己场上表侧表示「海晶少女」怪兽的数量，作为从卡组顶送墓的张数。
	local ct1=Duel.GetMatchingGroupCount(c21057444.ctfilter,tp,LOCATION_MZONE,0,nil)
	if ct1>0 then
		-- 将自己卡组顶部的对应数量卡牌送去墓地，确认实际送墓成功。
		if Duel.DiscardDeck(tp,ct1,REASON_EFFECT)~=0 then
			-- 获取因这个效果实际送去墓地的全部卡牌。
			local og=Duel.GetOperatedGroup()
			local ct2=og:FilterCount(c21057444.ctfilter2,nil)
			if ct2>0 then
				-- 给予对方玩家被送去墓地的「海晶少女」卡数量×200的伤害。
				Duel.Damage(1-tp,ct2*200,REASON_EFFECT)
			end
		end
	end
end
