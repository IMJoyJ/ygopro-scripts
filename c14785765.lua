--BF－精鋭のゼピュロス
-- 效果：
-- 这个卡名的效果在决斗中只能使用1次。
-- ①：这张卡在墓地存在的场合，让自己场上1张表侧表示卡回到手卡才能发动。这张卡特殊召唤，自己受到400伤害。
function c14785765.initial_effect(c)
	-- ①：这张卡在墓地存在的场合，让自己场上1张表侧表示卡回到手卡才能发动。这张卡特殊召唤，自己受到400伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14785765,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,14785765+EFFECT_COUNT_CODE_DUEL)
	e1:SetCost(c14785765.cost)
	e1:SetTarget(c14785765.target)
	e1:SetOperation(c14785765.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于检查场上是否有可以作为cost送入手卡的表侧表示卡。
function c14785765.costfilter(c)
	return c:IsFaceup() and c:IsAbleToHandAsCost()
end
-- 设置效果的cost处理函数，用于支付将场上一张表侧表示卡送入手卡的代价。
function c14785765.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家当前场上可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then
		if ft<0 then return false end
		if ft==0 then
			-- 检查玩家场上是否存在至少1张满足条件的表侧表示卡。
			return Duel.IsExistingMatchingCard(c14785765.costfilter,tp,LOCATION_MZONE,0,1,nil)
		else
			-- 检查玩家场上（包括魔法陷阱区）是否存在至少1张满足条件的表侧表示卡。
			return Duel.IsExistingMatchingCard(c14785765.costfilter,tp,LOCATION_ONFIELD,0,1,nil)
		end
	end
	-- 向玩家提示选择要送入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	if ft==0 then
		-- 选择一张满足条件的场上表侧表示卡并将其送入手卡。
		local g=Duel.SelectMatchingCard(tp,c14785765.costfilter,tp,LOCATION_MZONE,0,1,1,nil)
		-- 将选中的卡送入手卡作为效果的代价。
		Duel.SendtoHand(g,nil,REASON_COST)
	else
		-- 选择一张满足条件的场上表侧表示卡并将其送入手卡。
		local g=Duel.SelectMatchingCard(tp,c14785765.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
		-- 将选中的卡送入手卡作为效果的代价。
		Duel.SendtoHand(g,nil,REASON_COST)
	end
end
-- 设置效果的目标处理函数，用于确定效果的目标。
function c14785765.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果操作信息，表明将特殊召唤此卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置效果操作信息，表明将对玩家造成400点伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,400)
end
-- 设置效果的发动处理函数，用于执行效果的主要操作。
function c14785765.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否能被特殊召唤，并执行特殊召唤操作。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 对玩家造成400点伤害。
		Duel.Damage(tp,400,REASON_EFFECT)
	end
end
