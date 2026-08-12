--クリスタル・ローズ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，自己主要阶段才能发动。从手卡·卡组把1只「宝石骑士」怪兽或「幻奏」怪兽送去墓地。这张卡直到结束阶段当作和送去墓地的怪兽同名卡使用。
-- ②：这张卡在墓地存在的场合，从自己墓地把1只融合怪兽除外才能发动。这张卡守备表示特殊召唤。
function c79531196.initial_effect(c)
	-- ①：1回合1次，自己主要阶段才能发动。从手卡·卡组把1只「宝石骑士」怪兽或「幻奏」怪兽送去墓地。这张卡直到结束阶段当作和送去墓地的怪兽同名卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c79531196.tgtg)
	e1:SetOperation(c79531196.tgop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，从自己墓地把1只融合怪兽除外才能发动。这张卡守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,79531196)
	e2:SetCost(c79531196.spcost)
	e2:SetTarget(c79531196.sptg)
	e2:SetOperation(c79531196.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡·卡组中可以送去墓地的「宝石骑士」或「幻奏」怪兽
function c79531196.filter(c)
	return c:IsSetCard(0x1047,0x9b) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 效果①的发动准备与检测：检查手卡·卡组是否存在满足条件的怪兽，并设置送去墓地的操作信息
function c79531196.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡或卡组是否存在至少1只可以送去墓地的「宝石骑士」或「幻奏」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c79531196.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil) end
	-- 设置连锁处理的操作信息：从手卡或卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果①的效果处理：将选中的怪兽送去墓地，并使这张卡直到结束阶段当作同名卡使用，同时注册结束阶段重置同名效果的延迟事件
function c79531196.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从手卡或卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c79531196.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	-- 检查是否成功将选中的怪兽送去墓地且该卡确实存在于墓地
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE)
		and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡直到结束阶段当作和送去墓地的怪兽同名卡使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(tc:GetCode())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		-- 这张卡直到结束阶段当作和送去墓地的怪兽同名卡使用。
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(79531196,0))
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e2:SetCountLimit(1)
		e2:SetRange(LOCATION_MZONE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetLabelObject(e1)
		e2:SetOperation(c79531196.rstop)
		c:RegisterEffect(e2)
	end
end
-- 结束阶段重置同名效果的延迟处理：手动重置改变卡名的效果，并向双方玩家展示提示
function c79531196.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=e:GetLabelObject()
	e1:Reset()
	-- 在场上闪烁显示这张卡，提示玩家该卡的效果正在发生变化（重置）
	Duel.HintSelection(Group.FromCards(c))
	-- 向对方玩家提示“对方选择了：重置同名效果”
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 过滤条件：自己墓地中可以作为cost除外的融合怪兽
function c79531196.cfilter(c)
	return c:IsType(TYPE_FUSION) and c:IsAbleToRemoveAsCost()
end
-- 效果②的发动代价：从自己墓地选择1只融合怪兽除外
function c79531196.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只可以除外的融合怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c79531196.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从自己墓地选择1只融合怪兽
	local g=Duel.SelectMatchingCard(tp,c79531196.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的融合怪兽表侧表示除外作为发动的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的发动准备与检测：检查自己场上是否有空位且这张卡是否可以特殊召唤，并设置特殊召唤的操作信息
function c79531196.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置连锁处理的操作信息：将这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理：如果这张卡仍存在于墓地，则将其守备表示特殊召唤
function c79531196.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡以表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
