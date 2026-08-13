--BF－精鋭のゼピュロス
-- 效果：
-- 这个卡名的效果在决斗中只能使用1次。
-- ①：这张卡在墓地存在的场合，让自己场上1张表侧表示卡回到手卡才能发动。这张卡特殊召唤，自己受到400伤害。
function c14785765.initial_effect(c)
	-- 这个卡名的效果在决斗中只能使用1次。①：这张卡在墓地存在的场合，让自己场上1张表侧表示卡回到手卡才能发动。这张卡特殊召唤，自己受到400伤害。
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
-- 费用筛选函数：判定卡是否表侧表示且可以作为代价返回手卡。
function c14785765.costfilter(c)
	return c:IsFaceup() and c:IsAbleToHandAsCost()
end
-- 费用处理：发动前根据主怪兽区空格数判断可选范围；若主怪兽区无空位则只能从主怪兽区选1张，否则从整个场上选1张，将其返回手卡作为代价。
function c14785765.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前玩家主怪兽区的可用空格数量，用于决定代价选择范围。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then
		if ft<0 then return false end
		if ft==0 then
			-- 当主怪兽区没有空格时，检查自己主怪兽区是否存在至少1张满足费用筛选条件的卡，以满足发动条件。
			return Duel.IsExistingMatchingCard(c14785765.costfilter,tp,LOCATION_MZONE,0,1,nil)
		else
			-- 当主怪兽区有空位时，检查自己场上是否存在至少1张满足费用筛选条件的卡，以满足发动条件。
			return Duel.IsExistingMatchingCard(c14785765.costfilter,tp,LOCATION_ONFIELD,0,1,nil)
		end
	end
	-- 显示提示消息，让当前玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	if ft==0 then
		-- 在主怪兽区无空位的情况下，选择自己主怪兽区1张满足条件的卡作为返回手牌的代价。
		local g=Duel.SelectMatchingCard(tp,c14785765.costfilter,tp,LOCATION_MZONE,0,1,1,nil)
		-- 将选择的卡返回持有者手卡，该操作作为发动代价。
		Duel.SendtoHand(g,nil,REASON_COST)
	else
		-- 在主怪兽区有空位的情况下，选择自己场上1张满足条件的卡作为返回手牌的代价。
		local g=Duel.SelectMatchingCard(tp,c14785765.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
		-- 将选择的卡返回持有者手卡，该操作作为发动代价。
		Duel.SendtoHand(g,nil,REASON_COST)
	end
end
-- 目标函数：判断这张卡能否被特殊召唤；若可以，则设置本次连锁处理的信息为特殊召唤这张卡并给予自己400点伤害。
function c14785765.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理信息：将这张卡本身作为特殊召唤的对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置连锁处理信息：对当前玩家造成400点效果伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,400)
end
-- 效果处理：若这张卡仍与效果关联，将其表侧表示特殊召唤到自己场上；特殊召唤成功后再给予自己400点效果伤害。
function c14785765.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定这张卡是否仍与发动时的效果相关联，并尝试将其以表侧表示特殊召唤到自己场上，且特殊召唤成功。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 给予当前玩家400点效果伤害。
		Duel.Damage(tp,400,REASON_EFFECT)
	end
end
