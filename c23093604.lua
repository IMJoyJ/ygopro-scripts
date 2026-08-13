--X－セイバー パシウル
-- 效果：
-- ①：这张卡不会被战斗破坏。
-- ②：对方准备阶段发动。自己受到1000伤害。这个效果在这张卡在怪兽区域表侧守备表示存在的场合进行发动和处理。
function c23093604.initial_effect(c)
	-- ②：对方准备阶段发动。自己受到1000伤害。这个效果在这张卡在怪兽区域表侧守备表示存在的场合进行发动和处理。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23093604,0))  --"自己受到1000伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(c23093604.condition)
	e1:SetTarget(c23093604.target)
	e1:SetOperation(c23093604.operation)
	c:RegisterEffect(e1)
	-- ①：这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 效果②的发动条件判断：要求此卡在怪兽区域表侧守备表示存在，且当前为对方回合（即对方准备阶段），满足时效果才能发动。
function c23093604.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查此卡是否表侧守备表示，且当前回合玩家不是此卡控制者（即对方回合），确保只在对手准备阶段且此卡以表侧守备表示在场时发动。
	return e:GetHandler():IsFaceup() and e:GetHandler():IsDefensePos() and Duel.GetTurnPlayer()~=tp
end
-- 效果②发动时，将伤害对象设定为此卡的控制者（自己），伤害数值设为1000，并登记为造成伤害的效果操作信息。
function c23093604.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为此卡控制者（自己），作为伤害的承受者。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为1000，表示将要造成的伤害数值。
	Duel.SetTargetParam(1000)
	-- 登记本次操作信息，宣告该效果为对控制者造成1000点伤害的效果，供其他卡效果连锁或响应判定。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,1000)
end
-- 效果②实际处理阶段：先确认此卡仍与效果关联且仍为表侧守备表示，然后取出目标玩家和伤害数值，实际造成伤害。
function c23093604.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or not e:GetHandler():IsPosition(POS_FACEUP_DEFENSE) then return end
	-- 从当前连锁信息中取出之前设置的目标玩家p和伤害数值d，用于后续造成伤害。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对玩家p造成d点效果伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
