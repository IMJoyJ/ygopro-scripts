--ナチュル・ストロベリー
-- 效果：
-- 对方对怪兽的召唤·特殊召唤成功时，直到这个回合的结束阶段时这张卡的攻击力上升召唤·特殊召唤的1只怪兽的等级×100的数值。这个效果1回合只能使用1次。
function c55099248.initial_effect(c)
	-- 对方对怪兽的召唤·特殊召唤成功时，直到这个回合的结束阶段时这张卡的攻击力上升召唤·特殊召唤的1只怪兽的等级×100的数值。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55099248,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetTarget(c55099248.atktg)
	e1:SetOperation(c55099248.atkop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤满足“由对方召唤·特殊召唤成功、在场上表侧表示且可以成为效果对象”条件的怪兽
function c55099248.filter(c,e,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsCanBeEffectTarget(e) and c:IsSummonPlayer(1-tp)
end
-- 效果发动的目标选择阶段，确认是否有满足条件的怪兽被召唤·特殊召唤，并选择其中1只作为效果的对象
function c55099248.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c55099248.filter(chkc,e,tp) end
	if chk==0 then return eg:IsExists(c55099248.filter,1,nil,e,tp) end
	-- 给玩家发送提示信息，要求选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local g=eg:FilterSelect(tp,c55099248.filter,1,1,nil,e,tp)
	-- 将选择的怪兽组设置为当前连锁的效果处理对象
	Duel.SetTargetCard(g)
end
-- 效果处理阶段，若自身和目标怪兽均表侧表示存在，则使自身攻击力上升目标怪兽等级×100的数值，直到回合结束
function c55099248.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 直到这个回合的结束阶段时这张卡的攻击力上升召唤·特殊召唤的1只怪兽的等级×100的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetLevel()*100)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
