--ディフォーム
-- 效果：
-- 自己场上表侧表示存在的名字带有「变形斗士」的怪兽被选择作为攻击对象时才能发动。把1只攻击怪兽的攻击无效，被选择作为攻击对象的1只名字带有「变形斗士」的怪兽的表示形式改变。
function c92890308.initial_effect(c)
	-- 自己场上表侧表示存在的名字带有「变形斗士」的怪兽被选择作为攻击对象时才能发动。把1只攻击怪兽的攻击无效，被选择作为攻击对象的1只名字带有「变形斗士」的怪兽的表示形式改变。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(c92890308.condition)
	e1:SetTarget(c92890308.target)
	e1:SetOperation(c92890308.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：检查被攻击的怪兽是否为自己场上表侧表示的「变形斗士」怪兽
function c92890308.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的攻击目标怪兽
	local d=Duel.GetAttackTarget()
	return d:IsControler(tp) and d:IsFaceup() and d:IsSetCard(0x26)
end
-- 效果的发动准备：确认攻击怪兽和被攻击怪兽是否在场且能成为效果对象
function c92890308.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前的攻击怪兽
	local ta=Duel.GetAttacker()
	-- 获取当前的攻击目标怪兽
	local td=Duel.GetAttackTarget()
	if chkc then return chkc==ta end
	if chk==0 then return ta:IsOnField() and ta:IsCanBeEffectTarget(e)
		and td:IsOnField() and td:IsCanBeEffectTarget(e) end
	local g=Group.FromCards(ta,td)
	-- 将攻击怪兽和被攻击怪兽设为当前连锁的效果处理对象
	Duel.SetTargetCard(g)
	-- 设置操作信息，表明此效果包含改变1张卡表示形式的操作
	Duel.SetOperationInfo(0,CATEGORY_POSITION,td,1,0,0)
end
-- 效果处理：无效攻击并改变被攻击怪兽的表示形式
function c92890308.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的攻击怪兽
	local ta=Duel.GetAttacker()
	-- 获取当前的攻击目标怪兽
	local td=Duel.GetAttackTarget()
	-- 若攻击怪兽与效果有关联且成功无效其攻击，且被攻击怪兽仍表侧表示存在并与效果有关联
	if ta:IsRelateToEffect(e) and Duel.NegateAttack() and td:IsFaceup() and td:IsRelateToEffect(e) then
		-- 改变被攻击怪兽的表示形式（表侧攻击表示与表侧守备表示互相转换）
		Duel.ChangePosition(td,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end
