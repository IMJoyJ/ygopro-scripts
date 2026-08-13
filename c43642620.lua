--マンモス・ゾンビ
-- 效果：
-- 自己墓地没有不死族怪兽存在的场合，这张卡破坏。场上表侧表示存在的这张卡被破坏的场合，给与那个时候的控制者这张卡的原本攻击力数值的伤害。
function c43642620.initial_effect(c)
	-- 自己墓地没有不死族怪兽存在的场合，这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SELF_DESTROY)
	e1:SetCondition(c43642620.sdcon)
	c:RegisterEffect(e1)
	-- 场上表侧表示存在的这张卡被破坏的场合，给与那个时候的控制者这张卡的原本攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43642620,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c43642620.dmcon)
	e2:SetTarget(c43642620.dmtg)
	e2:SetOperation(c43642620.dmop)
	c:RegisterEffect(e2)
end
-- 定义自毁效果的条件函数：只要自己墓地没有不死族怪兽，就满足这张卡自我破坏的诱发条件。
function c43642620.sdcon(e)
	-- 检查自己墓地是否存在至少1只不死族怪兽；若不存在（not）则返回真，即满足自毁条件。
	return not Duel.IsExistingMatchingCard(Card.IsRace,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,RACE_ZOMBIE)
end
-- 定义伤害效果的触发条件：这张卡因被破坏而离场，并且离场前是表侧表示。
function c43642620.dmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousPosition(POS_FACEUP)
end
-- 伤害效果的发动时点判定与信息登记：若效果可以发动，则记录伤害对象为这张卡离场前的控制者，伤害数值为原本攻击力1900，并设置操作信息。
function c43642620.dmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 将当前连锁的对象玩家设置为这张卡被破坏离场前的控制者，即之后承受伤害的玩家。
	Duel.SetTargetPlayer(c:GetPreviousControler())
	-- 将当前连锁的对象参数设置为1900，即这张卡的原本攻击力数值，作为造成的伤害值。
	Duel.SetTargetParam(1900)
	-- 登记本次效果的操作信息：类别为造成伤害，目标玩家为这张卡离场前的控制者，伤害数值为1900；由于伤害对象已确定，targets设为nil。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,c:GetPreviousControler(),1900)
end
-- 定义伤害效果的实际处理函数：从连锁信息中取出之前登记的对象玩家和伤害数值，执行伤害。
function c43642620.dmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象玩家与对象参数，分别作为伤害承受者和伤害数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对玩家p造成d点效果伤害，完成伤害效果的处理。
	Duel.Damage(p,d,REASON_EFFECT)
end
