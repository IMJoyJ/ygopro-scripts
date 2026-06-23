--LL－ベリル・カナリー
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡存在的场合，以自己墓地1只「抒情歌鸲」怪兽为对象才能发动。这张卡和作为对象的怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
-- ②：场上的这张卡为素材作超量召唤的风属性怪兽得到以下效果。
-- ●这张卡的攻击力上升200，不能把控制权变更。
function c10182251.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，以自己墓地1只「抒情歌鸲」怪兽为对象才能发动。这张卡和作为对象的怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10182251,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,10182251)
	e1:SetTarget(c10182251.sptg)
	e1:SetOperation(c10182251.spop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡为素材作超量召唤的风属性怪兽得到以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCondition(c10182251.efcon)
	e2:SetOperation(c10182251.efop)
	c:RegisterEffect(e2)
end
-- 墓地的「抒情歌鸲」怪兽的过滤条件
function c10182251.spfilter(c,e,tp)
	return c:IsSetCard(0xf7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①的效果的发动准备与对象选择：检测是否受「青眼精灵龙」影响、怪兽区域空格数，并以自己墓地1只「抒情歌鸲」怪兽为对象发动
function c10182251.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c10182251.spfilter(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 判定自己场上是否有2个以上的空余怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判定自己墓地是否存在可以特殊召唤的「抒情歌鸲」怪兽
		and Duel.IsExistingTarget(c10182251.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「抒情歌鸲」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c10182251.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	g:AddCard(c)
	-- 设置操作信息：此卡与作为对象的怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- ①的效果处理：特殊召唤手牌的此卡与作为对象的怪兽，并施加直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤的限制
function c10182251.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 then
		local g=Group.FromCards(c,tc)
		-- 将此卡和作为对象的怪兽特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。②：场上的这张卡为素材作超量召唤的风属性怪兽得到以下效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(c10182251.splimit)
	-- 给自身施加直到回合结束时不是超量怪兽不能从额外卡组特殊召唤的限制
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能特殊召唤超量怪兽以外的额外卡组怪兽
function c10182251.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_XYZ)
end
-- 触发条件：场上的此卡作为超量素材且超量召唤的怪兽是风属性
function c10182251.efcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return r==REASON_XYZ and c:IsPreviousLocation(LOCATION_ONFIELD) and c:GetReasonCard():IsAttribute(ATTRIBUTE_WIND)
end
-- 效果处理：使超量召唤的风属性怪兽获得攻击力上升200以及不能变更控制权的效果
function c10182251.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ●这张卡的攻击力上升200
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(10182251,1))  --"「抒情歌鸲-绿柱石金丝雀」效果适用中"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetValue(200)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	-- 不能把控制权变更。
	local e2=Effect.CreateEffect(rc)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e2,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- ●这张卡的攻击力上升200，不能把控制权变更。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_ADD_TYPE)
		e3:SetValue(TYPE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e3,true)
	end
end
