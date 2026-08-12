--一族の結集
-- 效果：
-- ①：以场上1只表侧表示怪兽为对象才能发动。从自己的手卡·墓地选和那只怪兽是原本卡名不同并是原本种族相同的1只怪兽特殊召唤。
-- ②：魔法与陷阱区域的这张卡被对方的效果破坏的场合才能发动。从卡组选1张「一族的集结」在自己的魔法与陷阱区域盖放。
function c8608979.initial_effect(c)
	-- ①：以场上1只表侧表示怪兽为对象才能发动。从自己的手卡·墓地选和那只怪兽是原本卡名不同并是原本种族相同的1只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c8608979.target)
	e1:SetOperation(c8608979.operation)
	c:RegisterEffect(e1)
	-- ②：魔法与陷阱区域的这张卡被对方的效果破坏的场合才能发动。从卡组选1张「一族的集结」在自己的魔法与陷阱区域盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(8608979,0))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c8608979.setcon)
	e2:SetTarget(c8608979.settg)
	e2:SetOperation(c8608979.setop)
	c:RegisterEffect(e2)
end
-- 过滤场上表侧表示怪兽的条件函数：该怪兽存在于场上，且手卡·墓地存在与其原本种族相同、原本卡名不同的可特殊召唤的怪兽
function c8608979.filter1(c,e,tp)
	-- 检查该怪兽是否表侧表示，且自己的手卡·墓地是否存在满足特殊召唤条件的、与其原本种族相同且原本卡名不同的怪兽
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c8608979.filter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,c,e,tp)
end
-- 过滤手卡·墓地中满足特殊召唤条件的怪兽：必须是怪兽卡，可以特殊召唤，且原本种族与目标怪兽相同，原本卡名与目标怪兽不同
function c8608979.filter2(c,tc,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:GetOriginalRace()==tc:GetOriginalRace()
		and not c:IsOriginalCodeRule(tc:GetOriginalCodeRule())
end
-- 效果①的发动准备与目标选择
function c8608979.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsFaceup() and chkc:IsLocation(LOCATION_MZONE) and c8608979.filter1(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否存在可以作为效果对象的表侧表示怪兽
		and Duel.IsExistingTarget(c8608979.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) end
	-- 提示玩家选择作为效果对象的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择场上1只表侧表示怪兽作为对象
	local g=Duel.SelectTarget(tp,c8608979.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
	-- 设置效果处理信息：从手卡或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果①的处理逻辑
function c8608979.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有空余的怪兽区域，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取作为效果对象的那只怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手卡·墓地选择1只与对象怪兽原本种族相同且原本卡名不同的怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c8608979.filter2),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tc,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动条件：魔法与陷阱区域的这张卡被对方的效果破坏并送去墓地（或除外等）的场合
function c8608979.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_SZONE)
end
-- 过滤卡组中名为「一族的集结」且可以盖放的卡
function c8608979.setfilter(c)
	return c:IsCode(8608979) and c:IsSSetable()
end
-- 效果②的发动准备与目标检查
function c8608979.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以盖放的「一族的集结」
	if chk==0 then return Duel.IsExistingMatchingCard(c8608979.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果②的处理逻辑
function c8608979.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组选择1张「一族的集结」
	local g=Duel.SelectMatchingCard(tp,c8608979.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡在自己的魔法与陷阱区域盖放
		Duel.SSet(tp,g:GetFirst())
	end
end
