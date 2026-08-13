--アポカテクイル
-- 效果：
-- 自己场上有调整表侧表示存在的场合，场上表侧表示存在的这张卡的等级当作5星使用。场上存在的这张卡被破坏送去墓地时，可以选择自己墓地存在的1只「太阳之神官」特殊召唤。
function c41158734.initial_effect(c)
	-- “自己场上有调整表侧表示存在的场合，场上表侧表示存在的这张卡的等级当作5星使用。”
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetCondition(c41158734.lvcon)
	e1:SetValue(5)
	c:RegisterEffect(e1)
	-- “场上存在的这张卡被破坏送去墓地时，可以选择自己墓地存在的1只「太阳之神官」特殊召唤。”
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetDescription(aux.Stringid(41158734,0))  --"特殊召唤"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c41158734.spcon)
	e2:SetTarget(c41158734.sptg)
	e2:SetOperation(c41158734.spop)
	c:RegisterEffect(e2)
end
-- 定义等级变化条件的过滤函数：判定卡片是否为表侧表示且为调整怪兽，用于检查自己场上是否存在表侧表示的调整。
function c41158734.lvfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TUNER)
end
-- 等级变化效果的发动条件：检查这张卡的控制者自己场上是否存在至少1只表侧表示调整怪兽。
function c41158734.lvcon(e)
	-- 通过Duel.IsExistingMatchingCard在自己主要怪兽区（LOCATION_MZONE）检索是否存在1只满足lvfilter（表侧表示调整怪兽）的卡片。
	return Duel.IsExistingMatchingCard(c41158734.lvfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤效果的触发条件：这张卡被破坏（REASON_DESTROY）且被破坏前位于场上（LOCATION_ONFIELD），即从场上被破坏送去墓地。
function c41158734.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsReason(REASON_DESTROY)
end
-- 特殊召唤对象过滤函数：选择自己墓地中卡号为42280216的「太阳之神官」，并确认该卡可以被当前效果以表侧表示特殊召唤。
function c41158734.spfilter(c,e,tp)
	return c:IsCode(42280216) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动时点处理：若在连锁确认对象时，检查对象是否为自己墓地且由自己控制并满足spfilter；若在发动合法性检查时，则确认自己怪兽区有空位且墓地存在符合条件的对象。
function c41158734.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c41158734.spfilter(chkc,e,tp) end
	-- 发动合法性检查之一：自己主要怪兽区是否存在可用的空位，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动合法性检查之二：自己墓地是否存在1只满足spfilter的「太阳之神官」可以作为效果对象。
		and Duel.IsExistingTarget(c41158734.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向操作者显示选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的「太阳之神官」作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c41158734.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息：本效果将进行1只怪兽的特殊召唤（CATEGORY_SPECIAL_SUMMON），对象为已选择的g。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果处理：从连锁中获取对象卡，若该卡仍与本效果存在关联，则将其表侧表示特殊召唤到控制者场上。
function c41158734.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中第一个被选择的对象卡，通常是发动时选择的墓地中的「太阳之神官」。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示（POS_FACEUP）特殊召唤到其持有者（tp）的场上，完成特殊召唤处理。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
