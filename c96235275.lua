--ライトロード・パラディン ジェイン
-- 效果：
-- ①：这张卡向对方怪兽攻击的伤害步骤内，这张卡的攻击力上升300。
-- ②：自己结束阶段发动。从自己卡组上面把2张卡送去墓地。
function c96235275.initial_effect(c)
	-- ①：这张卡向对方怪兽攻击的伤害步骤内，这张卡的攻击力上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(c96235275.condtion)
	e1:SetValue(300)
	c:RegisterEffect(e1)
	-- ②：自己结束阶段发动。从自己卡组上面把2张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetDescription(aux.Stringid(96235275,0))  --"从卡组送2张卡去墓地"
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c96235275.discon)
	e2:SetTarget(c96235275.distg)
	e2:SetOperation(c96235275.disop)
	c:RegisterEffect(e2)
end
-- 判断是否处于伤害步骤或伤害计算时，且这张卡向对方怪兽发起攻击
function c96235275.condtion(e)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL)
		-- 判断攻击怪兽是否为本卡，且攻击对象不为空（即向对方怪兽攻击）
		and Duel.GetAttacker()==e:GetHandler() and Duel.GetAttackTarget()~=nil
end
-- 判断是否为自己的结束阶段
function c96235275.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return tp==Duel.GetTurnPlayer()
end
-- 设置效果发动目标，并向系统宣告将要进行卡组送墓的操作
function c96235275.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将自己卡组的2张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
end
-- 执行将卡组最上方2张卡送去墓地的效果处理
function c96235275.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 将自己卡组最上方的2张卡因效果送去墓地
	Duel.DiscardDeck(tp,2,REASON_EFFECT)
end
