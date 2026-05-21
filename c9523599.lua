--スタック・リバイバー
-- 效果：
-- 这个卡名的效果在决斗中只能使用1次。
-- ①：这张卡为素材作连接召唤的场合，以这张卡以外的自己墓地1只作为那次连接召唤的素材的4星以下的电子界族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
function c9523599.initial_effect(c)
	-- 这个卡名的效果在决斗中只能使用1次。①：这张卡为素材作连接召唤的场合，以这张卡以外的自己墓地1只作为那次连接召唤的素材的4星以下的电子界族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9523599,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCountLimit(1,9523599+EFFECT_COUNT_CODE_DUEL)
	e1:SetCondition(c9523599.spcon)
	e1:SetTarget(c9523599.sptg)
	e1:SetOperation(c9523599.spop)
	c:RegisterEffect(e1)
end
-- 判断此卡是否作为连接召唤的素材送去墓地
function c9523599.spcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_LINK
end
-- 过滤在自己墓地、4星以下、电子界族、可以成为效果对象且可以守备表示特殊召唤的怪兽
function c9523599.spfilter(c,e,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp) and c:IsLevelBelow(4) and c:IsRace(RACE_CYBERSE)
		and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动的目标选择与合法性检测，获取本次连接召唤的素材，并确认其中存在符合条件的怪兽
function c9523599.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local mg=e:GetHandler():GetReasonCard():GetMaterial()
	if chkc then return mg:IsContains(chkc) and c9523599.spfilter(chkc,e,tp) and chkc~=c end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and mg:IsExists(c9523599.spfilter,1,c,e,tp) end
	-- 给玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=mg:FilterSelect(tp,c9523599.spfilter,1,1,c,e,tp)
	-- 将选择的怪兽设置为效果处理的对象
	Duel.SetTargetCard(g)
	-- 设置效果处理的操作信息，表示该连锁将特殊召唤选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理，将作为对象的怪兽守备表示特殊召唤
function c9523599.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧守备表示特殊召唤到发动效果玩家的场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
