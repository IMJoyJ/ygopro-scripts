--カブトロン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把自己场上1张表侧表示的魔法·陷阱卡送去墓地，以自己墓地1只4星以下的昆虫族怪兽为对象才能发动。那只昆虫族怪兽守备表示特殊召唤。
function c30587695.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：把自己场上1张表侧表示的魔法·陷阱卡送去墓地，以自己墓地1只4星以下的昆虫族怪兽为对象才能发动。那只昆虫族怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30587695,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,30587695)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c30587695.spcost)
	e1:SetTarget(c30587695.sptg)
	e1:SetOperation(c30587695.spop)
	c:RegisterEffect(e1)
end
-- 定义代价筛选函数：检查表侧表示的魔法·陷阱卡能否作为代价送去墓地，并确认该卡离开后我方场上是否有可用怪兽区。
function c30587695.cfilter(c,tp)
	-- 判断条件：卡为表侧表示、是魔法·陷阱卡、可作为代价送去墓地，且该卡离场后我方怪兽区仍有空格。
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and Duel.GetMZoneCount(tp,c)>0 and c:IsAbleToGraveAsCost()
end
-- 代价处理函数：从我方场上选择一张满足条件的表侧魔法·陷阱卡送入墓地作为发动代价。
function c30587695.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前合法性检查：我方场上是否存在至少一张满足条件的表侧魔法·陷阱卡可作为代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c30587695.cfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	-- 向操作者发出选择提示，提示内容为“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己场上选择一张满足条件的表侧魔法·陷阱卡作为代价。
	local g=Duel.SelectMatchingCard(tp,c30587695.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 将选中的卡以代价原因送入墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义特殊召唤对象筛选函数：墓地中4星以下的昆虫族怪兽，且允许以表侧守备表示特殊召唤。
function c30587695.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 目标选择与操作信息设置：取对象效果，从自己墓地选择1只4星以下昆虫族怪兽为对象，并声明进行特殊召唤。
function c30587695.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c30587695.filter(chkc,e,tp) end
	-- 发动前合法性检查：自己墓地是否存在至少一张满足条件的昆虫族怪兽。
	if chk==0 then return Duel.IsExistingTarget(c30587695.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向操作者发出选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择一张满足条件的昆虫族怪兽并设为效果对象。
	local g=Duel.SelectTarget(tp,c30587695.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本次连锁的操作信息：将进行特殊召唤，对象为选择的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数：将效果对象怪兽以表侧守备表示特殊召唤到自己场上。
function c30587695.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时选择的第一个对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_INSECT) then
		-- 将对象怪兽以表侧守备表示特殊召唤，无视苏生限制和召唤条件检查。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
