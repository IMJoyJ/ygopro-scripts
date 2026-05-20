--サイコ・エンド・パニッシャー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：自己基本分是对方基本分以下的场合，同调召唤的这张卡不受对方发动的效果影响。
-- ②：1回合1次，支付1000基本分，以自己场上1只怪兽和对方场上1张卡为对象才能发动。那些卡除外。
-- ③：自己·对方的战斗阶段开始时才能发动。这张卡的攻击力上升双方基本分差的数值。
function c60465049.initial_effect(c)
	-- 设置同调召唤的手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：自己基本分是对方基本分以下的场合，同调召唤的这张卡不受对方发动的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c60465049.imcon)
	e1:SetValue(c60465049.efilter)
	c:RegisterEffect(e1)
	-- ②：1回合1次，支付1000基本分，以自己场上1只怪兽和对方场上1张卡为对象才能发动。那些卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(60465049,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCost(c60465049.rmcost)
	e2:SetTarget(c60465049.rmtg)
	e2:SetOperation(c60465049.rmop)
	c:RegisterEffect(e2)
	-- ③：自己·对方的战斗阶段开始时才能发动。这张卡的攻击力上升双方基本分差的数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(60465049,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c60465049.atktg)
	e3:SetOperation(c60465049.atkop)
	c:RegisterEffect(e3)
end
-- 效果①不受影响的判定条件函数
function c60465049.imcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己基本分是否在对方基本分以下，且自身是否为同调召唤
	return Duel.GetLP(tp)<=Duel.GetLP(1-tp) and e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤不受影响的效果：对方玩家发动的效果
function c60465049.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActivated()
end
-- 效果②的支付代价（Cost）函数
function c60465049.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 扣除玩家1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 效果②的靶向（Target）函数，用于检查和选择除外对象
function c60465049.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在可以除外的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在可以除外的卡
		and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己场上1只可以除外的怪兽作为对象
	local g1=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1张可以除外的卡作为对象
	local g2=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置效果处理信息：除外选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,g1:GetCount(),0,0)
end
-- 效果②的效果处理（Operation）函数
function c60465049.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象的所有卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将作为对象且仍存在于场上的卡片表侧表示除外
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	end
end
-- 效果③的靶向（Target）函数，检查双方基本分是否有差值
function c60465049.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方基本分差值是否大于0
	if chk==0 then return math.abs(Duel.GetLP(tp)-Duel.GetLP(1-tp))>0 end
end
-- 效果③的效果处理（Operation）函数
function c60465049.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升双方基本分差的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		-- 设置攻击力上升的数值为双方基本分差的绝对值
		e1:SetValue(math.abs(Duel.GetLP(tp)-Duel.GetLP(1-tp)))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
