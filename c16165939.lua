--超自然警戒区域
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：效果怪兽以外的怪兽表侧表示特殊召唤的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
-- ②：魔法与陷阱区域的这张卡被对方的效果破坏的场合才能发动。从自己的手卡·卡组·墓地选效果怪兽以外的1只怪兽特殊召唤。
function c16165939.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：效果怪兽以外的怪兽表侧表示特殊召唤的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16165939,0))  --"对方的卡破坏"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,16165939)
	e2:SetCondition(c16165939.descon)
	e2:SetTarget(c16165939.destg)
	e2:SetOperation(c16165939.desop)
	c:RegisterEffect(e2)
	-- ②：魔法与陷阱区域的这张卡被对方的效果破坏的场合才能发动。从自己的手卡·卡组·墓地选效果怪兽以外的1只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(16165939,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,16165940)
	e3:SetCondition(c16165939.spcon)
	e3:SetTarget(c16165939.sptg)
	e3:SetOperation(c16165939.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断是否为表侧表示且不是效果怪兽的怪兽
function c16165939.cfilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_EFFECT)
end
-- 效果发动的条件函数，判断是否有满足条件的怪兽被特殊召唤
function c16165939.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c16165939.cfilter,1,nil)
end
-- 效果的发动选择目标阶段，选择对方场上的1张卡作为破坏对象
function c16165939.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 判断是否满足发动条件，检查对方场上是否存在至少1张卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息，确定要破坏的卡的数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果的发动处理阶段，对选中的卡进行破坏
function c16165939.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判断此卡是否被对方效果破坏并处于魔法与陷阱区域
function c16165939.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousControler(tp)
		and rp==1-tp and c:IsReason(REASON_EFFECT)
end
-- 过滤函数，用于筛选可以特殊召唤的效果怪兽以外的怪兽
function c16165939.spfilter(c,e,tp)
	return not c:IsType(TYPE_EFFECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动选择目标阶段，检查是否有满足条件的怪兽可特殊召唤
function c16165939.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，检查玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足发动条件，检查手卡·卡组·墓地是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c16165939.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果处理信息，确定要特殊召唤的怪兽数量及来源
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 特殊召唤效果的发动处理阶段，从手卡·卡组·墓地选择怪兽进行特殊召唤
function c16165939.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足发动条件，检查玩家场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组·墓地选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c16165939.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以特殊召唤方式召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
