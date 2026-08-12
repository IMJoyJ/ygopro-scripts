--空牙団の叡智 ウィズ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。自己回复「空牙团的睿智 薇兹」以外的自己场上的「空牙团」怪兽种类×500基本分。
-- ②：对方把魔法·陷阱卡的效果发动时，从手卡丢弃1张「空牙团」卡才能发动。那个发动无效。
function c1527418.initial_effect(c)
	-- ①：这张卡特殊召唤的场合才能发动。自己回复「空牙团的睿智 薇兹」以外的自己场上的「空牙团」怪兽种类×500基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1527418,0))
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,1527418)
	e1:SetTarget(c1527418.rectg)
	e1:SetOperation(c1527418.recop)
	c:RegisterEffect(e1)
	-- ②：对方把魔法·陷阱卡的效果发动时，从手卡丢弃1张「空牙团」卡才能发动。那个发动无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1527418,1))
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,1527419)
	e2:SetCondition(c1527418.negcon)
	e2:SetCost(c1527418.negcost)
	e2:SetTarget(c1527418.negtg)
	e2:SetOperation(c1527418.negop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选场上正面表示的「空牙团」怪兽（不包括薇兹自身）
function c1527418.recfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x114) and not c:IsCode(1527418)
end
-- 效果处理时，检查场上是否存在满足条件的怪兽，并计算回复基本分
function c1527418.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c1527418.recfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 获取场上满足条件的怪兽数组
	local g=Duel.GetMatchingGroup(c1527418.recfilter,tp,LOCATION_MZONE,0,nil)
	local rec=g:GetClassCount(Card.GetCode)*500
	-- 设置效果处理时的回复基本分信息
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
-- 效果处理时，根据场上满足条件的怪兽数量计算并回复基本分
function c1527418.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上满足条件的怪兽数组
	local g=Duel.GetMatchingGroup(c1527418.recfilter,tp,LOCATION_MZONE,0,nil)
	local rec=g:GetClassCount(Card.GetCode)*500
	-- 使玩家回复计算出的基本分
	Duel.Recover(tp,rec,REASON_EFFECT)
end
-- 效果发动条件，判断对方发动魔法或陷阱卡且该连锁可被无效
function c1527418.negcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 对方发动的是魔法或陷阱卡且该连锁可被无效
		and ep~=tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
-- 过滤函数，用于筛选手牌或墓地中的「空牙团」卡作为代价
function c1527418.cfilter(c,e,tp)
	if c:IsLocation(LOCATION_HAND) then
		return c:IsSetCard(0x114) and c:IsDiscardable()
	else
		return e:GetHandler():IsSetCard(0x114) and c:IsAbleToRemoveAsCost() and c:IsHasEffect(53557529,tp)
	end
end
-- 效果处理时，选择并处理丢弃或除外一张「空牙团」卡作为代价
function c1527418.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌或墓地是否存在满足条件的「空牙团」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c1527418.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要丢弃的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	-- 选择一张满足条件的「空牙团」卡作为代价
	local g=Duel.SelectMatchingCard(tp,c1527418.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	local te=tc:IsHasEffect(53557529,tp)
	if te then
		te:UseCountLimit(tp)
		-- 将该卡从游戏中除外（替换效果）
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
	else
		-- 将该卡送入墓地（丢弃效果）
		Duel.SendtoGrave(tc,REASON_COST+REASON_DISCARD)
	end
end
-- 设置效果处理时的无效发动信息
function c1527418.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理时的无效发动信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 效果处理时，使对方的连锁发动无效
function c1527418.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使对方的连锁发动无效
	Duel.NegateActivation(ev)
end
