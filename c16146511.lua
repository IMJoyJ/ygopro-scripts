--エヴォルテクター エヴェック
-- 效果：
-- ①：这张卡只要在场上·墓地存在，当作通常怪兽使用。
-- ②：可以把场上的当作通常怪兽使用的这张卡作为通常召唤作再1次召唤。那个场合这张卡变成当作效果怪兽使用并得到以下效果。
-- ●这张卡召唤·特殊召唤成功的场合，以「真化护法 主教」以外的自己墓地1只战士族·炎属性怪兽或者二重怪兽为对象才能发动。那只怪兽特殊召唤。这个卡名的这个效果1回合只能使用1次。
function c16146511.initial_effect(c)
	-- 为这张卡添加二重怪兽属性，使其在场上·墓地当作通常怪兽使用（对应①效果的基础设定）。
	aux.EnableDualAttribute(c)
	-- ●这张卡召唤·特殊召唤成功的场合，以「真化护法 主教」以外的自己墓地1只战士族·炎属性怪兽或者二重怪兽为对象才能发动。那只怪兽特殊召唤。这个卡名的这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16146511,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,16146511)
	-- 设置效果发动条件：这张卡处于再度召唤状态（即作为效果怪兽使用）。只有再1次召唤后，此特召效果才能发动。
	e1:SetCondition(aux.IsDualState)
	e1:SetTarget(c16146511.sptg)
	e1:SetOperation(c16146511.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 定义特殊召唤对象的选择条件：自己墓地的对象须为战士族且炎属性，或是二重怪兽；不能是卡名「真化护法 主教」的卡；且能够被当前效果特殊召唤。
function c16146511.spfilter(c,e,tp)
	return ((c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE)) or c:IsType(TYPE_DUAL)) and not c:IsCode(16146511) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的取对象处理函数：先处理已指定对象的情况（chkc）；再在发动时检查是否有空余怪兽区且墓地有合法对象，满足条件后进入正式选对象流程。
function c16146511.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c16146511.spfilter(chkc,e,tp) end
	-- 发动合法性检查：自己场上主要怪兽区有空闲区域，才有发动此特殊召唤效果的余地。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且墓地存在至少1张符合spfilter条件、并能成为此效果对象的卡，否则不能发动。
		and Duel.IsExistingTarget(c16146511.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向操作玩家显示‘请选择要特殊召唤的卡’的提示信息，用于接下来的选卡引导。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地的合法候选卡中选择1张作为效果对象，并将其登记为当前连锁的对象卡。
	local g=Duel.SelectTarget(tp,c16146511.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本连锁的操作信息：本效果将进行1次特殊召唤，对象为已选择的卡片；供其他卡或效果进行连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数：在效果结算时，将取对象阶段选择的怪兽特殊召唤到自己场上。
function c16146511.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁的对象中取得第一张卡（本效果为取1个对象，因此即所选的墓地怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 在检查召唤条件和苏生限制均满足后，将对象怪兽以表侧表示特殊召唤到发动者场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
