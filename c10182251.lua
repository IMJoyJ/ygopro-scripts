--LL－ベリル・カナリー
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡存在的场合，以自己墓地1只「抒情歌鸲」怪兽为对象才能发动。这张卡和作为对象的怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
-- ②：场上的这张卡为素材作超量召唤的风属性怪兽得到以下效果。
-- ●这张卡的攻击力上升200，不能把控制权变更。
function c10182251.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，以自己墓地1只「抒情歌鸲」怪兽为对象才能发动。这张卡和作为对象的怪兽特殊召唤
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
	-- ②：场上的这张卡为素材作超量召唤的风属性怪兽得到以下效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCondition(c10182251.efcon)
	e2:SetOperation(c10182251.efop)
	c:RegisterEffect(e2)
end
-- 定义筛选函数，用于检查卡片是否为抒情歌鸲怪兽且可以被特殊召唤
function c10182251.spfilter(c,e,tp)
	return c:IsSetCard(0xf7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置①效果的目标选择条件，检查特殊召唤所需的各种要求
function c10182251.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c10182251.spfilter(chkc,e,tp) end
	-- 检查玩家是否受到禁止多重特殊召唤的效果影响（如古遗物运动）
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查玩家主要怪兽区是否有至少2个空位，以同时特殊召唤自己和对象怪兽
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查墓地是否存在符合条件的抒情歌鸲怪兽作为对象
		and Duel.IsExistingTarget(c10182251.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示提示信息，要求选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 让玩家从墓地中选择一只抒情歌鸲怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c10182251.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	g:AddCard(c)
	-- 设置操作信息，宣布将要特殊召唤两只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 定义①效果的处理函数，执行特殊召唤和后续限制
function c10182251.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取玩家在目标选择阶段选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 再次确认玩家未受禁止多重特殊召唤效果影响且有足够位置
		and not Duel.IsPlayerAffectedByEffect(tp,59822133) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 then
		local g=Group.FromCards(c,tc)
		-- 将这张卡和对象怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(c10182251.splimit)
	-- 注册限制效果，限制玩家在回合结束前不能从额外卡组特殊召唤非超量怪兽
	Duel.RegisterEffect(e1,tp)
end
-- 定义限制函数，判断是否为额外卡组的非超量怪兽
function c10182251.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_XYZ)
end
-- 检查这张卡是否作为风属性超量怪兽的素材
function c10182251.efcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return r==REASON_XYZ and c:IsPreviousLocation(LOCATION_ONFIELD) and c:GetReasonCard():IsAttribute(ATTRIBUTE_WIND)
end
-- 当这张卡作为风属性超量怪兽素材时，给该怪兽添加效果
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
	-- 不能把控制权变更
	local e2=Effect.CreateEffect(rc)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e2,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- 场上的这张卡为素材作超量召唤的风属性怪兽得到以下效果
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_ADD_TYPE)
		e3:SetValue(TYPE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e3,true)
	end
end
