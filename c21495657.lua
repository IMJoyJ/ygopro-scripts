--宝竜星－セフィラフウシ
-- 效果：
-- ←1 【灵摆】 1→
-- ①：自己不是「龙星」怪兽以及「神数」怪兽不能灵摆召唤。这个效果不会被无效化。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：这张卡灵摆召唤或者从卡组的特殊召唤成功的场合，以「宝龙星-神数负屃」以外的自己场上1只「龙星」怪兽或者「神数」怪兽为对象才能发动。这个回合，那只表侧表示怪兽当作调整使用。这个效果发动过的这张卡从场上离开的场合回到持有者卡组最下面。
function c21495657.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是「龙星」怪兽以及「神数」怪兽不能灵摆召唤。这个效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c21495657.splimit)
	c:RegisterEffect(e2)
	-- ①：这张卡灵摆召唤或者从卡组的特殊召唤成功的场合，以「宝龙星-神数负屃」以外的自己场上1只「龙星」怪兽或者「神数」怪兽为对象才能发动。这个回合，那只表侧表示怪兽当作调整使用。这个效果发动过的这张卡从场上离开的场合回到持有者卡组最下面。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,21495657)
	e3:SetCondition(c21495657.condition)
	e3:SetTarget(c21495657.target)
	e3:SetOperation(c21495657.operation)
	c:RegisterEffect(e3)
end
-- 限制非「龙星」或「神数」怪兽进行灵摆召唤
function c21495657.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(0x9e,0xc4) then return false end
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 判断此卡是否为灵摆召唤或从卡组特殊召唤成功
function c21495657.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM) or e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end
-- 筛选场上表侧表示的「龙星」或「神数」怪兽（非调整且非自身）
function c21495657.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9e,0xc4) and not c:IsType(TYPE_TUNER) and not c:IsCode(21495657)
end
-- 选择符合条件的场上表侧表示的「龙星」或「神数」怪兽作为效果对象
function c21495657.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c21495657.filter(chkc) end
	-- 判断是否存在符合条件的场上表侧表示的「龙星」或「神数」怪兽
	if chk==0 then return Duel.IsExistingTarget(c21495657.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上表侧表示的「龙星」或「神数」怪兽作为效果对象
	Duel.SelectTarget(tp,c21495657.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 将选中的怪兽变为调整类型，并在该卡离开场时回到卡组最下面
function c21495657.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将目标怪兽变为调整类型
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(TYPE_TUNER)
		tc:RegisterEffect(e1)
	end
	if c:IsRelateToEffect(e) then
		-- 使此卡离开场时回到持有者卡组最下面
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e2:SetValue(LOCATION_DECKBOT)
		c:RegisterEffect(e2)
	end
end
