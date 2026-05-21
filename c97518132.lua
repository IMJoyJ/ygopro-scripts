--影依の巫女 エリアル
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡反转的场合，以自己的除外状态的1只「影依」怪兽为对象才能发动。那只怪兽表侧守备表示或里侧守备表示特殊召唤。
-- ②：这张卡被效果送去墓地的场合，以自己·对方的墓地的卡合计最多3张为对象才能发动。那些卡除外。
function c97518132.initial_effect(c)
	-- ①：这张卡反转的场合，以自己的除外状态的1只「影依」怪兽为对象才能发动。那只怪兽表侧守备表示或里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97518132,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,97518132)
	e1:SetTarget(c97518132.target)
	e1:SetOperation(c97518132.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果送去墓地的场合，以自己·对方的墓地的卡合计最多3张为对象才能发动。那些卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97518132,1))  --"除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,97518132)
	e2:SetCondition(c97518132.rmcon)
	e2:SetTarget(c97518132.rmtg)
	e2:SetOperation(c97518132.rmop)
	c:RegisterEffect(e2)
	c97518132.shadoll_flip_effect=e1
end
-- 过滤条件：自己除外状态的表侧表示「影依」怪兽，且可以守备表示特殊召唤
function c97518132.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x9d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)
end
-- ①号效果的target函数：检查场上是否有空位、除外区是否有合法的「影依」怪兽，并选择对象
function c97518132.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c97518132.filter(chkc,e,tp) end
	-- 检查自己场上是否有可以特殊召唤怪兽的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的除外状态中是否存在至少1只满足条件的「影依」怪兽
		and Duel.IsExistingTarget(c97518132.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己除外状态的1只满足条件的「影依」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c97518132.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息，包含对象怪兽和数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①号效果的operation函数：将选择的怪兽特殊召唤，若里侧守备表示特殊召唤则给对方确认
function c97518132.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为对象的第一张卡
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 将对象怪兽以守备表示（表侧或里侧）特殊召唤，并判断是否成功且为里侧守备表示
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_DEFENSE)~=0 and tc:IsFacedown() then
		-- 让对方玩家确认里侧守备表示特殊召唤的怪兽
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- ②号效果的发动条件：这张卡是被效果送去墓地的场合
function c97518132.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- ②号效果的target函数：选择双方墓地合计最多3张卡作为对象
function c97518132.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToRemove() end
	-- 检查双方墓地中是否存在至少1张可以除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择双方墓地合计1到3张可以除外的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,3,nil)
	-- 设置除外的操作信息，包含对象卡片组和数量
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- ②号效果的operation函数：将选择的墓地的卡除外
function c97518132.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将这些对象卡片以表侧表示因效果除外
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	end
end
