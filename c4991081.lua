--ハーピィズペット竜－セイント・ファイアー・ギガ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己场上有6星以下的风属性怪兽存在的场合才能发动。这张卡从手卡守备表示特殊召唤。
-- ②：只要这张卡在怪兽区域存在，双方怪兽不能选择6星以下的「鹰身」怪兽作为攻击对象。
-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把1只鸟兽族·风属性怪兽送去墓地。
function c4991081.initial_effect(c)
	-- 这个卡名的①③的效果1回合各能使用1次。①：自己场上有6星以下的风属性怪兽存在的场合才能发动。这张卡从手卡守备表示特殊召唤。
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
	-- 这个卡名的①③的效果1回合各能使用1次。③：这张卡从场上送去墓地的场合才能发动。从卡组把1只鸟兽族·风属性怪兽送去墓地。
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
-- 判定怪兽是否为表侧表示、风属性且6星以下，作为①效果发动条件的筛选条件。
function c4991081.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND) and c:IsLevelBelow(6)
end
-- ①效果的发动条件，检查自己场上是否存在至少1只表侧表示、风属性且6星以下的怪兽。
function c4991081.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示、风属性且6星以下的怪兽。
	return Duel.IsExistingMatchingCard(c4991081.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果发动时的合法性检查，若自己主要怪兽区有空位且这张卡可以表侧守备表示特殊召唤则返回true。
function c4991081.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区域是否存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置连锁处理信息，分类为特殊召唤，对象为这张卡，数量1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理时，若这张卡仍与效果关联，则将其从手牌以表侧守备表示特殊召唤到自己场上。
function c4991081.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧守备表示特殊召唤到持有者场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 判定候选攻击对象是否为表侧表示、6星以下且属于「鹰身」系列，若是则不能被选择为攻击对象。
function c4991081.atlimit(e,c)
	return c:IsFaceup() and c:IsLevelBelow(6) and c:IsSetCard(0x64)
end
-- 判定这张卡之前的位置为场上，即满足从场上被送去墓地的条件。
function c4991081.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 判定卡组中的卡是否为鸟兽族、风属性且可以被送去墓地，作为③效果的选择条件。
function c4991081.tgfilter(c)
	return c:IsRace(RACE_WINDBEAST) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToGrave()
end
-- ③效果发动时确认卡组存在符合条件的怪兽，并设置连锁信息为从卡组将1张卡送去墓地。
function c4991081.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在至少1张鸟兽族·风属性且可送去墓地的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c4991081.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息，分类为送去墓地，数量1，来源为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理时，从卡组选择1只鸟兽族·风属性且可送去墓地的怪兽送去墓地。
function c4991081.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要送去墓地的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己卡组选择1张鸟兽族·风属性且可送去墓地的卡。
	local g=Duel.SelectMatchingCard(tp,c4991081.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
