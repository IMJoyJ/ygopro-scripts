--サイバース・クアンタム・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：只要自己场上有连接怪兽存在，对方不能选择这张卡以外的自己场上的怪兽作为攻击对象，也不能作为效果的对象。
-- ②：1回合1次，这张卡和对方怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽回到持有者手卡。这个效果发动的场合，这张卡只再1次可以继续攻击。
function c63533837.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ②：1回合1次，这张卡和对方怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽回到持有者手卡。这个效果发动的场合，这张卡只再1次可以继续攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63533837,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetCountLimit(1)
	e1:SetTarget(c63533837.thtg)
	e1:SetOperation(c63533837.thop)
	c:RegisterEffect(e1)
	-- ①：只要自己场上有连接怪兽存在，对方不能选择这张卡以外的自己场上的怪兽……作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c63533837.tgcon)
	e2:SetTarget(c63533837.tgtg)
	-- 设置不能成为对方卡片效果的对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ①：只要自己场上有连接怪兽存在，对方不能选择这张卡以外的自己场上的怪兽作为攻击对象……
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(c63533837.tgcon)
	e3:SetValue(c63533837.tgtg)
	c:RegisterEffect(e3)
end
-- 保护效果的适用条件：自己场上存在连接怪兽
function c63533837.tgcon(e)
	-- 检查自己场上是否存在至少1只连接怪兽
	return Duel.IsExistingMatchingCard(Card.IsType,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,TYPE_LINK)
end
-- 过滤除自身以外的自己场上的怪兽
function c63533837.tgtg(e,c)
	return c~=e:GetHandler()
end
-- 弹回手牌效果的发动条件与效果处理准备
function c63533837.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if chk==0 then return tc and tc:IsAbleToHand() end
	-- 设置操作信息，表示该效果的处理为将1张卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,0,0)
end
-- 弹回手牌效果的实际处理：将对方怪兽送回手牌，并使自身可以再进行1次攻击
function c63533837.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 如果自身是攻击方，则将战斗目标（被攻击方）设为要操作的对方怪兽
	if c==tc then tc=Duel.GetAttackTarget() end
	if tc and tc:IsRelateToBattle() then
		-- 因效果将对方怪兽送回持有者手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
	if c:IsRelateToEffect(e) and c:IsChainAttackable() then
		-- 使这张卡可以再进行1次攻击
		Duel.ChainAttack()
	end
end
