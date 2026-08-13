--聖殿の水遣い
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己场上有「勇者衍生物」存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：把手卡·墓地的这张卡除外才能发动。从自己的卡组·墓地把1张「阿拉弥赛亚之仪」加入手卡。
-- ③：自己场上有「勇者衍生物」存在的场合才能发动。把有「勇者衍生物」的衍生物名记述的1张场地魔法卡从卡组到自己场上表侧表示放置。
function c30680659.initial_effect(c)
	-- 将卡名「勇者衍生物」（3285552）登记为此卡效果文本中记述的卡名，用于后续「有勇者衍生物名记述的卡」的检索。
	aux.AddCodeList(c,3285552)
	-- ①：自己场上有「勇者衍生物」存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30680659,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,30680659)
	e1:SetCondition(c30680659.condition)
	e1:SetTarget(c30680659.sptg)
	e1:SetOperation(c30680659.spop)
	c:RegisterEffect(e1)
	-- ②：把手卡·墓地的这张卡除外才能发动。从自己的卡组·墓地把1张「阿拉弥赛亚之仪」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30680659,1))  --"检索或回收"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCountLimit(1,30680660)
	e2:SetCost(c30680659.thcost)
	e2:SetTarget(c30680659.thtg)
	e2:SetOperation(c30680659.thop)
	c:RegisterEffect(e2)
	-- ③：自己场上有「勇者衍生物」存在的场合才能发动。把有「勇者衍生物」的衍生物名记述的1张场地魔法卡从卡组到自己场上表侧表示放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(30680659,2))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,30680661)
	e3:SetCondition(c30680659.condition)
	e3:SetTarget(c30680659.stg)
	e3:SetOperation(c30680659.sop)
	c:RegisterEffect(e3)
end
-- 判断卡片是否为卡号3285552（勇者衍生物）且处于表侧表示，用于确认场上存在勇者衍生物。
function c30680659.cfilter(c)
	return c:IsCode(3285552) and c:IsFaceup()
end
-- 检查己方场上是否存在至少1张表侧表示的勇者衍生物，作为效果的发动条件。
function c30680659.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 从己方场上所有区域中检索是否存在至少1张满足cfilter的卡（勇者衍生物且表侧表示）。
	return Duel.IsExistingMatchingCard(c30680659.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 特殊召唤的发动目标：确认己方主要怪兽区有空位，且这张卡自身可以被效果特殊召唤（满足召唤条件和苏生限制）。
function c30680659.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认己方主要怪兽区可用空格数大于0。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁的特殊召唤操作信息，指定特殊召唤对象为这张卡本身，供其他效果检测该效果包含特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与发动的效果保持关联，则将其特殊召唤。
function c30680659.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 在检查召唤条件与苏生限制的前提下，以表侧表示将这张卡特殊召唤到己方场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 代价处理：确认这张卡可以从手卡·墓地除外作为代价，然后将其以表侧表示除外来支付发动代价。
function c30680659.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将这张卡从手卡·墓地以表侧表示除外（REASON_COST），作为②效果的发动代价。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 检索过滤器：目标是卡号为3285551（阿拉弥赛亚之仪）且能够加入手卡的卡。
function c30680659.thfilter(c)
	return c:IsCode(3285551) and c:IsAbleToHand()
end
-- ②的发动目标：确认卡组·墓地存在至少1张阿拉弥赛亚之仪，并设置操作信息为将1张卡加入手卡。
function c30680659.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方卡组·墓地中是否存在至少1张符合条件的阿拉弥赛亚之仪。
	if chk==0 then return Duel.IsExistingMatchingCard(c30680659.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：本次效果处理要把1张卡加入手卡，目标来源为卡组·墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：让玩家从卡组·墓地选择1张阿拉弥赛亚之仪加入手卡，并向对方展示。
function c30680659.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给出选择提示文本“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组·墓地选择1张满足thfilter的卡，并过滤掉会受王家长眠之谷影响而无法移动的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c30680659.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果理由加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示刚刚加入手卡的卡片，以确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 场地魔法卡的过滤器：效果文本中记述有勇者衍生物、类型为场地魔法、不在禁止名单中，且满足场上同名卡放置限制。
function c30680659.stfilter(c,tp)
	-- 具体条件：卡名记述了勇者衍生物(3285552)、是场地魔法、未被禁止、并且可以在己方场上再放置一张。
	return aux.IsCodeListed(c,3285552) and c:IsType(TYPE_FIELD) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- ③的发动目标：确认卡组中存在至少1张符合条件的场地魔法卡。
function c30680659.stg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在至少1张满足stfilter的场地魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c30680659.stfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- 效果处理：从卡组选择1张符合条件的场地魔法卡；若场地区已有卡则先规则送墓，再把新场地表侧放置到场地区。
function c30680659.sop(e,tp,eg,ep,ev,re,r,rp)
	-- 给出选择提示文本“请选择要放置到场上的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组选择1张符合条件的场地魔法卡并取得该卡。
	local tc=Duel.SelectMatchingCard(tp,c30680659.stfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 获取己方场地区域（魔法陷阱区第6格，seq=5）当前的卡片，用于处理旧场地替换。
		local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
		if fc then
			-- 如果场地区域已有卡片，以规则理由将其送去墓地。
			Duel.SendtoGrave(fc,REASON_RULE)
			-- Duel.BreakEffect：中断当前效果处理，使后续放置新场地不与旧场地送墓视为同时处理，避免造成时点问题。
			Duel.BreakEffect()
		end
		-- 将选中的场地魔法卡以表侧表示移动到己方场地区域，并立即适用其效果。
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end
