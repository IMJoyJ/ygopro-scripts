--Live☆Twin リィラ・トリート
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有「姬丝基勒」怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：「邪恶★双子」怪兽的战斗让自己或对方受到战斗伤害时，把墓地的这张卡除外，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力下降那次战斗伤害的数值。
function c81078880.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己场上有「姬丝基勒」怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,81078880+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c81078880.spcon)
	c:RegisterEffect(e1)
	-- ②的效果1回合只能使用1次。②：「邪恶★双子」怪兽的战斗让自己或对方受到战斗伤害时，把墓地的这张卡除外，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力下降那次战斗伤害的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(81078880,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,81078881)
	-- 把墓地的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(c81078880.atkcon)
	e2:SetTarget(c81078880.atktg)
	e2:SetOperation(c81078880.atkop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「姬丝基勒」怪兽
function c81078880.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x152)
end
-- 特殊召唤规则的条件：怪兽区域有空位且自己场上有「姬丝基勒」怪兽存在
function c81078880.spcon(e,c)
	if c==nil then return true end
	-- 检查当前玩家的怪兽区域是否有可用的空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查自己场上是否存在表侧表示的「姬丝基勒」怪兽
		Duel.IsExistingMatchingCard(c81078880.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：参与战斗的怪兽中包含「邪恶★双子」怪兽
function c81078880.cfilter(c)
	local bc=c:GetBattleTarget()
	return c:IsSetCard(0x2151) or (bc and bc:IsSetCard(0x2151))
end
-- 效果发动条件：发生战斗伤害的战斗中存在「邪恶★双子」怪兽
function c81078880.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c81078880.cfilter,1,nil)
end
-- 过滤条件：对方场上表侧表示且攻击力不为0的怪兽
function c81078880.atkfilter(c)
	return c:IsFaceup() and c:GetAttack()~=0
end
-- 效果的目标：选择对方场上1只表侧表示怪兽为对象
function c81078880.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c81078880.atkfilter(chkc) end
	-- 在效果发动时，检查对方场上是否存在符合条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c81078880.atkfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息，要求选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,c81078880.atkfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：使作为对象的怪兽的攻击力下降那次战斗伤害的数值
function c81078880.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力下降那次战斗伤害的数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(-ev)
		tc:RegisterEffect(e1)
	end
end
