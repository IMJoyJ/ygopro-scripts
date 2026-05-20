--覇王白竜オッドアイズ・ウィング・ドラゴン
-- 效果：
-- ←10 【灵摆】 10→
-- ①：1回合1次，自己怪兽和对方怪兽进行战斗的伤害计算前才能发动。那只自己怪兽的攻击力直到那次伤害步骤结束时上升那只对方怪兽的攻击力数值。
-- 【怪兽效果】
-- 暗属性调整＋调整以外的「幻透翼」怪兽1只
-- 这个卡名的①②的怪兽效果1回合只能有1次使用其中任意1个。
-- ①：以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
-- ②：同调召唤的这张卡存在的场合，双方的战斗阶段才能发动。对方场上的5星以上的怪兽全部破坏。
-- ③：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
function c58074177.initial_effect(c)
	c:EnableReviveLimit()
	-- 启用灵摆怪兽属性，且不自动注册灵摆卡发动的效果
	aux.EnablePendulumAttribute(c,false)
	-- 设置同调召唤手续：暗属性调整＋调整以外的「幻透翼」怪兽1只
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),aux.NonTuner(Card.IsSetCard,0xff),1,1)
	-- ①：1回合1次，自己怪兽和对方怪兽进行战斗的伤害计算前才能发动。那只自己怪兽的攻击力直到那次伤害步骤结束时上升那只对方怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58074177,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_CONFIRM)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c58074177.atkcon)
	e1:SetOperation(c58074177.atkop)
	c:RegisterEffect(e1)
	-- ①：以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(58074177,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,58074177)
	e2:SetTarget(c58074177.distg)
	e2:SetOperation(c58074177.disop)
	c:RegisterEffect(e2)
	-- ②：同调召唤的这张卡存在的场合，双方的战斗阶段才能发动。对方场上的5星以上的怪兽全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(58074177,2))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,58074177)
	e3:SetCondition(c58074177.descon)
	e3:SetTarget(c58074177.destg)
	e3:SetOperation(c58074177.desop)
	c:RegisterEffect(e3)
	-- ③：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(58074177,3))
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCondition(c58074177.pencon)
	e6:SetTarget(c58074177.pentg)
	e6:SetOperation(c58074177.penop)
	c:RegisterEffect(e6)
end
-- 判定灵摆效果的发动条件：自己怪兽和对方怪兽进行战斗的伤害计算前
function c58074177.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击的怪兽
	local a=Duel.GetAttacker()
	local d=a:GetBattleTarget()
	if a:IsControler(1-tp) then a,d=d,a end
	return a and a:IsFaceup() and a:IsRelateToBattle()
		and d and d:IsFaceup() and d:IsRelateToBattle()
		and d:GetAttack()>0 and a:GetControler()~=d:GetControler()
end
-- 灵摆效果处理：使自己怪兽的攻击力直到伤害步骤结束时上升对方怪兽的攻击力数值
function c58074177.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击的怪兽
	local a=Duel.GetAttacker()
	local d=a:GetBattleTarget()
	if a:IsControler(1-tp) then a,d=d,a end
	if e:GetHandler():IsRelateToEffect(e)
		and a:IsFaceup() and a:IsRelateToBattle()
		and d:IsFaceup() and d:IsRelateToBattle() then
		-- 那只自己怪兽的攻击力直到那次伤害步骤结束时上升那只对方怪兽的攻击力数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(d:GetAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		a:RegisterEffect(e1)
	end
end
-- 怪兽效果①的发动准备：检查并选择对方场上1只表侧表示的效果怪兽作为对象
function c58074177.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查已选择的对象是否仍是对方场上未被无效的效果怪兽
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateEffectMonsterFilter(chkc) end
	-- 检查对方场上是否存在可以作为无效对象的效果怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息，要求选择要无效的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让玩家选择对方场上1只效果怪兽作为效果对象
	Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 怪兽效果①的效果处理：使作为对象的效果怪兽的效果直到回合结束时无效
function c58074177.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择为对象的效果怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使与该对象怪兽相关的连锁中已发动的效果无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 那只怪兽的效果直到回合结束时无效。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
-- 判定怪兽效果②的发动条件：同调召唤的这张卡存在，且处于双方的战斗阶段
function c58074177.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
		-- 判定当前是否处于战斗阶段
		and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
-- 过滤出场上表侧表示且等级在5星以上的怪兽
function c58074177.desfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(5)
end
-- 怪兽效果②的发动准备：检查并确定要破坏的对方场上5星以上的怪兽
function c58074177.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上所有表侧表示且等级在5星以上的怪兽
	local g=Duel.GetMatchingGroup(c58074177.desfilter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return g:GetCount()>0 end
	-- 设置效果处理信息：破坏对方场上所有符合条件的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 怪兽效果②的效果处理：破坏对方场上所有5星以上的怪兽
function c58074177.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次获取对方场上所有表侧表示且等级在5星以上的怪兽
	local g=Duel.GetMatchingGroup(c58074177.desfilter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 因效果破坏符合条件的怪兽组
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 判定怪兽效果③的发动条件：怪兽区域的这张卡被破坏且表侧表示存在
function c58074177.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 怪兽效果③的发动准备：检查自己的灵摆区域是否有空位
function c58074177.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的左或右灵摆区域是否可用
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 怪兽效果③的效果处理：将这张卡在自己的灵摆区域放置
function c58074177.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示移动到自己的灵摆区域
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
