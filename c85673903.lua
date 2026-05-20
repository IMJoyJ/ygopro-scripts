--オルターガイスト・フィジアラート
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在手卡存在，「幻变骚灵」连接怪兽在自己场上连接召唤时，以那只怪兽以外的场上1只连接怪兽为对象才能发动。这张卡在作为成为对象的怪兽所连接区的自己场上特殊召唤。这个回合，作为对象的怪兽也当作「幻变骚灵」怪兽使用。
function c85673903.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡在手卡存在，「幻变骚灵」连接怪兽在自己场上连接召唤时，以那只怪兽以外的场上1只连接怪兽为对象才能发动。这张卡在作为成为对象的怪兽所连接区的自己场上特殊召唤。这个回合，作为对象的怪兽也当作「幻变骚灵」怪兽使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85673903,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,85673903)
	e1:SetCondition(c85673903.spcon)
	e1:SetTarget(c85673903.sptg)
	e1:SetOperation(c85673903.spop)
	c:RegisterEffect(e1)
end
-- 过滤出自己场上表侧表示连接召唤成功的「幻变骚灵」连接怪兽
function c85673903.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x103) and c:IsControler(tp) and c:IsType(TYPE_LINK) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- 检查是否满足「幻变骚灵」连接怪兽在自己场上连接召唤时的发动条件
function c85673903.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c85673903.cfilter,1,nil,tp)
end
-- 过滤出场上可作为对象的连接怪兽，要求其指向的自己主要怪兽区域有空位且此卡可以特殊召唤
function c85673903.tgfilter(c,e,tp)
	if not c:IsType(TYPE_LINK) then return false end
	local zone=bit.band(c:GetLinkedZone(tp),0x1f)
	return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 效果发动的对象选择与合法性检测
function c85673903.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c85673903.tgfilter(chkc,e,tp) and chkc~=eg:GetFirst() end
	-- 检查场上是否存在除刚连接召唤的那只怪兽以外的、可作为对象的连接怪兽
	if chk==0 then return Duel.IsExistingTarget(c85673903.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,eg:GetFirst(),e,tp)
		-- 检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择1只除刚连接召唤的那只怪兽以外的场上的连接怪兽作为效果的对象
	Duel.SelectTarget(tp,c85673903.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,eg:GetFirst(),e,tp)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将此卡特殊召唤到作为对象的怪兽所连接区的自己场上，并使作为对象的怪兽也当作「幻变骚灵」怪兽使用
function c85673903.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local zone=bit.band(tc:GetLinkedZone(tp),0x1f)
	if c:IsRelateToEffect(e) and zone~=0 then
		-- 将此卡在作为对象的怪兽所指向的自己场上区域特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,zone)
	end
	-- 这个回合，作为对象的怪兽也当作「幻变骚灵」怪兽使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85673903,1))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_SETCODE)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(0x103)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
end
