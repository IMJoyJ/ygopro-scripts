--聖殿の水遣い
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己场上有「勇者衍生物」存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：把手卡·墓地的这张卡除外才能发动。从自己的卡组·墓地把1张「阿拉弥赛亚之仪」加入手卡。
-- ③：自己场上有「勇者衍生物」存在的场合才能发动。把有「勇者衍生物」的衍生物名记述的1张场地魔法卡从卡组到自己场上表侧表示放置。
function c30680659.initial_effect(c)
	-- 记录该卡具有「勇者衍生物」的卡名信息
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
-- 过滤函数，用于检测场上是否存在正面表示的「勇者衍生物」
function c30680659.cfilter(c)
	return c:IsCode(3285552) and c:IsFaceup()
end
-- 判断条件函数，用于判断是否满足发动效果的条件（场上有「勇者衍生物」）
function c30680659.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检测场上是否存在至少1张正面表示的「勇者衍生物」
	return Duel.IsExistingMatchingCard(c30680659.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 设置特殊召唤效果的目标函数，检查是否满足特殊召唤的条件
function c30680659.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理函数，将卡片特殊召唤到场上
function c30680659.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行将卡片特殊召唤到场上的操作
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 检索或回收效果的费用支付函数，将自身从手牌或墓地除外
function c30680659.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将自身从手牌或墓地除外作为费用
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 过滤函数，用于检索「阿拉弥赛亚之仪」
function c30680659.thfilter(c)
	return c:IsCode(3285551) and c:IsAbleToHand()
end
-- 设置检索或回收效果的目标函数，检查是否满足检索条件
function c30680659.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测卡组或墓地是否存在至少1张「阿拉弥赛亚之仪」
	if chk==0 then return Duel.IsExistingMatchingCard(c30680659.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置检索或回收效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 检索或回收效果的处理函数，选择并加入手牌
function c30680659.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组或墓地选择1张「阿拉弥赛亚之仪」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c30680659.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数，用于筛选带有「勇者衍生物」衍生物名记述的场地魔法卡
function c30680659.stfilter(c,tp)
	-- 判断卡片是否带有「勇者衍生物」衍生物名记述且为场地魔法卡
	return aux.IsCodeListed(c,3285552) and c:IsType(TYPE_FIELD) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 设置场地魔法卡放置效果的目标函数，检查是否满足放置条件
function c30680659.stg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测卡组是否存在至少1张符合条件的场地魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c30680659.stfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- 场地魔法卡放置效果的处理函数，选择并放置到场上
function c30680659.sop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组选择1张符合条件的场地魔法卡
	local tc=Duel.SelectMatchingCard(tp,c30680659.stfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 获取玩家场上已存在的场地魔法卡
		local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
		if fc then
			-- 将已存在的场地魔法卡送入墓地
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果，使后续处理视为错时点
			Duel.BreakEffect()
		end
		-- 将选中的场地魔法卡放置到场上
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end
