--EMキングベアー
-- 效果：
-- ←7 【灵摆】 7→
-- ①：这张卡发动的回合的结束阶段才能发动。这张卡破坏，从自己的额外卡组的表侧表示的灵摆怪兽以及自己墓地的怪兽之中选1只7星以上的怪兽加入手卡。
-- 【怪兽效果】
-- ①：攻击表示的这张卡不会被魔法·陷阱卡的效果破坏。
-- ②：这张卡的攻击力在自己战斗阶段内上升自己场上的「娱乐伙伴」卡数量×100。
function c67808837.initial_effect(c)
	-- 为卡片注册灵摆怪兽属性，但不自动注册灵摆卡的发动效果（以便手动注册并添加Cost）
	aux.EnablePendulumAttribute(c,false)
	-- 这张卡发动的回合
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1160)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c67808837.reg)
	c:RegisterEffect(e1)
	-- ①：这张卡发动的回合的结束阶段才能发动。这张卡破坏，从自己的额外卡组的表侧表示的灵摆怪兽以及自己墓地的怪兽之中选1只7星以上的怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(67808837,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c67808837.thcon)
	e2:SetTarget(c67808837.thtg)
	e2:SetOperation(c67808837.thop)
	c:RegisterEffect(e2)
	-- ①：攻击表示的这张卡不会被魔法·陷阱卡的效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c67808837.indescon)
	e3:SetValue(c67808837.indesval)
	c:RegisterEffect(e3)
	-- ②：这张卡的攻击力在自己战斗阶段内上升自己场上的「娱乐伙伴」卡数量×100。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c67808837.atkcon)
	e4:SetValue(c67808837.atkval)
	c:RegisterEffect(e4)
end
-- 灵摆卡发动时的Cost函数，给自身注册一个表示“在本回合发动过”的Flag
function c67808837.reg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(67808837,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 灵摆效果发动条件：检查自身是否在本回合发动过（是否存在对应的Flag）
function c67808837.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(67808837)~=0
end
-- 过滤条件：自己墓地或额外卡组表侧表示的、可以加入手卡的7星以上怪兽（如果是额外卡组则必须是灵摆怪兽）
function c67808837.thfilter(c)
	return c:IsLevelAbove(7) and (c:IsLocation(LOCATION_GRAVE) or (c:IsFaceup() and c:IsType(TYPE_PENDULUM))) and c:IsAbleToHand()
end
-- 灵摆效果发动靶向：检查自身是否可破坏，且是否存在满足条件的回收对象
function c67808837.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable()
		-- 检查自己的额外卡组（表侧）或墓地是否存在至少1张满足过滤条件的卡
		and Duel.IsExistingMatchingCard(c67808837.thfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置操作信息：从额外卡组或墓地将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end
-- 灵摆效果处理：破坏自身，并从额外卡组（表侧）或墓地选择1只满足条件的怪兽加入手卡
function c67808837.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍存在于场上，并执行破坏，若破坏失败则不处理后续效果
	if not c:IsRelateToEffect(e) or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从额外卡组（表侧）或墓地选择1张满足条件的卡（受王家之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c67808837.thfilter),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果破坏抗性的适用条件：这张卡处于攻击表示
function c67808837.indescon(e)
	return e:GetHandler():IsAttackPos()
end
-- 效果破坏抗性的适用范围：不会被魔法·陷阱卡的效果破坏
function c67808837.indesval(e,re,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 攻击力上升效果的适用条件：在自己的战斗阶段内
function c67808837.atkcon(e)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	-- 获取当前的回合玩家
	local tp=Duel.GetTurnPlayer()
	return tp==e:GetHandler():GetControler() and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 过滤条件：自己场上表侧表示的「娱乐伙伴」卡
function c67808837.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9f)
end
-- 攻击力上升数值计算：自己场上的「娱乐伙伴」卡数量×100
function c67808837.atkval(e,c)
	-- 计算自己场上表侧表示的「娱乐伙伴」卡数量并乘以100
	return Duel.GetMatchingGroupCount(c67808837.atkfilter,c:GetControler(),LOCATION_ONFIELD,0,nil)*100
end
