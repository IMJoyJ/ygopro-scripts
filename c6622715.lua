--エンコード・トーカー
-- 效果：
-- 电子界族怪兽2只以上
-- ①：1回合1次，这张卡所连接区的自己怪兽和比那只怪兽攻击力高的对方怪兽进行战斗的伤害计算前才能发动。那只自己怪兽不会被那次战斗破坏，那次战斗发生的对自己的战斗伤害变成0。那次伤害计算后，选这张卡或者这张卡所连接区1只自己怪兽，那个攻击力直到回合结束时上升那只进行战斗的对方怪兽的攻击力数值。
function c6622715.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤手续，需要2只以上的电子界族怪兽作为素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),2)
	-- ①：1回合1次，这张卡所连接区的自己怪兽和比那只怪兽攻击力高的对方怪兽进行战斗的伤害计算前才能发动。那只自己怪兽不会被那次战斗破坏，那次战斗发生的对自己的战斗伤害变成0。那次伤害计算后，选这张卡或者这张卡所连接区1只自己怪兽，那个攻击力直到回合结束时上升那只进行战斗的对方怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6622715,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_CONFIRM)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c6622715.condition)
	e1:SetOperation(c6622715.operation)
	c:RegisterEffect(e1)
end
-- 判断是否满足发动条件：这张卡所连接区的自己怪兽和比那只怪兽攻击力高的对方怪兽进行战斗的伤害计算前
function c6622715.condition(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup()
	-- 获取进行战斗的攻击怪兽
	local a=Duel.GetAttacker()
	local b=a:GetBattleTarget()
	if not b then return false end
	if a:IsControler(1-tp) then a,b=b,a end
	return a:GetControler()~=b:GetControler()
		and lg:IsContains(a) and a:IsFaceup() and b:IsFaceup()
		and b:GetAttack()>a:GetAttack()
end
-- 执行发动时的效果处理：使该自己怪兽不会被战斗破坏，对自己的战斗伤害变成0，并注册伤害计算后的追加效果
function c6622715.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取进行战斗的攻击怪兽
	local a=Duel.GetAttacker()
	local b=a:GetBattleTarget()
	if a:IsControler(1-tp) then a,b=b,a end
	if a:IsRelateToBattle() then
		-- 那只自己怪兽不会被那次战斗破坏
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		a:RegisterEffect(e1)
	end
	-- 那次战斗发生的对自己的战斗伤害变成0
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 为玩家注册免受战斗伤害的效果
	Duel.RegisterEffect(e2,tp)
	-- 那次伤害计算后，选这张卡或者这张卡所连接区1只自己怪兽，那个攻击力直到回合结束时上升那只进行战斗的对方怪兽的攻击力数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_BATTLED)
	e3:SetLabelObject(b)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(c6622715.atkop)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
	c:RegisterEffect(e3)
end
-- 伤害计算后，选择这张卡或其所连接区的1只自己怪兽，使其攻击力上升进行战斗的对方怪兽的攻击力数值
function c6622715.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local b=e:GetLabelObject()
	local lg=c:GetLinkedGroup()
	lg:AddCard(c)
	local tc=nil
	if lg:GetCount()==1 then
		tc=lg:GetFirst()
	else
		-- 提示玩家选择表侧表示的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		tc=lg:Select(tp,1,1,nil):GetFirst()
	end
	-- 在场上对选中的怪兽进行闪烁提示
	Duel.HintSelection(Group.FromCards(tc))
	-- 那个攻击力直到回合结束时上升那只进行战斗的对方怪兽的攻击力数值
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(b:GetAttack())
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
end
