--ハーピィズペット竜－セイント・ファイアー・ギガ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己场上有6星以下的风属性怪兽存在的场合才能发动。这张卡从手卡守备表示特殊召唤。
-- ②：只要这张卡在怪兽区域存在，双方怪兽不能选择6星以下的「鹰身」怪兽作为攻击对象。
-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把1只鸟兽族·风属性怪兽送去墓地。
function c4991081.initial_effect(c)
	-- ①：自己场上有6星以下的风属性怪兽存在的场合才能发动。这张卡从手卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4991081,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,4991081)
	e1:SetCondition(c4991081.spcon)
	e1:SetTarget(c4991081.sptg)
	e1:SetOperation(c4991081.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，双方怪兽不能选择6星以下的「鹰身」怪兽作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetValue(c4991081.atlimit)
	c:RegisterEffect(e2)
	-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把1只鸟兽族·风属性怪兽送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4991081,1))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,4991082)
	e3:SetCondition(c4991081.tgcon)
	e3:SetTarget(c4991081.tgtg)
	e3:SetOperation(c4991081.tgop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否存在满足条件的风属性6星以下的怪兽
function c4991081.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND) and c:IsLevelBelow(6)
end
-- 效果发动的条件判断，检查自己场上是否有6星以下的风属性怪兽
function c4991081.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检索满足条件的卡片组
	return Duel.IsExistingMatchingCard(c4991081.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置特殊召唤的处理目标
function c4991081.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤的操作
function c4991081.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将卡片以守备表示特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 限制攻击对象的过滤函数，用于判断是否为6星以下的鹰身怪兽
function c4991081.atlimit(e,c)
	return c:IsFaceup() and c:IsLevelBelow(6) and c:IsSetCard(0x64)
end
-- 效果发动条件，判断此卡是否从场上送去墓地
function c4991081.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数，用于检索满足条件的鸟兽族风属性怪兽
function c4991081.tgfilter(c)
	return c:IsRace(RACE_WINDBEAST) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToGrave()
end
-- 设置送去墓地的效果处理目标
function c4991081.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检索满足条件的卡片组
	if chk==0 then return Duel.IsExistingMatchingCard(c4991081.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 执行将卡送去墓地的操作
function c4991081.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c4991081.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
