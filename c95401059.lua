--オルシャドール－セフィラルーツ
-- 效果：
-- ←7 【灵摆】 7→
-- ①：自己不是「影依」怪兽以及「神数」怪兽不能灵摆召唤。这个效果不会被无效化。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：这张卡灵摆召唤成功的场合或者这张卡被送去墓地的场合，以「绊影依-神数原核」以外的自己的灵摆区域1张「神数」卡为对象才能发动。那张卡特殊召唤。
function c95401059.initial_effect(c)
	-- 初始化灵摆怪兽属性，注册灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是「影依」怪兽以及「神数」怪兽不能灵摆召唤。这个效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c95401059.splimit)
	c:RegisterEffect(e2)
	-- ①：这张卡灵摆召唤成功的场合或者这张卡被送去墓地的场合，以「绊影依-神数原核」以外的自己的灵摆区域1张「神数」卡为对象才能发动。那张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,95401059)
	e3:SetCondition(c95401059.condition1)
	e3:SetTarget(c95401059.target)
	e3:SetOperation(c95401059.operation)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_TO_GRAVE)
	-- 将送去墓地时触发的效果条件设置为无条件（始终成立）
	e4:SetCondition(aux.TRUE)
	c:RegisterEffect(e4)
end
-- 灵摆召唤限制的判定函数，非「影依」或「神数」怪兽不能进行灵摆召唤
function c95401059.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(0x9d,0xc4) then return false end
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 检测此卡是否是通过灵摆召唤成功
function c95401059.condition1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 过滤出「绊影依-神数原核」以外的、可以特殊召唤的「神数」卡
function c95401059.filter(c,e,tp)
	return c:IsSetCard(0xc4) and not c:IsCode(95401059) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的对象选择与合法性检测（确认怪兽区域有空位，且灵摆区域存在合法的「神数」卡作为对象）
function c95401059.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) and c95401059.filter(chkc,e,tp) end
	-- 在发动效果时，检测自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测自己的灵摆区域是否存在至少1张符合条件的「神数」卡
		and Duel.IsExistingTarget(c95401059.filter,tp,LOCATION_PZONE,0,1,nil,e,tp) end
	-- 向玩家发送提示信息，要求选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己灵摆区域的1张符合条件的「神数」卡作为效果的对象
	local g=Duel.SelectTarget(tp,c95401059.filter,tp,LOCATION_PZONE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息，用于连锁处理和后续卡片效果的检测
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理的执行函数，将作为对象的卡特殊召唤
function c95401059.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片以表侧表示特殊召唤到发动效果的玩家场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
