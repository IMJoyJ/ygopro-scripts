--マンモス・ゾンビ
-- 效果：
-- 自己墓地没有不死族怪兽存在的场合，这张卡破坏。场上表侧表示存在的这张卡被破坏的场合，给与那个时候的控制者这张卡的原本攻击力数值的伤害。
function c43642620.initial_effect(c)
	-- 效果原文：自己墓地没有不死族怪兽存在的场合，这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SELF_DESTROY)
	e1:SetCondition(c43642620.sdcon)
	c:RegisterEffect(e1)
	-- 效果原文：场上表侧表示存在的这张卡被破坏的场合，给与那个时候的控制者这张卡的原本攻击力数值的伤害。
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
-- 检索满足条件的卡片组，检查自己墓地是否存在不死族怪兽
function c43642620.sdcon(e)
	-- 若自己墓地不存在不死族怪兽，则满足条件
	return not Duel.IsExistingMatchingCard(Card.IsRace,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,RACE_ZOMBIE)
end
-- 判断场上的这张卡是否因破坏而离场且为正面表示
function c43642620.dmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousPosition(POS_FACEUP)
end
-- 设置连锁处理时的目标玩家和伤害值
function c43642620.dmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 将目标玩家设置为该卡离开场时的控制者
	Duel.SetTargetPlayer(c:GetPreviousControler())
	-- 将目标参数设置为1900（攻击力数值）
	Duel.SetTargetParam(1900)
	-- 设置操作信息为伤害效果，目标玩家为之前设定的玩家，伤害值为1900
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,c:GetPreviousControler(),1900)
end
-- 执行伤害效果，对目标玩家造成指定数值的伤害
function c43642620.dmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果为原因，对指定玩家造成指定数值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
