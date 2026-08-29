--星遺物－『星櫃』
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己场上的连接怪兽被对方的效果破坏送去自己墓地的场合，把这张卡从手卡送去墓地，以那1只连接怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
-- ③：通常召唤的这张卡在怪兽区域存在，对方从额外卡组把怪兽特殊召唤的场合才能发动。从卡组把1只怪兽送去墓地。
function c42388271.initial_effect(c)
	-- ①：自己场上的连接怪兽被对方的效果破坏送去自己墓地的场合，把这张卡从手卡送去墓地，以那1只连接怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42388271,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,42388271)
	e1:SetCost(c42388271.spcost)
	e1:SetTarget(c42388271.sptg)
	e1:SetOperation(c42388271.spop)
	c:RegisterEffect(e1)
	-- ②：怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e2:SetValue(c42388271.condition)
	c:RegisterEffect(e2)
	-- ③：通常召唤的这张卡在怪兽区域存在，对方从额外卡组把怪兽特殊召唤的场合才能发动。从卡组把1只怪兽送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(42388271,1))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,42388272)
	e3:SetCondition(c42388271.tgcon)
	e3:SetTarget(c42388271.tgtg)
	e3:SetOperation(c42388271.tgop)
	c:RegisterEffect(e3)
end
-- 上级召唤怪兽时作为2只数量解放的适用条件
function c42388271.condition(e,c)
	local ec=e:GetHandler()
	return ec:IsFaceup() or c:GetControler()==ec:GetControler()
end
-- 把这张卡从手卡送去墓地作为发动代价
function c42388271.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将手卡的这张卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤被对方效果破坏送去自己墓地的前场表侧表示连接怪兽
function c42388271.spfilter(c,e,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and bit.band(c:GetPreviousTypeOnField(),TYPE_LINK)~=0
		and c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp) and c:IsType(TYPE_LINK)
		and c:IsReason(REASON_EFFECT) and c:IsReason(REASON_DESTROY) and c:GetReasonPlayer()==1-tp
		and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备与取对象
function c42388271.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c42388271.spfilter(chkc,e,tp) end
	-- 检查怪兽区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and eg:IsExists(c42388271.spfilter,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=eg:FilterSelect(tp,c42388271.spfilter,1,1,nil,e,tp)
	-- 将选中的破坏送墓的连接怪兽设为效果对象
	Duel.SetTargetCard(g)
	-- 设置操作信息：特殊召唤目标连接怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果的效果处理：特殊召唤作为对象的连接怪兽
function c42388271.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标连接怪兽表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤由对方从额外卡组特殊召唤的怪兽
function c42388271.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsPreviousLocation(LOCATION_EXTRA)
end
-- 判断自身是否通常召唤且对方有从额外卡组特殊召唤怪兽
function c42388271.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL) and eg:IsExists(c42388271.cfilter,1,nil,1-tp)
end
-- 过滤卡组中可以送去墓地的怪兽
function c42388271.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- ③效果的发动准备
function c42388271.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在可以送去墓地的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c42388271.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组把1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ③效果的效果处理：从卡组选1只怪兽送去墓地
function c42388271.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1只怪兽
	local g=Duel.SelectMatchingCard(tp,c42388271.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
