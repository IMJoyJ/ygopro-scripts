--インフェルニティ・デス・ドラゴン
-- 效果：
-- 暗属性调整＋调整以外的怪兽1只以上
-- 1回合1次，自己手卡是0张的场合选择对方场上存在的1只怪兽才能发动。选择的对方怪兽破坏，给与对方基本分破坏的怪兽的攻击力一半数值的伤害。这个效果发动的回合这张卡不能攻击。
function c72896720.initial_effect(c)
	-- 添加同调召唤手续：暗属性调整+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 1回合1次，自己手卡是0张的场合选择对方场上存在的1只怪兽才能发动。选择的对方怪兽破坏，给与对方基本分破坏的怪兽的攻击力一半数值的伤害。这个效果发动的回合这张卡不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_DESTROY)
	e1:SetDescription(aux.Stringid(72896720,0))  --"破坏"
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c72896720.descon)
	e1:SetCost(c72896720.descost)
	e1:SetTarget(c72896720.destg)
	e1:SetOperation(c72896720.desop)
	c:RegisterEffect(e1)
end
-- 发动条件：自己手卡是0张
function c72896720.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己手卡数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
end
-- 发动代价：本回合未进行攻击宣言，并使自身本回合不能攻击
function c72896720.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- 选择对方场上存在的1只怪兽才能发动。选择的对方怪兽破坏，给与对方基本分破坏的怪兽的攻击力一半数值的伤害。这个效果发动的回合这张卡不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1,true)
end
-- 效果目标：选择对方场上1只怪兽，并设置破坏与伤害的操作信息
function c72896720.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可作为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	local d=g:GetFirst()
	local atk=0
	if d:IsFaceup() then atk=d:GetAttack() end
	-- 设置操作信息：破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：给与对方该怪兽攻击力一半数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,math.floor(atk/2))
end
-- 效果处理：破坏选择的怪兽，并给与对方该怪兽攻击力一半数值的伤害
function c72896720.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local atk=0
		if tc:IsFaceup() then atk=tc:GetAttack() end
		-- 破坏选择的怪兽，若未成功破坏则结束处理
		if Duel.Destroy(tc,REASON_EFFECT)==0 then return end
		-- 给与对方该怪兽攻击力一半数值的伤害
		Duel.Damage(1-tp,math.floor(atk/2),REASON_EFFECT)
	end
end
