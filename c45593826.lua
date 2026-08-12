--彼岸の悪鬼 ドラゴネル
-- 效果：
-- 「彼岸的恶鬼 德拉基尼亚佐」的①③的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上没有魔法·陷阱卡存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己场上有「彼岸」怪兽以外的怪兽存在的场合这张卡破坏。
-- ③：这张卡被送去墓地的场合才能发动。从卡组选1张「彼岸」卡在卡组最上面放置。
function c45593826.initial_effect(c)
	-- ②：自己场上有「彼岸」怪兽以外的怪兽存在的场合这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SELF_DESTROY)
	e1:SetCondition(c45593826.sdcon)
	c:RegisterEffect(e1)
	-- ①：自己场上没有魔法·陷阱卡存在的场合才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45593826,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,45593826)
	e2:SetCondition(c45593826.sscon)
	e2:SetTarget(c45593826.sstg)
	e2:SetOperation(c45593826.ssop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合才能发动。从卡组选1张「彼岸」卡在卡组最上面放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(45593826,1))  --"选1张「彼岸」卡在卡组最上面放置"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,45593826)
	e3:SetTarget(c45593826.dttg)
	e3:SetOperation(c45593826.dtop)
	c:RegisterEffect(e3)
end
-- 用于判断场上是否存在非「彼岸」怪兽或里侧表示的怪兽
function c45593826.sdfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0xb1)
end
-- 判断场上是否存在非「彼岸」怪兽或里侧表示的怪兽
function c45593826.sdcon(e)
	-- 判断场上是否存在非「彼岸」怪兽或里侧表示的怪兽
	return Duel.IsExistingMatchingCard(c45593826.sdfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 用于过滤魔法·陷阱卡
function c45593826.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 判断自己场上是否没有魔法·陷阱卡存在
function c45593826.sscon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否没有魔法·陷阱卡存在
	return not Duel.IsExistingMatchingCard(c45593826.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 判断特殊召唤的条件是否满足
function c45593826.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function c45593826.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将卡片特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 判断卡组中是否存在「彼岸」卡
function c45593826.dttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在「彼岸」卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_DECK,0,1,nil,0xb1) end
end
-- 执行将「彼岸」卡放置到卡组最上方的操作
function c45593826.dtop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要放置到卡组最上方的「彼岸」卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(45593826,2))  --"请选择要在卡组最上面放置的卡"
	-- 从卡组中选择一张「彼岸」卡
	local g=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_DECK,0,1,1,nil,0xb1)
	local tc=g:GetFirst()
	if tc then
		-- 将卡组洗牌
		Duel.ShuffleDeck(tp)
		-- 将选中的卡移动到卡组最上方
		Duel.MoveSequence(tc,SEQ_DECKTOP)
		-- 确认卡组最上方的卡
		Duel.ConfirmDecktop(tp,1)
	end
end
