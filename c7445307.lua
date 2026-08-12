--デュアル・アセンブルム
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，从手卡以及自己场上的表侧表示怪兽之中把2只电子界族怪兽除外才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡的攻击力变成一半。
-- ②：1回合1次，把1张手卡除外才能发动。选持有这张卡的攻击力以下的攻击力的场上1只怪兽除外。
function c7445307.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡在手卡·墓地存在的场合，从手卡以及自己场上的表侧表示怪兽之中把2只电子界族怪兽除外才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡的攻击力变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7445307,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE+LOCATION_HAND)
	e1:SetCountLimit(1,7445307)
	e1:SetCost(c7445307.spcost)
	e1:SetTarget(c7445307.sptg)
	e1:SetOperation(c7445307.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把1张手卡除外才能发动。选持有这张卡的攻击力以下的攻击力的场上1只怪兽除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(7445307,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c7445307.rmcost)
	e2:SetTarget(c7445307.rmtg)
	e2:SetOperation(c7445307.rmop)
	c:RegisterEffect(e2)
end
-- 过滤手牌或场上表侧表示的、可以作为代价除外的电子界族怪兽
function c7445307.cfilter(c)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsRace(RACE_CYBERSE) and c:IsAbleToRemoveAsCost()
end
-- 过滤自己主要怪兽区域的怪兽
function c7445307.mzfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5
end
-- 效果①的发动代价，从手卡·场上表侧表示怪兽中将2只电子界族怪兽除外（包含处理怪兽区域格子不足时的特殊除外逻辑）
function c7445307.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取手牌及自己场上表侧表示的、除自身以外可作为代价除外的电子界族怪兽组
	local rg=Duel.GetMatchingGroup(c7445307.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,c)
	-- 获取自己场上可用怪兽区域的数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ct=-ft+1
	if chk==0 then return ft>-2 and rg:GetCount()>1 and (ft>0 or rg:IsExists(c7445307.mzfilter,ct,nil,tp)) end
	local g=nil
	if ft>0 then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		g=rg:Select(tp,2,2,nil)
	elseif ft==0 then
		-- 提示玩家选择要除外的卡（格子不足时，必须先选择1只场上的怪兽以腾出格子）
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		g=rg:FilterSelect(tp,c7445307.mzfilter,1,1,nil,tp)
		-- 提示玩家选择第2张要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local g2=rg:Select(tp,1,1,g:GetFirst())
		g:Merge(g2)
	else
		-- 提示玩家选择要除外的卡（格子不足且需要腾出2个格子时，必须选择2只场上的怪兽）
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		g=rg:FilterSelect(tp,c7445307.mzfilter,2,2,nil,tp)
	end
	-- 将选中的卡作为发动代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果①的发动准备，检查自身是否能特殊召唤，并设置特殊召唤的操作信息
function c7445307.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理，将自身特殊召唤，并使其攻击力变成一半
function c7445307.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 尝试将自身以表侧表示特殊召唤
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		local atk=c:GetAttack()
		-- 这个效果特殊召唤的这张卡的攻击力变成一半。②：1回合1次，把1张手卡除外才能发动。选持有这张卡的攻击力以下的攻击力的场上1只怪兽除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(atk/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
	end
	-- 完成特殊召唤的处理
	Duel.SpecialSummonComplete()
end
-- 过滤场上表侧表示、攻击力在自身攻击力以下且可以被除外的怪兽
function c7445307.rmfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk) and c:IsAbleToRemove()
end
-- 效果②的发动代价，将1张手牌除外
function c7445307.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可以作为代价除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要除外的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择1张手牌作为代价
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的手牌作为发动代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的发动准备，检查场上是否存在满足条件的怪兽，并设置除外的操作信息
function c7445307.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在攻击力在自身攻击力以下的表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c7445307.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e:GetHandler():GetAttack()) end
	-- 获取场上所有攻击力在自身攻击力以下的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c7445307.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e:GetHandler():GetAttack())
	-- 设置除外1张场上怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果②的效果处理，选择场上1只攻击力在自身攻击力以下的怪兽除外
function c7445307.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的场上怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择1只攻击力在自身攻击力以下的场上表侧表示怪兽
	local g=Duel.SelectMatchingCard(tp,c7445307.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e:GetHandler():GetAttack())
	if g:GetCount()>0 then
		-- 选中目标怪兽并显示选择动画
		Duel.HintSelection(g)
		-- 将选中的怪兽表侧表示除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
