--幻影騎士団ティアースケイル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：丢弃1张手卡才能发动。除「幻影骑士团 破洞鳞甲」外的1只「幻影骑士团」怪兽或1张「幻影」魔法·陷阱卡从卡组送去墓地。
-- ②：这张卡在墓地存在，从自己墓地有其他的「幻影骑士团」怪兽或「幻影」魔法·陷阱卡被除外的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c25538345.initial_effect(c)
	-- ①：丢弃1张手卡才能发动。除「幻影骑士团 破洞鳞甲」外的1只「幻影骑士团」怪兽或1张「幻影」魔法·陷阱卡从卡组送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25538345,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,25538345)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c25538345.sgcost)
	e1:SetTarget(c25538345.sgtg)
	e1:SetOperation(c25538345.sgop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，从自己墓地有其他的「幻影骑士团」怪兽或「幻影」魔法·陷阱卡被除外的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25538345,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,25538346)
	e2:SetCondition(c25538345.sscon)
	e2:SetTarget(c25538345.sstg)
	e2:SetOperation(c25538345.ssop)
	c:RegisterEffect(e2)
end
-- 检查玩家手牌是否存在可丢弃的卡牌，若存在则丢弃1张手牌作为效果的发动代价。
function c25538345.sgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌是否存在可丢弃的卡牌，若存在则返回true。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃玩家手牌中满足Card.IsDiscardable条件的1张卡作为效果的发动代价。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义过滤函数，用于筛选卡组中除自身外的「幻影骑士团」怪兽或「幻影」魔法·陷阱卡。
function c25538345.filter(c)
	return not c:IsCode(25538345) and ((c:IsSetCard(0x10db) and c:IsType(TYPE_MONSTER)) or (c:IsSetCard(0xdb) and c:IsType(TYPE_SPELL+TYPE_TRAP)))
		and c:IsAbleToGrave()
end
-- 检查玩家卡组中是否存在满足过滤条件的卡牌，若存在则设置效果处理信息为将1张卡送去墓地。
function c25538345.sgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查玩家卡组中是否存在满足过滤条件的卡牌，若存在则返回true。
	if chk==0 then return Duel.IsExistingMatchingCard(c25538345.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息，表示将1张卡从卡组送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 提示玩家选择要送去墓地的卡牌，并将选中的卡牌送去墓地。
function c25538345.sgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从玩家卡组中选择满足过滤条件的1张卡作为目标。
	local g=Duel.SelectMatchingCard(tp,c25538345.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡牌送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 定义过滤函数，用于筛选从墓地被除外的「幻影骑士团」怪兽或「幻影」魔法·陷阱卡。
function c25538345.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp)
		and ((c:IsSetCard(0x10db) and c:IsType(TYPE_MONSTER)) or (c:IsSetCard(0xdb) and c:IsType(TYPE_SPELL+TYPE_TRAP)))
end
-- 判断除外的卡牌是否满足过滤条件，若满足则返回true。
function c25538345.sscon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c25538345.cfilter,1,nil,tp)
end
-- 检查玩家场上是否有空位，并判断该卡是否可以特殊召唤。
function c25538345.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息，表示将该卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 将该卡特殊召唤到场上，并设置其离开场上的处理为除外。
function c25538345.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断该卡是否与效果相关联，并将其特殊召唤到场上。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 设置该卡从场上离开时被除外的效果。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
