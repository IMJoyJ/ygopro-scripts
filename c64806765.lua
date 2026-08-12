--破魔のカラス天狗
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡被对方的效果破坏送去墓地的场合或者从墓地的特殊召唤成功的场合，以对方场上1只攻击表示怪兽为对象才能发动。那只怪兽破坏。
function c64806765.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡被对方的效果破坏送去墓地的场合……以对方场上1只攻击表示怪兽为对象才能发动。那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,64806765)
	e1:SetCondition(c64806765.descon1)
	e1:SetTarget(c64806765.destg)
	e1:SetOperation(c64806765.desop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c64806765.descon2)
	c:RegisterEffect(e2)
end
-- 判定发动条件：这张卡在己方控制下被对方的效果破坏并送去墓地
function c64806765.descon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and c:IsReason(REASON_DESTROY)
		and c:IsReason(REASON_EFFECT) and rp==1-tp
end
-- 判定发动条件：这张卡特殊召唤时的出处为墓地（即从墓地特殊召唤成功）
function c64806765.descon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_GRAVE)
end
-- 效果发动的目标选择与检测：以对方场上1只攻击表示怪兽为对象
function c64806765.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsAttackPos() and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 在发动阶段，检测对方场上是否存在可以作为对象的攻击表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsAttackPos,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发送选择要破坏的卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1只攻击表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAttackPos,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：将作为对象的怪兽破坏
function c64806765.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的第一个效果对象
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽在效果处理时仍与效果相关联，则将其因效果破坏
	if tc:IsRelateToEffect(e) then Duel.Destroy(tc,REASON_EFFECT) end
end
