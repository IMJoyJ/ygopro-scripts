--ブルル＠イグニスター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1只「@火灵天星」怪兽送去墓地。
-- ②：这张卡作为电子界族同调怪兽的同调素材送去墓地的场合，以「抖抖妖@火灵天星」以外的自己墓地1只作为那次同调召唤的素材的怪兽为对象才能发动。那只怪兽特殊召唤。
function c42429678.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1只「@火灵天星」怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42429678,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,42429678)
	e1:SetTarget(c42429678.tgtg)
	e1:SetOperation(c42429678.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡作为电子界族同调怪兽的同调素材送去墓地的场合，以「抖抖妖@火灵天星」以外的自己墓地1只作为那次同调召唤的素材的怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(42429678,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,42429679)
	e3:SetCondition(c42429678.spcon)
	e3:SetTarget(c42429678.sptg)
	e3:SetOperation(c42429678.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选卡组中满足条件的「@火灵天星」怪兽（种族为0x135，类型为怪兽，可以送去墓地）
function c42429678.tgfilter(c)
	return c:IsSetCard(0x135) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 效果处理时检查是否满足条件，即在卡组中是否存在至少1张满足tgfilter条件的卡
function c42429678.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足条件，即在卡组中是否存在至少1张满足tgfilter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c42429678.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将要处理的效果类别为送去墓地，目标为卡组中的一张卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，提示玩家选择一张卡组中的「@火灵天星」怪兽并将其送去墓地
function c42429678.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家从卡组中选择一张「@火灵天星」怪兽送去墓地
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择一张满足tgfilter条件的卡作为目标
	local g=Duel.SelectMatchingCard(tp,c42429678.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地，原因来自效果
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 条件函数，判断该卡是否作为电子界族同调怪兽的同调素材被送去墓地
function c42429678.spcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO and e:GetHandler():GetReasonCard():IsRace(RACE_CYBERSE)
end
-- 过滤函数，用于筛选自己墓地中满足条件的怪兽（在墓地、属于玩家、不是自身、可以成为效果对象、可以特殊召唤）
function c42429678.spfilter(c,e,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp) and not c:IsCode(42429678) and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时检查是否满足条件，即在作为同调素材的怪兽中是否存在至少1张满足spfilter条件的卡
function c42429678.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local mg=e:GetHandler():GetReasonCard():GetMaterial()
	if chkc then return mg:IsContains(chkc) and c42429678.spfilter(chkc,e,tp) end
	-- 检查是否满足条件，即玩家场上是否有足够的位置来特殊召唤怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and mg:IsExists(c42429678.spfilter,1,nil,e,tp) end
	-- 提示玩家从墓地中选择一张怪兽进行特殊召唤
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=mg:FilterSelect(tp,c42429678.spfilter,1,1,nil,e,tp)
	-- 设置当前处理的连锁对象为选中的怪兽
	Duel.SetTargetCard(g)
	-- 设置连锁操作信息，表示将要处理的效果类别为特殊召唤，目标为选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数，将选中的墓地怪兽特殊召唤到场上
function c42429678.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以正面表示的形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
