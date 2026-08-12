--影六武衆－ハツメ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：从自己墓地以及自己场上的表侧表示怪兽之中把2只「六武众」怪兽除外，以「影六武众-初芽」以外的自己墓地1只「六武众」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：只让自己场上的「六武众」怪兽1只被效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c44686185.initial_effect(c)
	-- ①：从自己墓地以及自己场上的表侧表示怪兽之中把2只「六武众」怪兽除外，以「影六武众-初芽」以外的自己墓地1只「六武众」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44686185,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,44686185)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c44686185.cost)
	e1:SetTarget(c44686185.target)
	e1:SetOperation(c44686185.operation)
	c:RegisterEffect(e1)
	-- ②：只让自己场上的「六武众」怪兽1只被效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(c44686185.reptg)
	e2:SetValue(c44686185.repval)
	e2:SetOperation(c44686185.repop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断是否为场上（主要怪兽区）且为前排怪兽（序列小于5）
function c44686185.filter0(c)
	return c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5
end
-- 过滤函数，用于判断是否为「六武众」怪兽且为怪兽卡且可以作为除外的代价且在墓地或表侧表示
function c44686185.filter1(c)
	return c:IsSetCard(0x103d) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
-- 过滤函数，用于判断是否满足filter1条件并能通过filter4函数的进一步筛选
function c44686185.filter3(c,e,tp)
	return c44686185.filter1(c)
		-- 检查是否存在满足filter4条件的卡
		and Duel.IsExistingMatchingCard(c44686185.filter4,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,1,c,e,tp,c)
end
-- 过滤函数，用于判断是否满足filter1条件且场上存在足够召唤区域且能选择目标
function c44686185.filter4(c,e,tp,rc)
	-- 获取玩家tp的场上怪兽区域可用空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=Group.FromCards(c,rc)
	local ct=g:FilterCount(c44686185.filter0,nil)
	return c44686185.filter1(c) and ft+ct>0
		-- 检查是否存在满足filter2条件的目标卡
		and Duel.IsExistingTarget(c44686185.filter2,tp,LOCATION_GRAVE,0,1,g,e,tp)
end
-- cost函数，用于处理效果发动的代价，需要从墓地或场上选择2只「六武众」怪兽除外
function c44686185.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足cost条件，即是否存在满足filter3条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c44686185.filter3,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,1,nil,e,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足filter3条件的卡作为第一组除外的卡
	local g1=Duel.SelectMatchingCard(tp,c44686185.filter3,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,1,1,nil,e,tp)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足filter4条件的卡作为第二组除外的卡
	local g2=Duel.SelectMatchingCard(tp,c44686185.filter4,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,1,1,g1:GetFirst(),e,tp,g1:GetFirst())
	g1:Merge(g2)
	-- 将选中的卡除外作为发动效果的代价
	Duel.Remove(g1,POS_FACEUP,REASON_COST)
end
-- 过滤函数，用于判断是否为「六武众」怪兽且不是本卡且可以特殊召唤
function c44686185.filter2(c,e,tp)
	return c:IsSetCard(0x103d) and not c:IsCode(44686185) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- target函数，用于设置效果的目标，选择墓地中的「六武众」怪兽作为特殊召唤对象
function c44686185.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c44686185.filter2(chkc,e,tp) end
	if chk==0 then return true end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足filter2条件的卡作为特殊召唤的目标
	local g=Duel.SelectTarget(tp,c44686185.filter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，确定特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- operation函数，用于执行效果的处理，将目标卡特殊召唤
function c44686185.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于判断是否为「六武众」怪兽且在场上表侧表示且因效果破坏且不是代替破坏
function c44686185.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x103d)
		and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- reptg函数，用于判断是否可以发动代替破坏效果
function c44686185.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c44686185.repfilter,1,nil,tp)
		and eg:GetCount()==1 end
	-- 询问玩家是否发动代替破坏效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- repval函数，用于返回代替破坏的条件
function c44686185.repval(e,c)
	return c44686185.repfilter(c,e:GetHandlerPlayer())
end
-- repop函数，用于执行代替破坏效果的处理，将本卡除外
function c44686185.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将本卡除外作为代替破坏的效果处理
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
