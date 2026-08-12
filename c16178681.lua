--オッドアイズ・ペンデュラム・ドラゴン
-- 效果：
-- ←4 【灵摆】 4→
-- 这个卡名的①②的灵摆效果1回合各能使用1次。
-- ①：可以把自己的灵摆怪兽的战斗发生的对自己的战斗伤害变成0。
-- ②：自己结束阶段才能发动。这张卡破坏，从卡组把1只攻击力1500以下的灵摆怪兽加入手卡。
-- 【怪兽效果】
-- ①：这张卡用和对方怪兽的战斗给与对方的战斗伤害变成2倍。
function c16178681.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：可以把自己的灵摆怪兽的战斗发生的对自己的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16178681,0))  --"伤害变化"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(c16178681.rdcon)
	e2:SetOperation(c16178681.rdop)
	c:RegisterEffect(e2)
	-- ②：自己结束阶段才能发动。这张卡破坏，从卡组把1只攻击力1500以下的灵摆怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(16178681,1))  --"卡组检索"
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1,16178682)
	e3:SetCondition(c16178681.thcon)
	e3:SetTarget(c16178681.thtg)
	e3:SetOperation(c16178681.thop)
	c:RegisterEffect(e3)
	-- ①：这张卡用和对方怪兽的战斗给与对方的战斗伤害变成2倍。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e4:SetCondition(c16178681.damcon)
	-- 设置战斗伤害变为2倍
	e4:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e4)
end
-- 判断是否满足灵摆伤害变化效果的触发条件：伤害来源为己方，攻击怪兽为灵摆怪兽，且本回合未使用过该效果
function c16178681.rdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击的怪兽
	local tc=Duel.GetAttacker()
	-- 若攻击怪兽不是自己，则获取攻击目标怪兽
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	-- 返回是否满足灵摆伤害变化效果的触发条件
	return ep==tp and tc and tc:IsType(TYPE_PENDULUM) and Duel.GetFlagEffect(tp,16178681)==0
end
-- 处理灵摆伤害变化效果的发动：询问玩家是否将战斗伤害变为0，并执行相应操作
function c16178681.rdop(e,tp,eg,ep,ev,re,r,rp)
	-- 询问玩家是否将战斗伤害变为0
	if Duel.SelectYesNo(tp,aux.Stringid(16178681,2)) then  --"是否要把战斗伤害变成0？"
		-- 提示卡片发动动画
		Duel.Hint(HINT_CARD,0,16178681)
		-- 将玩家受到的战斗伤害设置为0
		Duel.ChangeBattleDamage(tp,0)
		-- 注册本回合已使用过该灵摆效果的标识
		Duel.RegisterFlagEffect(tp,16178681,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 判断是否满足灵摆卡检索效果的触发条件：当前为己方回合
function c16178681.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前是否为己方回合
	return Duel.GetTurnPlayer()==tp
end
-- 定义检索卡组中满足条件的灵摆怪兽的过滤函数
function c16178681.filter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsAttackBelow(1500) and c:IsAbleToHand()
end
-- 设置检索效果的目标信息：需要破坏自身并从卡组检索灵摆怪兽
function c16178681.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable()
		-- 检查卡组中是否存在满足条件的灵摆怪兽
		and Duel.IsExistingMatchingCard(c16178681.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将自身送去破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置操作信息：从卡组检索1张灵摆怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理灵摆卡检索效果的发动：破坏自身并从卡组检索符合条件的灵摆怪兽加入手牌
function c16178681.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否还在场上且能被破坏
	if not c:IsRelateToEffect(e) or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c16178681.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的灵摆怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断是否满足怪兽效果的触发条件：当前有战斗目标
function c16178681.damcon(e)
	return e:GetHandler():GetBattleTarget()~=nil
end
