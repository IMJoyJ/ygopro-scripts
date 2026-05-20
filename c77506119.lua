--サンダー・ユニコーン
-- 效果：
-- 兽族调整＋调整以外的怪兽1只以上
-- 1回合1次，自己的主要阶段时选择对方场上表侧表示存在的1只怪兽才能发动。选择的怪兽的攻击力直到结束阶段时下降自己场上存在的怪兽数量×500的数值。这个效果发动的回合，这张卡以外的怪兽不能攻击。
function c77506119.initial_effect(c)
	-- 设置同调召唤手续：兽族调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_BEAST),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 1回合1次，自己的主要阶段时选择对方场上表侧表示存在的1只怪兽才能发动。选择的怪兽的攻击力直到结束阶段时下降自己场上存在的怪兽数量×500的数值。这个效果发动的回合，这张卡以外的怪兽不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77506119,0))  --"攻击下降"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c77506119.atkcon)
	e1:SetTarget(c77506119.atktg)
	e1:SetOperation(c77506119.atkop)
	c:RegisterEffect(e1)
end
-- 定义效果发动的条件函数，限制在主要阶段1发动
function c77506119.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前阶段是否为主要阶段1
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 定义效果的目标选择与合法性检测函数
function c77506119.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 在发动阶段，检测对方场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 向发动效果的玩家发送提示信息，要求选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 定义效果处理的执行函数，包含降低攻击力和限制其他怪兽攻击
function c77506119.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 选择的怪兽的攻击力直到结束阶段时下降自己场上存在的怪兽数量×500的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		-- 计算并设置攻击力下降的数值，为自己场上的怪兽数量乘以-500
		e1:SetValue(Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)*-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 这个效果发动的回合，这张卡以外的怪兽不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c77506119.atlimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 向玩家注册全局效果，限制本回合其他怪兽的攻击
	Duel.RegisterEffect(e2,tp)
end
-- 定义不能攻击的怪兽过滤条件，即自身以外的怪兽
function c77506119.atlimit(e,c)
	return c~=e:GetOwner()
end
