--教導国家ドラグマ
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要这张卡在场地区域存在，自己场上的「教导」怪兽不会成为从额外卡组特殊召唤的双方怪兽的效果的对象。
-- ②：自己的「教导」怪兽和对方怪兽进行战斗的伤害计算后才能发动。那只对方怪兽破坏。
-- ③：场地区域的表侧表示的这张卡被对方的效果破坏的场合才能发动。双方各自从自身的额外卡组把1只怪兽送去墓地。
function c65589010.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：只要这张卡在场地区域存在，自己场上的「教导」怪兽不会成为从额外卡组特殊召唤的双方怪兽的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_FZONE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c65589010.eftg)
	e1:SetValue(c65589010.efilter)
	c:RegisterEffect(e1)
	-- ②：自己的「教导」怪兽和对方怪兽进行战斗的伤害计算后才能发动。那只对方怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(65589010,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLED)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,65589010)
	e2:SetCondition(c65589010.descon)
	e2:SetTarget(c65589010.destg)
	e2:SetOperation(c65589010.desop)
	c:RegisterEffect(e2)
	-- ③：场地区域的表侧表示的这张卡被对方的效果破坏的场合才能发动。双方各自从自身的额外卡组把1只怪兽送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(65589010,1))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,65589011)
	e3:SetCondition(c65589010.tgcon)
	e3:SetTarget(c65589010.tgtg)
	e3:SetOperation(c65589010.tgop)
	c:RegisterEffect(e3)
end
-- 过滤自己场上表侧表示的「教导」怪兽
function c65589010.eftg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x145)
end
-- 过滤从额外卡组特殊召唤的、在怪兽区域发动效果的怪兽
function c65589010.efilter(e,re,rp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSummonLocation(LOCATION_EXTRA) and re:GetActivateLocation()==LOCATION_MZONE
end
-- 检查是否是自己场上的「教导」怪兽与对方怪兽进行战斗，并记录该对方怪兽
function c65589010.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local ac=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽
	local bc=Duel.GetAttackTarget()
	if not bc then return false end
	if not ac:IsControler(tp) then ac,bc=bc,ac end
	e:SetLabelObject(bc)
	return ac:IsFaceup() and ac:IsControler(tp) and ac:IsSetCard(0x145) and bc:IsControler(1-tp)
end
-- 效果2的发动准备，设置破坏对方怪兽的操作信息
function c65589010.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	if not bc then return false end
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为破坏1只对方怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
-- 效果2的处理，破坏进行战斗的那只对方怪兽
function c65589010.desop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc and bc:IsRelateToBattle() and bc:IsControler(1-tp) then
		-- 因效果破坏该对方怪兽
		Duel.Destroy(bc,REASON_EFFECT)
	end
end
-- 检查这张卡是否在场地区域表侧表示存在并被对方的效果破坏
function c65589010.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_FZONE) and c:IsPreviousControler(tp)
		and c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp
end
-- 效果3的发动准备，确认双方额外卡组都有可以送去墓地的卡，并设置送墓操作信息
function c65589010.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己额外卡组可以送去墓地的卡片组
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_EXTRA,0,nil)
	-- 获取对方额外卡组可以送去墓地的卡片组
	local g2=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_EXTRA,nil)
	if chk==0 then return g:GetCount()>0 and g2:GetCount()>0 end
	-- 设置当前连锁的操作信息为双方从额外卡组将共2张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,PLAYER_ALL,LOCATION_EXTRA)
end
-- 效果3的处理，双方各自从自身的额外卡组选择1只怪兽送去墓地
function c65589010.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己额外卡组是否存在至少1张可以送去墓地的卡
	if not Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_EXTRA,0,1,nil)
		-- 或者对方额外卡组不存在可以送去墓地的卡，则不处理效果
		or not Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_EXTRA,1,nil) then return end
	-- 获取当前的回合玩家（回合玩家先进行选择）
	local p=Duel.GetTurnPlayer()
	-- 获取当前回合玩家额外卡组中可以送去墓地的卡片组
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,p,LOCATION_EXTRA,0,nil)
	-- 给当前回合玩家发送选择送去墓地的卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:Select(p,1,1,nil)
	if sg:GetCount()>0 then
		-- 将当前回合玩家选中的卡因效果送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
	-- 获取非当前回合玩家额外卡组中可以送去墓地的卡片组
	local g2=Duel.GetMatchingGroup(Card.IsAbleToGrave,p,0,LOCATION_EXTRA,nil)
	-- 给非当前回合玩家发送选择送去墓地的卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,1-p,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg2=g2:Select(1-p,1,1,nil)
	if sg2:GetCount()>0 then
		-- 将非当前回合玩家选中的卡因效果送去墓地
		Duel.SendtoGrave(sg2,REASON_EFFECT)
	end
end
