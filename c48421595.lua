--ネクロ・シンクロン
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「鲜花同调士」使用。
-- ②：以这张卡以外的自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的等级直到回合结束时上升2星。
-- ③：这张卡作为风属性同调怪兽的同调素材送去墓地的场合才能发动。从卡组把1只植物族·1星怪兽特殊召唤。
function c48421595.initial_effect(c)
	-- 使此卡在场上或墓地时视为「鲜花同调士」
	aux.EnableChangeCode(c,19642774,LOCATION_MZONE+LOCATION_GRAVE)
	-- 以这张卡以外的自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的等级直到回合结束时上升2星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48421595,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,48421595)
	e1:SetTarget(c48421595.lvltg)
	e1:SetOperation(c48421595.lvlop)
	c:RegisterEffect(e1)
	-- 这张卡作为风属性同调怪兽的同调素材送去墓地的场合才能发动。从卡组把1只植物族·1星怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48421595,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,48421596)
	e2:SetCondition(c48421595.spcon)
	e2:SetTarget(c48421595.sptg)
	e2:SetOperation(c48421595.spop)
	c:RegisterEffect(e2)
end
-- 选择一只自己场上的表侧表示怪兽作为效果对象
function c48421595.lvltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc:IsControler(tp) end
	-- 检查场上是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 向玩家提示选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标怪兽
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 将目标怪兽的等级上升2星
function c48421595.lvlop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 创建一个使目标怪兽等级上升2星的效果
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(2)
		tc:RegisterEffect(e1)
	end
end
-- 判断此卡是否作为风属性同调怪兽的素材被送去墓地
function c48421595.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO and c:GetReasonCard():IsAttribute(ATTRIBUTE_WIND)
end
-- 过滤出满足条件的植物族1星怪兽
function c48421595.spfilter(c,e,tp)
	return c:IsLevel(1) and c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤的条件
function c48421595.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c48421595.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行特殊召唤操作
function c48421595.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c48421595.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
