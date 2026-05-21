--召喚獣アウゴエイデス
-- 效果：
-- 「召唤师 阿莱斯特」＋融合怪兽
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤成功的场合或者对方场上有怪兽特殊召唤的场合，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
-- ②：1回合1次，从自己墓地把1只融合怪兽除外才能发动。这张卡的攻击力直到对方回合结束时上升除外的怪兽的攻击力数值。
function c97300502.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续，需要「召唤师 阿莱斯特」和1只融合怪兽作为素材
	aux.AddFusionProcCodeFun(c,86120751,aux.FilterBoolFunction(Card.IsFusionType,TYPE_FUSION),1,true,true)
	-- ①：这张卡特殊召唤成功的场合或者对方场上有怪兽特殊召唤的场合，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97300502,0))  --"怪兽破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,97300502)
	e1:SetTarget(c97300502.destg)
	e1:SetOperation(c97300502.desop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(97300502,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c97300502.descon)
	c:RegisterEffect(e2)
	-- ②：1回合1次，从自己墓地把1只融合怪兽除外才能发动。这张卡的攻击力直到对方回合结束时上升除外的怪兽的攻击力数值。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(97300502,2))
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCost(c97300502.atkcost)
	e4:SetOperation(c97300502.atkop)
	c:RegisterEffect(e4)
end
-- 检查触发条件：特殊召唤的怪兽不包含自身，且其中有对方场上特殊召唤的怪兽
function c97300502.descon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(Card.IsControler,1,nil,1-tp)
end
-- 破坏效果的对象选择与发动准备函数
function c97300502.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置破坏效果的操作信息，包括目标卡片和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的执行函数
function c97300502.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤自己墓地中攻击力在1以上且可以除外的融合怪兽
function c97300502.atkfilter(c)
	return c:IsType(TYPE_FUSION) and c:IsAttackAbove(1) and c:IsAbleToRemoveAsCost()
end
-- 攻击力上升效果的发动代价处理函数
function c97300502.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在满足除外条件的融合怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c97300502.atkfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己墓地1只满足条件的融合怪兽
	local g=Duel.SelectMatchingCard(tp,c97300502.atkfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	local atk=g:GetFirst():GetAttack()
	e:SetLabel(atk)
	-- 将选中的融合怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 攻击力上升效果的执行函数
function c97300502.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local atk=e:GetLabel()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到对方回合结束时上升除外的怪兽的攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		c:RegisterEffect(e1)
	end
end
