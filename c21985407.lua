--聖夜の降臨
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己·对方的主要阶段，可以从以下效果选择1个发动。
-- ●以自己场上1只龙族·光属性·7星怪兽为对象才能发动。那只怪兽回到持有者手卡。
-- ●从手卡把1只龙族·光属性·7星怪兽特殊召唤。
function c21985407.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己·对方的主要阶段，可以从以下效果选择1个发动。●以自己场上1只龙族·光属性·7星怪兽为对象才能发动。那只怪兽回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21985407,0))  --"回到手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCountLimit(1,21985407)
	e2:SetCondition(c21985407.condition)
	e2:SetTarget(c21985407.thtg)
	e2:SetOperation(c21985407.thop)
	c:RegisterEffect(e2)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己·对方的主要阶段，可以从以下效果选择1个发动。●从手卡把1只龙族·光属性·7星怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(21985407,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetCountLimit(1,21985407)
	e3:SetCondition(c21985407.condition)
	e3:SetTarget(c21985407.sptg)
	e3:SetOperation(c21985407.spop)
	c:RegisterEffect(e3)
end
-- 回手/特殊召唤共同的效果发动条件：当前阶段必须为主要阶段1或主要阶段2，即仅在自己·对方的主要阶段才能发动。
function c21985407.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段，用于判断是否处于主要阶段。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 回手效果的对象过滤规则：怪兽须为表侧表示、等级7、光属性、龙族，且能够被加入手卡。
function c21985407.thfilter(c)
	return c:IsFaceup() and c:IsLevel(7) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
-- 回手效果的目标选择与发动合法性判定：若指定对象则验证其位置/控制权/种族属性等级等；若首次判断则检查场上是否存在满足条件的对象；随后提示并选择对象，并设置回手牌的操作信息。
function c21985407.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c21985407.thfilter(chkc) end
	-- 发动合法性检查：自己场上是否存在至少1只符合条件的龙族·光属性·7星表侧怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c21985407.thfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向操作者显示选择提示，提示内容为“请选择要返回手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从自己场上选择1只符合条件的怪兽作为效果对象，并将该对象登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c21985407.thfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 登记本次连锁的处理信息：包含回手牌分类，对象为已选择的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 回手效果的实际处理：取出对象，若对象仍与该效果关联，则将其送回持有者手卡。
function c21985407.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理中登记的第一张对象卡（即回手目标）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将目标怪兽送往其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 特殊召唤对象的过滤规则：手牌中的怪兽须为等级7、光属性、龙族，且能够被当前效果特殊召唤。
function c21985407.spfilter(c,e,tp)
	return c:IsLevel(7) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的目标选择与发动合法性判定：检查主怪兽区是否有空位以及手牌是否存在满足条件的怪兽，满足则登记特殊召唤的操作信息。
function c21985407.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查之一：自己场上的主怪兽区是否存在可用的空格，若没有则无法发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动合法性检查之二：手牌中是否存在至少1只符合条件的龙族·光属性·7星怪兽可以被特殊召唤。
		and Duel.IsExistingMatchingCard(c21985407.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记本次连锁的处理信息：包含特殊召唤分类，预计从手卡特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 特殊召唤效果的实际处理：若场上仍有空位，则从手牌选择符合条件的怪兽并表侧表示特殊召唤。
function c21985407.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次确认自己场上是否有可用主怪兽区空格，若没有则效果处理失败并终止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作者显示选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌选择1只符合条件的龙族·光属性·7星怪兽。
	local g=Duel.SelectMatchingCard(tp,c21985407.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上（不检查召唤条件，不检查苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
