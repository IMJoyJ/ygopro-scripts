--守護神官マナ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在，只以自己场上的魔法师族怪兽1只为对象的对方的魔法·陷阱·怪兽的效果发动时才能发动。这张卡特殊召唤。
-- ②：只要这张卡在怪兽区域存在，自己场上的7星以上的魔法师族怪兽不会被效果破坏。
-- ③：这张卡被战斗·效果破坏的场合才能发动。从自己的手卡·卡组·墓地选1只「黑魔术少女」特殊召唤。
function c42006475.initial_effect(c)
	-- 注册卡片效果中涉及的其他卡名，用于识别「黑魔术少女」
	aux.AddCodeList(c,38033121)
	-- ①：这张卡在手卡·墓地存在，只以自己场上的魔法师族怪兽1只为对象的对方的魔法·陷阱·怪兽的效果发动时才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42006475,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,42006475)
	e1:SetCondition(c42006475.spcon)
	e1:SetTarget(c42006475.sptg)
	e1:SetOperation(c42006475.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己场上的7星以上的魔法师族怪兽不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c42006475.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗·效果破坏的场合才能发动。从自己的手卡·卡组·墓地选1只「黑魔术少女」特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c42006475.spcon2)
	e3:SetTarget(c42006475.sptg2)
	e3:SetOperation(c42006475.spop2)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否存在己方正面表示的魔法师族怪兽
function c42006475.tfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_SPELLCASTER)
end
-- 效果发动时的条件判断函数，检查是否满足①效果的发动条件
function c42006475.spcon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的目标卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:GetCount()==1 and g:IsExists(c42006475.tfilter,1,nil,tp)
end
-- 设置①效果的发动时点处理目标
function c42006475.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足特殊召唤的条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理时的提示信息，表示将特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理函数，将此卡特殊召唤到场上
function c42006475.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤操作，将此卡以正面表示特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤函数，用于判断是否为7星以上魔法师族怪兽
function c42006475.indtg(e,c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsLevelAbove(7)
end
-- ③效果的发动条件判断函数，检查是否为战斗或效果破坏
function c42006475.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 过滤函数，用于筛选「黑魔术少女」卡牌
function c42006475.spfilter(c,e,tp)
	return c:IsCode(38033121) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置③效果的发动时点处理目标
function c42006475.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足特殊召唤的条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌、卡组、墓地是否存在「黑魔术少女」
		and Duel.IsExistingMatchingCard(c42006475.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果处理时的提示信息，表示将特殊召唤「黑魔术少女」
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- ③效果的处理函数，从手牌、卡组、墓地选择并特殊召唤「黑魔术少女」
function c42006475.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「黑魔术少女」卡牌
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c42006475.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 执行特殊召唤操作，将选中的卡牌以正面表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
