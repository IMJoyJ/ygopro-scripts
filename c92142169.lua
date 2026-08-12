--パクバグ
-- 效果：
-- 对方场上有超量怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤成功时，选择对方场上1只怪兽发动。选择的怪兽的攻击力下降300。
function c92142169.initial_effect(c)
	-- 对方场上有超量怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c92142169.spcon)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- 这个方法特殊召唤成功时，选择对方场上1只怪兽发动。选择的怪兽的攻击力下降300。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92142169,0))  --"攻击下降"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c92142169.atkcon)
	e2:SetTarget(c92142169.atktg)
	e2:SetOperation(c92142169.atkop)
	c:RegisterEffect(e2)
end
-- 过滤表侧表示的超量怪兽
function c92142169.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 检查自身特殊召唤的条件是否满足（怪兽区域有空位且对方场上有超量怪兽存在）
function c92142169.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查对方场上是否存在至少1只表侧表示的超量怪兽
		Duel.IsExistingMatchingCard(c92142169.filter,c:GetControler(),0,LOCATION_MZONE,1,nil)
end
-- 检查是否是通过自身效果（这个方法）特殊召唤成功
function c92142169.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 攻击力下降效果的靶向（选择对象）处理，选择对方场上1只表侧表示怪兽
function c92142169.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return true end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择对方场上1只表侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 攻击力下降效果的执行处理，使选择的对象怪兽攻击力下降300
function c92142169.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 选择的怪兽的攻击力下降300。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
