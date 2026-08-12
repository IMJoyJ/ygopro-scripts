--DDD超死偉王パープリッシュ・ヘル・アーマゲドン
-- 效果：
-- ←1 【灵摆】 1→
-- ①：1回合1次，自己的「DDD」融合怪兽和对方怪兽进行战斗的伤害计算前才能发动。那只对方怪兽的攻击力直到回合结束时下降1000。
-- 【怪兽效果】
-- 「DDD」怪兽×2
-- 这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：以对方场上1只攻击表示怪兽为对象才能发动。那只怪兽破坏，给与对方破坏的怪兽的原本攻击力一半数值的伤害。
-- ②：对方怪兽进行战斗的伤害计算前才能发动。那只对方怪兽的攻击力直到伤害步骤结束时变成原本数值。
-- ③：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
function c84569886.initial_effect(c)
	c:EnableReviveLimit()
	-- 启用灵摆怪兽属性，但不注册灵摆卡的发动效果
	aux.EnablePendulumAttribute(c,false)
	-- 注册融合召唤手续，需要2只「DDD」怪兽作为素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x10af),2,true)
	-- ①：1回合1次，自己的「DDD」融合怪兽和对方怪兽进行战斗的伤害计算前才能发动。那只对方怪兽的攻击力直到回合结束时下降1000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84569886,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_CONFIRM)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c84569886.atkcon1)
	e1:SetOperation(c84569886.atkop1)
	c:RegisterEffect(e1)
	-- ①：以对方场上1只攻击表示怪兽为对象才能发动。那只怪兽破坏，给与对方破坏的怪兽的原本攻击力一半数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84569886,1))  --"对方怪兽破坏"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,84569886)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c84569886.destg)
	e2:SetOperation(c84569886.desop)
	c:RegisterEffect(e2)
	-- ②：对方怪兽进行战斗的伤害计算前才能发动。那只对方怪兽的攻击力直到伤害步骤结束时变成原本数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(84569886,2))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_CONFIRM)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c84569886.atkcon2)
	e3:SetOperation(c84569886.atkop2)
	c:RegisterEffect(e3)
	-- ③：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(84569886,3))
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCondition(c84569886.pencon)
	e6:SetTarget(c84569886.pentg)
	e6:SetOperation(c84569886.penop)
	c:RegisterEffect(e6)
end
-- 灵摆效果①的发动条件判定（伤害计算前，己方「DDD」融合怪兽与对方怪兽战斗）
function c84569886.atkcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击的怪兽
	local a=Duel.GetAttacker()
	local d=a:GetBattleTarget()
	if a:IsControler(1-tp) then a,d=d,a end
	return a and d and a:IsFaceup() and a:IsRelateToBattle() and a:IsSetCard(0x10af) and a:IsType(TYPE_FUSION)
		and d:IsFaceup() and d:IsRelateToBattle() and d:GetAttack()>0 and a:GetControler()~=d:GetControler()
end
-- 灵摆效果①的效果处理（对方怪兽攻击力下降1000）
function c84569886.atkop1(e,tp,ep,ev,re,r,rp)
	-- 获取当前进行攻击的怪兽
	local a=Duel.GetAttacker()
	local d=a:GetBattleTarget()
	if a:IsControler(1-tp) then a,d=d,a end
	if e:GetHandler():IsRelateToEffect(e)
		and d:IsFaceup() and d:IsRelateToBattle() then
		-- 那只对方怪兽的攻击力直到回合结束时下降1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		d:RegisterEffect(e1)
	end
end
-- 怪兽效果①的发动目标选择与效果声明（选择对方场上1只攻击表示怪兽，并声明破坏与伤害处理）
function c84569886.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsPosition(POS_FACEUP_ATTACK) end
	-- 检查对方场上是否存在可以作为对象的表侧表示攻击表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsPosition,tp,0,LOCATION_MZONE,1,nil,POS_FACEUP_ATTACK) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只表侧表示攻击表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsPosition,tp,0,LOCATION_MZONE,1,1,nil,POS_FACEUP_ATTACK)
	local atk=math.floor(g:GetFirst():GetBaseAttack()/2)
	if atk<0 then atk=0 end
	-- 设置破坏操作的信息，包含目标怪兽组
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置伤害操作的信息，包含伤害数值和受伤害玩家
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
-- 怪兽效果①的效果处理（破坏对象怪兽并给予对方其原本攻击力一半的伤害）
function c84569886.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local atk=math.floor(tc:GetBaseAttack()/2)
		if atk<0 then atk=0 end
		-- 尝试破坏目标怪兽，若成功破坏则执行后续处理
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			-- 给予对方玩家相当于被破坏怪兽原本攻击力一半数值的伤害
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end
-- 怪兽效果②的发动条件判定（对方怪兽进行战斗的伤害计算前，且该怪兽攻击力不等于原本攻击力）
function c84569886.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击的怪兽
	local a=Duel.GetAttacker()
	local d=a:GetBattleTarget()
	if a:IsControler(tp) then a,d=d,a end
	return a and a:IsControler(1-tp) and not a:IsAttack(a:GetBaseAttack())
end
-- 怪兽效果②的效果处理（使对方怪兽的攻击力变成原本数值）
function c84569886.atkop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击的怪兽
	local tc=Duel.GetAttacker()
	if tc:IsControler(tp) then tc=tc:GetBattleTarget() end
	if tc and tc:IsFaceup() and not tc:IsAttack(tc:GetBaseAttack()) then
		-- 那只对方怪兽的攻击力直到伤害步骤结束时变成原本数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetBaseAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		tc:RegisterEffect(e1)
	end
end
-- 怪兽效果③的发动条件判定（怪兽区域的这张卡被破坏的场合）
function c84569886.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 怪兽效果③的发动目标判定（检查自己的灵摆区域是否有空位）
function c84569886.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的左或右灵摆区域是否有空位
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 怪兽效果③的效果处理（将这张卡在自己的灵摆区域放置）
function c84569886.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡移动到自己的灵摆区域表侧表示放置
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
