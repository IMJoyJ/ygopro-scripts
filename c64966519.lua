--激撮ディスパラッチ
-- 效果：
-- 效果怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡以外的自己怪兽被选择作为攻击对象时才能发动。攻击对象转移为这张卡进行伤害计算。
-- ②：这张卡被和对方怪兽的战斗破坏时才能发动。那只对方怪兽破坏，自己基本分回复那个原本攻击力一半的数值。
function c64966519.initial_effect(c)
	-- 添加连接召唤手续：效果怪兽2只
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2,2)
	c:EnableReviveLimit()
	-- ①：这张卡以外的自己怪兽被选择作为攻击对象时才能发动。攻击对象转移为这张卡进行伤害计算。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64966519,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,64966519)
	e1:SetCondition(c64966519.cbcon)
	e1:SetOperation(c64966519.cbop)
	c:RegisterEffect(e1)
	-- ②：这张卡被和对方怪兽的战斗破坏时才能发动。那只对方怪兽破坏，自己基本分回复那个原本攻击力一半的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(64966519,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCountLimit(1,64966520)
	e2:SetTarget(c64966519.target)
	e2:SetOperation(c64966519.operation)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：被选择作为攻击对象的怪兽是自己场上这张卡以外的怪兽
function c64966519.cbcon(e,tp,eg,ep,ev,re,r,rp)
	local bt=eg:GetFirst()
	return r~=REASON_REPLACE and bt~=e:GetHandler() and bt:IsControler(tp)
end
-- 效果①的效果处理：将攻击对象转移为此卡并进行伤害计算
function c64966519.cbop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 获取当前进行攻击的怪兽
		local at=Duel.GetAttacker()
		if at:IsAttackable() and not at:IsImmuneToEffect(e) and not c:IsImmuneToEffect(e) then
			-- 令攻击怪兽与此卡进行战斗伤害计算
			Duel.CalculateDamage(at,c)
		end
	end
end
-- 效果②的发动与目标确认：确认战斗过的对方怪兽存在，并设置破坏和回复的操作信息
function c64966519.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return bc:IsRelateToBattle() and bc:IsControler(1-tp) end
	-- 设置破坏该对方怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
	-- 设置回复自己生命值（数值为该怪兽原本攻击力一半）的操作信息
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,math.ceil(bc:GetBaseAttack()/2))
end
-- 效果②的效果处理：破坏战斗过的对方怪兽，并回复自己该怪兽原本攻击力一半数值的生命值
function c64966519.operation(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	-- 若成功破坏战斗过的对方怪兽且其原本攻击力大于0
	if bc:IsRelateToBattle() and Duel.Destroy(bc,REASON_EFFECT)>0 and bc:GetBaseAttack()>0 then
		-- 回复自己相当于该怪兽原本攻击力一半数值的生命值
		Duel.Recover(tp,math.ceil(bc:GetBaseAttack()/2),REASON_EFFECT)
	end
end
