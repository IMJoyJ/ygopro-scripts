--ジャンク・バーサーカー
-- 效果：
-- 「废品同调士」＋调整以外的怪兽1只以上
-- 把自己墓地存在的1只名字带有「废品」的怪兽从游戏中除外，选择对方场上表侧表示存在的1只怪兽发动。选择的对方怪兽的攻击力下降除外的怪兽的攻击力数值。此外，这张卡向守备表示怪兽攻击的场合，不进行伤害计算把那只怪兽破坏。
function c59771339.initial_effect(c)
	-- 在素材代码列表中添加「废品同调士」，用于效果关联或检索
	aux.AddMaterialCodeList(c,63977008)
	-- 添加同调召唤手续：以「废品同调士」为调整，加上1只以上调整以外的怪兽
	aux.AddSynchroProcedure(c,c59771339.tfilter,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 把自己墓地存在的1只名字带有「废品」的怪兽从游戏中除外，选择对方场上表侧表示存在的1只怪兽发动。选择的对方怪兽的攻击力下降除外的怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59771339,0))  --"攻击力下降"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c59771339.cost)
	e1:SetTarget(c59771339.target)
	e1:SetOperation(c59771339.operation)
	c:RegisterEffect(e1)
	-- 此外，这张卡向守备表示怪兽攻击的场合，不进行伤害计算把那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59771339,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCondition(c59771339.descon)
	e2:SetTarget(c59771339.destg)
	e2:SetOperation(c59771339.desop)
	c:RegisterEffect(e2)
end
c59771339.material_setcode=0x1017
-- 过滤同调素材中的调整怪兽：卡名为「废品同调士」或具有代替其作为同调素材的效果
function c59771339.tfilter(c)
	return c:IsCode(63977008) or c:IsHasEffect(20932152)
end
-- 过滤自己墓地中可以作为除外代价的名字带有「废品」的怪兽
function c59771339.cfilter(c)
	return c:IsSetCard(0x43) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果1（攻击力下降）的发动代价：将自己墓地1只名字带有「废品」的怪兽除外，并记录其攻击力
function c59771339.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己墓地是否存在至少1只满足条件的名字带有「废品」的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c59771339.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家发送提示信息，提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只满足条件的名字带有「废品」的怪兽
	local g=Duel.SelectMatchingCard(tp,c59771339.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	e:SetLabel(g:GetFirst():GetAttack())
	-- 将选择的怪兽表侧表示除外作为发动的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果1（攻击力下降）的发动目标：选择对方场上表侧表示存在的1只怪兽为对象
function c59771339.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 在发动阶段，检查对方场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 给玩家发送提示信息，提示选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择对方场上表侧表示存在的1只怪兽作为效果的对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果1（攻击力下降）的效果处理：使选择的对方怪兽的攻击力下降除外怪兽的攻击力数值
function c59771339.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的对方怪兽（效果对象）
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 选择的对方怪兽的攻击力下降除外的怪兽的攻击力数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 效果2（向守备表示怪兽攻击时破坏）的发动条件：这张卡向守备表示怪兽进行攻击的伤害步骤开始时
function c59771339.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次战斗的被攻击怪兽
	local d=Duel.GetAttackTarget()
	-- 检查攻击怪兽是否为自身，且被攻击怪兽存在并且处于守备表示
	return e:GetHandler()==Duel.GetAttacker() and d and d:IsDefensePos()
end
-- 效果2（向守备表示怪兽攻击时破坏）的发动目标：将攻击目标（被攻击怪兽）确定为破坏对象
function c59771339.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁的操作信息，表明该效果的处理是破坏1只被攻击的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttackTarget(),1,0,0)
end
-- 效果2（向守备表示怪兽攻击时破坏）的效果处理：不进行伤害计算把那只守备表示怪兽破坏
function c59771339.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次战斗的被攻击怪兽
	local d=Duel.GetAttackTarget()
	if d:IsRelateToBattle() then
		-- 通过效果将该被攻击怪兽破坏
		Duel.Destroy(d,REASON_EFFECT)
	end
end
