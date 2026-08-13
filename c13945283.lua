--幻影の壁
-- 效果：
-- 向这张卡攻击的怪兽回到持有者手卡。伤害计算适用。
function c13945283.initial_effect(c)
	-- 向这张卡攻击的怪兽回到持有者手卡。伤害计算适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13945283,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetCondition(c13945283.condition)
	e1:SetTarget(c13945283.target)
	e1:SetOperation(c13945283.operation)
	c:RegisterEffect(e1)
end
-- 效果的发动条件判定：当这张卡成为攻击目标（攻击对象为此卡），且攻击怪兽未被战斗破坏确定（未处于STATUS_BATTLE_DESTROYED状态）时，该诱发效果满足发动条件。
function c13945283.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 具体判定：本次战斗的攻击目标是这张卡自身，并且攻击怪兽不带有STATUS_BATTLE_DESTROYED状态（即未因本次战斗被确定破坏）。
	return Duel.GetAttackTarget()==e:GetHandler() and not Duel.GetAttacker():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 效果发动时的目标处理：该效果不取对象，因此无需选择目标；target函数在chk==0时返回true允许发动，在chk==1时设置操作信息，声明将把攻击怪兽返回手牌（CATEGORY_TOHAND）。
function c13945283.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次连锁的操作信息：声明将把当前攻击怪兽返回持有者手牌（CATEGORY_TOHAND），对象指定为攻击怪兽，数量为1，所属玩家和位置参数为0（不指定），使其他卡能正确检测该效果。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,Duel.GetAttacker(),1,0,0)
end
-- 效果处理时的执行操作：获取当前攻击怪兽，若它仍然与本次战斗相关（未离场），则将其返回持有者手卡；若已离场则不做处理。
function c13945283.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗的攻击怪兽，存入局部变量a以便后续处理。
	local a=Duel.GetAttacker()
	if not a:IsRelateToBattle() then return end
	-- 以“效果”这一原因为处理方式，将攻击怪兽a送回其持有者的手卡（nil表示返回持有者手卡）。
	Duel.SendtoHand(a,nil,REASON_EFFECT)
end
