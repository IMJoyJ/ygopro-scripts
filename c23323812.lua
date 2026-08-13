--念導力
-- 效果：
-- 自己场上表侧表示存在的念动力族怪兽被对方怪兽的攻击破坏的场合才能发动。那个时候进行攻击的1只对方怪兽破坏，自己基本分回复那个攻击力的数值。
function c23323812.initial_effect(c)
	-- 自己场上表侧表示存在的念动力族怪兽被对方怪兽的攻击破坏的场合才能发动。那个时候进行攻击的1只对方怪兽破坏，自己基本分回复那个攻击力的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c23323812.condition)
	e1:SetTarget(c23323812.target)
	e1:SetOperation(c23323812.activate)
	c:RegisterEffect(e1)
end
-- 筛选被战斗破坏的怪兽：必须是我方场上的、表侧表示、作为攻击对象且种族为念动力族的怪兽。
function c23323812.filter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP)
		-- 进一步限定：该怪兽必须是攻击对象（即受到攻击的怪兽），且种族为念动力族。
		and c==Duel.GetAttackTarget() and c:IsRace(RACE_PSYCHO)
end
-- 发动条件判定：本次被战斗破坏的怪兽组中，至少存在1只满足filter条件的念动力族怪兽。
function c23323812.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c23323812.filter,1,nil,tp)
end
-- 效果发动时的目标选择与信息设定：获取攻击怪兽，验证其属于对方、与本次战斗关联且能成为效果对象，然后将其设为对象并登记破坏与回复的操作信息。
function c23323812.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取进行攻击的那只对方怪兽。
	local at=Duel.GetAttacker()
	if chkc then return chkc==at end
	if chk==0 then return at:IsControler(1-tp) and at:IsRelateToBattle() and at:IsCanBeEffectTarget(e) end
	-- 将攻击怪兽设为当前连锁的效果对象。
	Duel.SetTargetCard(at)
	local atk=at:GetAttack()
	-- 设置操作信息：以效果破坏该攻击怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,at,1,0,0)
	-- 设置操作信息：预计回复自己基本分，数值为攻击怪兽的攻击力。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,atk)
end
-- 效果处理：取出对象怪兽，若其仍与效果关联则将其破坏；破坏成功时回复自己基本分，回复数值为被破坏怪兽的攻击力。
function c23323812.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时锁定的对象怪兽。
	local a=Duel.GetFirstTarget()
	if a:IsRelateToEffect(e) then
		local atk=a:GetAttack()
		-- 以效果原因破坏该怪兽，若破坏处理成功（返回值不为0）则继续执行回复。
		if Duel.Destroy(a,REASON_EFFECT)~=0 then
			-- 以效果原因回复自己基本分，回复量为被破坏怪兽的当前攻击力数值。
			Duel.Recover(tp,atk,REASON_EFFECT)
		end
	end
end
