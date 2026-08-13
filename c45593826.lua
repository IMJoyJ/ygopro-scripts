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
	-- 「彼岸的恶鬼 德拉基尼亚佐」的①③的效果1回合只能有1次使用其中任意1个。①：自己场上没有魔法·陷阱卡存在的场合才能发动。这张卡从手卡特殊召唤。
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
	-- 「彼岸的恶鬼 德拉基尼亚佐」的①③的效果1回合只能有1次使用其中任意1个。③：这张卡被送去墓地的场合才能发动。从卡组选1张「彼岸」卡在卡组最上面放置。
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
-- ②自坏效果的过滤函数：判定场上怪兽是否为里侧表示或不属于「彼岸」字段，满足其一即视为‘「彼岸」怪兽以外的怪兽’。
function c45593826.sdfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0xb1)
end
-- ②自坏效果的发动条件：检查自己怪兽区是否存在至少1张满足sdfilter的怪兽（即非「彼岸」怪兽或里侧表示怪兽），存在时自坏效果适用。
function c45593826.sdcon(e)
	-- ②自坏效果的条件判断：在自己怪兽区检索是否存在1张以上非「彼岸」怪兽或里侧表示的怪兽，用于决定是否破坏自身。
	return Duel.IsExistingMatchingCard(c45593826.sdfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- ①自召效果的过滤函数：判定卡片是否为魔法卡或陷阱卡，用于检查自己场上是否存在魔法·陷阱卡。
function c45593826.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ①自召效果的发动条件：检查自己场上不存在魔法·陷阱卡（LOCATION_ONFIELD内无filter命中的卡），满足则可以从手卡发动。
function c45593826.sscon(e,tp,eg,ep,ev,re,r,rp)
	-- ①自召效果的发动条件判断：若自己场上没有魔法·陷阱卡，则条件成立，允许从手卡特殊召唤。
	return not Duel.IsExistingMatchingCard(c45593826.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- ①自召效果的目标合法性检查：确认自己主要怪兽区有空位，且手牌中的这张卡能够被特殊召唤，满足才能发动。
function c45593826.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ①自召效果的目标合法性检查（前半）：确认自己主要怪兽区域存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- ①自召效果的操作登记：将特殊召唤分类及对象（这张卡）写入连锁操作信息，供其他卡效果检测与处理确认。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①自召效果的处理操作：获取效果所属的这张卡，若其仍与效果关联（未离场或未被无效），则以表侧表示将其特殊召唤到自己场上。
function c45593826.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- ①自召效果的实际执行：将这张卡以表侧表示特殊召唤到其控制者的主要怪兽区（不无视召唤条件与苏生限制）。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ③送墓检索效果的目标合法性检查：确认自己卡组中是否存在至少1张「彼岸」字段的卡，存在才可发动。
function c45593826.dttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ③送墓检索效果的发动条件判断：若卡组中有至少1张「彼岸」卡，则③效果满足发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_DECK,0,1,nil,0xb1) end
end
-- ③送墓检索效果的处理操作：从卡组选择1张「彼岸」卡，洗切卡组后，将选中的卡放到卡组最上方，并向双方确认。
function c45593826.dtop(e,tp,eg,ep,ev,re,r,rp)
	-- ③处理时向玩家展示选择提示：弹出让玩家选择要放置到卡组最上方的「彼岸」卡的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(45593826,2))  --"请选择要在卡组最上面放置的卡"
	-- ③从自己卡组中挑选1张「彼岸」字段的卡（不取对象，处理时选择）。
	local g=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_DECK,0,1,1,nil,0xb1)
	local tc=g:GetFirst()
	if tc then
		-- ③将玩家卡组洗切，使所选卡片位置随机化，防止卡组顺序信息泄露。
		Duel.ShuffleDeck(tp)
		-- ③将选中的「彼岸」卡移动到卡组最上方（SEQ_DECKTOP），完成放置到卡组顶部的操作。
		Duel.MoveSequence(tc,SEQ_DECKTOP)
		-- ③确认卡组最上方1张卡，向双方展示已放置到卡组顶部的卡，完成效果处理。
		Duel.ConfirmDecktop(tp,1)
	end
end
