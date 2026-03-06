--機巧蛙－磐盾多邇具久
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组选攻击力和守备力的数值相同的1只机械族怪兽在卡组最上面放置。
-- ②：把墓地的这张卡除外，以攻击力和守备力的数值相同的自己墓地1只机械族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
function c23384666.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23384666,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,23384666)
	e1:SetTarget(c23384666.tdtg)
	e1:SetOperation(c23384666.tdop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡除外，以攻击力和守备力的数值相同的自己墓地1只机械族怪兽为对象才能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(23384666,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,23384667)
	-- 将此卡从游戏中除外作为费用
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c23384666.sptg)
	e3:SetOperation(c23384666.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数：检查怪兽的攻击力和守备力是否相同且为机械族
function c23384666.tdfilter(c)
	-- 攻击力和守备力相同且为机械族
	return aux.AtkEqualsDef(c) and c:IsRace(RACE_MACHINE)
end
-- 判断是否满足效果①的发动条件：卡组中存在满足条件的怪兽且卡组数量大于1
function c23384666.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c23384666.tdfilter,tp,LOCATION_DECK,0,1,nil)
		-- 判断卡组数量大于1
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1 end
end
-- 效果①的处理函数：选择一张满足条件的怪兽放置到卡组最上方
function c23384666.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要放置到卡组最上方的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(23384666,2))  --"请选择要放置到卡组最上面的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c23384666.tdfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将卡组洗牌
		Duel.ShuffleDeck(tp)
		-- 将选中的怪兽移动到卡组最上方
		Duel.MoveSequence(tc,SEQ_DECKTOP)
		-- 确认卡组最上方的卡
		Duel.ConfirmDecktop(tp,1)
	end
end
-- 过滤函数：检查怪兽是否为机械族且攻击力和守备力相同且可以特殊召唤
function c23384666.spfilter(c,e,tp)
	-- 为机械族且攻击力和守备力相同
	return c:IsRace(RACE_MACHINE) and aux.AtkEqualsDef(c)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果②的处理函数：选择一张满足条件的墓地怪兽进行特殊召唤
function c23384666.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c23384666.filter(chkc,e,tp) end
	-- 判断场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地中是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c23384666.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为对象
	local g=Duel.SelectTarget(tp,c23384666.spfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	-- 设置效果处理信息，确定特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的处理函数：将选中的怪兽特殊召唤
function c23384666.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以守备表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
