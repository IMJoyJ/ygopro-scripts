--機巧蛇－叢雲遠呂智
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡在手卡·墓地存在的场合，从自己卡组上面把8张卡里侧表示除外才能发动。这张卡特殊召唤。这个效果在对方回合也能发动。
-- ②：从额外卡组把3张卡里侧表示除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。
function c71197066.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在的场合，从自己卡组上面把8张卡里侧表示除外才能发动。这张卡特殊召唤。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71197066,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,71197066)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c71197066.spcost)
	e1:SetTarget(c71197066.sptg)
	e1:SetOperation(c71197066.spop)
	c:RegisterEffect(e1)
	-- ②：从额外卡组把3张卡里侧表示除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(71197066,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,71197066)
	e2:SetCost(c71197066.descost)
	e2:SetTarget(c71197066.destg)
	e2:SetOperation(c71197066.desop)
	c:RegisterEffect(e2)
end
-- ①效果的发动代价：从自己卡组上面把8张卡里侧表示除外
function c71197066.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己卡组最上方的8张卡
	local g=Duel.GetDecktopGroup(tp,8)
	if chk==0 then return g:FilterCount(Card.IsAbleToRemoveAsCost,nil,POS_FACEDOWN)==8 end
	-- 使接下来的卡组操作不触发自动洗牌检测
	Duel.DisableShuffleCheck()
	-- 将这8张卡作为代价里侧表示除外
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
-- ①效果的发动准备：检查自身是否能特殊召唤并设置特殊召唤的操作信息
function c71197066.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk为0（检查可行性）时，判断自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁中的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：将这张卡特殊召唤
function c71197066.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动代价：从额外卡组把3张卡里侧表示除外
function c71197066.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk为0时，检查自己额外卡组是否存在至少3张可以作为代价里侧表示除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_EXTRA,0,3,nil,POS_FACEDOWN) end
	-- 向玩家发送提示信息，要求选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己额外卡组选择3张可以作为代价里侧表示除外的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_EXTRA,0,3,3,nil,POS_FACEDOWN)
	-- 将选中的3张额外卡组的卡作为代价里侧表示除外
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
-- ②效果的发动准备：选择场上1只表侧表示怪兽为对象，并设置破坏的操作信息
function c71197066.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 在chk为0时，检查场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息，要求选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上1只表侧表示怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁中的操作信息为破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果的处理：将作为对象的怪兽破坏
function c71197066.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将该怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
