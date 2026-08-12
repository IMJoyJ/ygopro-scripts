--フェニックス・ギア・フリード
-- 效果：
-- ①：这张卡只要在场上·墓地存在，当作通常怪兽使用。
-- ②：可以把场上的当作通常怪兽使用的这张卡作为通常召唤作再1次召唤。那个场合这张卡变成当作效果怪兽使用并得到以下效果。
-- ●对方把魔法卡发动的场合，以自己墓地1只二重怪兽为对象才能发动。那只怪兽特殊召唤。
-- ●场上的怪兽为对象的魔法·陷阱卡发动时，把自己场上1张表侧表示的装备卡送去墓地才能发动。那个发动无效并破坏。
function c69488544.initial_effect(c)
	-- 为卡片c启用二重怪兽属性（使其在场上·墓地当作通常怪兽，并可以再度召唤）
	aux.EnableDualAttribute(c)
	-- ●对方把魔法卡发动的场合，以自己墓地1只二重怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69488544,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c69488544.spcon)
	e1:SetTarget(c69488544.sptg)
	e1:SetOperation(c69488544.spop)
	c:RegisterEffect(e1)
	-- ●场上的怪兽为对象的魔法·陷阱卡发动时，把自己场上1张表侧表示的装备卡送去墓地才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(69488544,1))  --"无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c69488544.negcon)
	e2:SetCost(c69488544.negcost)
	e2:SetTarget(c69488544.negtg)
	e2:SetOperation(c69488544.negop)
	c:RegisterEffect(e2)
end
-- 特殊召唤效果的发动条件判定函数
function c69488544.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 判定自身处于再度召唤状态，且对方发动了魔法卡（卡片发动）
		and aux.IsDualState(e) and rp==1-tp and re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 过滤自己墓地中可以特殊召唤的二重怪兽
function c69488544.filter(c,e,tp)
	return c:IsType(TYPE_DUAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动目标选择与检测函数
function c69488544.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c69488544.filter(chkc,e,tp) end
	-- 判定自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定自己墓地是否存在至少1只满足条件的二重怪兽
		and Duel.IsExistingTarget(c69488544.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只二重怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c69488544.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息，表明该效果包含特殊召唤操作，对象为选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的效果处理函数
function c69488544.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的特殊召唤对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 无效并破坏效果的发动条件判定函数
function c69488544.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定自身是否处于再度召唤状态，以及发动的效果是否取对象
	if not aux.IsDualState(e) or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁中被作为对象的所有卡片
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or not g:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE) then return false end
	-- 判定发动的效果是魔法·陷阱卡的发动，且该发动可以被无效
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 过滤自己场上表侧表示且可以送去墓地作为Cost的装备卡
function c69488544.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP) and c:IsAbleToGraveAsCost()
end
-- 无效并破坏效果的发动代价（Cost）处理函数
function c69488544.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定自己场上是否存在可以送去墓地的表侧表示装备卡
	if chk==0 then return Duel.IsExistingMatchingCard(c69488544.cfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择自己场上1张表侧表示的装备卡
	local g=Duel.SelectMatchingCard(tp,c69488544.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选择的装备卡送去墓地作为发动代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 无效并破坏效果的发动目标与操作信息设置函数
function c69488544.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁信息，表明该效果包含使发动无效的操作
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsDestructable() then
		-- 设置连锁信息，表明该效果包含破坏操作
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 无效并破坏效果的效果处理函数
function c69488544.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效该发动的效果，并判定该卡在效果处理时是否仍与该效果相关
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该卡
		Duel.Destroy(re:GetHandler(),REASON_EFFECT)
	end
end
