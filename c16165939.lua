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
-- 过滤条件：判断怪兽是否为表侧表示且不是效果怪兽，用于识别“效果怪兽以外的怪兽表侧表示特殊召唤”。
function c16165939.cfilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_EFFECT)
end
-- 发动条件：本次特殊召唤成功的怪兽集合中是否存在至少1只满足cfilter的怪兽（即包含效果怪兽以外的表侧表示怪兽）。
function c16165939.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c16165939.cfilter,1,nil)
end
-- 效果①的目标选择：取对方场上1张卡为对象；发动时确认有可选对象，选择1张对方场上的卡并设置破坏的操作信息。
function c16165939.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 发动时判定：检查对方场上是否存在至少1张能够成为效果对象的卡（aux.TRUE表示任意卡，但仍需可被取对象）。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 弹出发动时选择提示：请选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家从对方场上选择1张卡作为效果对象，同时将该卡登记为本次连锁的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：本连锁将破坏所选择的卡，数量为选择数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果①处理时的操作：取出对象卡，若其仍与该效果关联，则将其破坏。
function c16165939.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁第一个效果对象卡（此处即破坏对象）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以“效果”为原因将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 效果②的发动条件：这张卡原本在魔法与陷阱区域，且被对方玩家的效果破坏时才能发动（同时要求破坏前控制权为己方）。
function c16165939.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousControler(tp)
		and rp==1-tp and c:IsReason(REASON_EFFECT)
end
-- 可特殊召唤的怪兽的过滤条件：不是效果怪兽，且能够被效果特殊召唤（检查召唤条件和苏生限制）。
function c16165939.spfilter(c,e,tp)
	return not c:IsType(TYPE_EFFECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的目标选择条件：发动时确认自己主要怪兽区有空格，且手卡·卡组·墓地中存在满足条件的怪兽。
function c16165939.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定自己主要怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定手卡·卡组·墓地中是否存在至少1只满足spfilter的效果怪兽以外的怪兽。
		and Duel.IsExistingMatchingCard(c16165939.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：本连锁将从手卡·卡组·墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果②处理时的操作：自己主要怪兽区有空位时，从手卡·卡组·墓地选1只效果怪兽以外的怪兽（并受王家长眠之谷影响过滤）以表侧表示特殊召唤。
function c16165939.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己主要怪兽区有空位；若无空格则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出特殊召唤选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组·墓地选择1只效果怪兽以外的怪兽（过滤王家长眠之谷影响）作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c16165939.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。注意nocheck=false,nolimit=false，即会正常检查召唤条件与苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
