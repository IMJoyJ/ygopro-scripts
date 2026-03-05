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
-- 过滤函数，用于检查墓地是否满足条件的「海晶少女」怪兽（可除外作为cost）
function c21057444.cfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x12b)
end
-- 效果处理：检查是否满足除外条件并选择1只「海晶少女」怪兽除外作为发动cost
function c21057444.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足除外条件
	if chk==0 then return Duel.IsExistingMatchingCard(c21057444.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1只「海晶少女」怪兽
	local sg=Duel.SelectMatchingCard(tp,c21057444.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡除外作为发动cost
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- 效果处理：检查是否满足特殊召唤条件
function c21057444.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：执行特殊召唤
function c21057444.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 条件函数：判断此卡是否作为水属性连接怪兽的素材被送去墓地
function c21057444.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_LINK and c:GetReasonCard():IsAttribute(ATTRIBUTE_WATER)
end
-- 过滤函数，用于统计场上「海晶少女」怪兽数量
function c21057444.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12b)
end
-- 效果处理：检查是否满足发动条件并设置处理信息
function c21057444.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 统计场上「海晶少女」怪兽数量
	local ct=Duel.GetMatchingGroupCount(c21057444.ctfilter,tp,LOCATION_MZONE,0,nil)
	-- 检查是否满足发动条件
	if chk==0 then return ct>0 and Duel.IsPlayerCanDiscardDeck(tp,ct) end
	-- 设置丢弃卡组的处理信息
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,ct)
end
-- 过滤函数，用于统计被送去墓地的「海晶少女」卡数量
function c21057444.ctfilter2(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsSetCard(0x12b)
end
-- 效果处理：执行丢弃卡组并造成伤害
function c21057444.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 统计场上「海晶少女」怪兽数量
	local ct1=Duel.GetMatchingGroupCount(c21057444.ctfilter,tp,LOCATION_MZONE,0,nil)
	if ct1>0 then
		-- 将场上数量的卡从卡组丢弃到墓地
		if Duel.DiscardDeck(tp,ct1,REASON_EFFECT)~=0 then
			-- 获取实际被丢弃的卡组
			local og=Duel.GetOperatedGroup()
			local ct2=og:FilterCount(c21057444.ctfilter2,nil)
			if ct2>0 then
				-- 对对方造成伤害
				Duel.Damage(1-tp,ct2*200,REASON_EFFECT)
			end
		end
	end
end
