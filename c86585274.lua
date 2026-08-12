--魔導法士 ジュノン
-- 效果：
-- ①：把手卡3张「魔导书」魔法卡给对方观看才能发动。这张卡从手卡特殊召唤。
-- ②：1回合1次，从自己的手卡·墓地把1张「魔导书」魔法卡除外，以场上1张卡为对象才能发动。那张卡破坏。
function c86585274.initial_effect(c)
	-- ①：把手卡3张「魔导书」魔法卡给对方观看才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86585274,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c86585274.spcost)
	e1:SetTarget(c86585274.sptg)
	e1:SetOperation(c86585274.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，从自己的手卡·墓地把1张「魔导书」魔法卡除外，以场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86585274,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c86585274.descost)
	e2:SetTarget(c86585274.destg)
	e2:SetOperation(c86585274.desop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中未公开的「魔导书」魔法卡
function c86585274.cffilter(c)
	return c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL) and not c:IsPublic()
end
-- 特殊召唤效果的发动代价（把手卡3张「魔导书」魔法卡给对方观看）
function c86585274.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少3张未公开的「魔导书」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c86585274.cffilter,tp,LOCATION_HAND,0,3,nil) end
	-- 提示玩家选择要确认的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 玩家选择手卡中3张未公开的「魔导书」魔法卡
	local g=Duel.SelectMatchingCard(tp,c86585274.cffilter,tp,LOCATION_HAND,0,3,3,nil)
	-- 给对方玩家确认选中的卡片
	Duel.ConfirmCards(1-tp,g)
	-- 洗切手卡
	Duel.ShuffleHand(tp)
end
-- 特殊召唤效果的发动准备（检查怪兽区域空位及自身是否能特殊召唤）
function c86585274.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理（将自身特殊召唤）
function c86585274.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以表侧表示特殊召唤到自己的怪兽区域
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤手卡或墓地中可以作为代价除外的「魔导书」魔法卡
function c86585274.cfilter(c)
	return c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
-- 破坏效果的发动代价（从手卡·墓地把1张「魔导书」魔法卡除外）
function c86585274.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的手卡或墓地是否存在至少1张可以除外的「魔导书」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c86585274.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择手卡或墓地中1张「魔导书」魔法卡
	local g=Duel.SelectMatchingCard(tp,c86585274.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡片作为发动代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 破坏效果的对象选择与发动准备
function c86585274.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在可以作为效果对象的卡片
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上1张卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁处理中的操作信息为破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的处理（破坏作为对象的卡片）
function c86585274.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 破坏作为效果对象的卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
