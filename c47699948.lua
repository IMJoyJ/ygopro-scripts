--シンクロ・ディレンマ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：可以从以下效果选择1个发动。
-- ●从手卡以及自己场上的表侧表示怪兽之中把1只「同调士」怪兽送去墓地才能发动。从手卡把1只怪兽特殊召唤。
-- ●以这张卡以外的自己场上1张卡为对象才能发动。那张卡破坏，从自己的手卡·墓地选原本卡名和那张卡不同的1只「同调士」怪兽特殊召唤。
function c47699948.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- 从手卡以及自己场上的表侧表示怪兽之中把1只「同调士」怪兽送去墓地才能发动。从手卡把1只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47699948,0))  --"送去墓地并特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,47699948)
	e1:SetCost(c47699948.spcost)
	e1:SetTarget(c47699948.sptg1)
	e1:SetOperation(c47699948.spop1)
	c:RegisterEffect(e1)
	-- 以这张卡以外的自己场上1张卡为对象才能发动。那张卡破坏，从自己的手卡·墓地选原本卡名和那张卡不同的1只「同调士」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47699948,1))  --"破坏并特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,47699948)
	e2:SetTarget(c47699948.sptg2)
	e2:SetOperation(c47699948.spop2)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于检查手卡或场上的「同调士」怪兽是否满足送去墓地的条件，包括：是「同调士」怪兽、正面表示或不在怪兽区、可以作为代价送去墓地、场上存在空位、且手牌中存在可特殊召唤的怪兽。
function c47699948.costfilter(c,e,tp)
	return c:IsSetCard(0x1017) and c:IsType(TYPE_MONSTER) and (c:IsFaceup() or not c:IsLocation(LOCATION_MZONE))
		-- 检查目标怪兽是否可以被送去墓地作为发动代价，并确保场上存在空位。
		and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
		-- 检查手牌中是否存在满足条件的怪兽，用于后续特殊召唤。
		and Duel.IsExistingMatchingCard(c47699948.spfilter,tp,LOCATION_HAND,0,1,c,e,tp)
end
-- 过滤函数，用于检查手牌中的怪兽是否可以被特殊召唤。
function c47699948.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的处理函数，用于选择并送去墓地1只符合条件的「同调士」怪兽作为代价。
function c47699948.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：是否存在满足costfilter的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c47699948.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 根据costfilter筛选并选择1张卡。
	local g=Duel.SelectMatchingCard(tp,c47699948.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 将选中的卡送去墓地作为代价。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置效果处理时的操作信息，用于确定特殊召唤的目标。
function c47699948.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将要特殊召唤1只怪兽到手牌区域。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果发动时的处理函数，用于选择并特殊召唤1只符合条件的怪兽。
function c47699948.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位可以进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 根据spfilter筛选并选择1张可特殊召唤的怪兽。
	local g=Duel.SelectMatchingCard(tp,c47699948.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于检查场上的卡是否可以被破坏，并且手牌或墓地存在满足条件的「同调士」怪兽。
function c47699948.desfilter(c,e,tp)
	local code=c:GetOriginalCode()
	-- 检查目标卡是否在场上有空位可以进行特殊召唤。
	return Duel.GetMZoneCount(tp,c)>0
		-- 检查手牌或墓地中是否存在与目标卡原卡名不同的「同调士」怪兽。
		and Duel.IsExistingMatchingCard(c47699948.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,code,e,tp)
end
-- 过滤函数，用于检查手牌或墓地中的「同调士」怪兽是否满足特殊召唤条件，并且原卡名不同。
function c47699948.spfilter2(c,code,e,tp)
	return not c:IsCode(code) and c:IsSetCard(0x1017) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果处理时的操作信息，用于确定破坏和特殊召唤的目标。
function c47699948.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c47699948.desfilter(chkc,e,tp) end
	-- 判断是否满足发动条件：是否存在满足desfilter的场上的卡。
	if chk==0 then return Duel.IsExistingTarget(c47699948.desfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler(),e,tp) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 根据desfilter筛选并选择1张场上的卡作为破坏对象。
	local g=Duel.SelectTarget(tp,c47699948.desfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler(),e,tp)
	-- 设置操作信息，表示将要破坏选中的卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息，表示将要特殊召唤1只「同调士」怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果发动时的处理函数，用于破坏目标卡并特殊召唤符合条件的「同调士」怪兽。
function c47699948.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡。
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效，并且成功破坏。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0
		-- 检查场上是否有空位可以进行特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 根据spfilter2筛选并选择1张符合条件的「同调士」怪兽。
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c47699948.spfilter2),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tc:GetOriginalCode(),e,tp)
		if sg:GetCount()>0 then
			-- 将选中的「同调士」怪兽特殊召唤到场上。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
