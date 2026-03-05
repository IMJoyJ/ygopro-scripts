--竜魔道騎士ガイア
-- 效果：
-- 「暗黑骑士 盖亚」怪兽＋5星龙族怪兽
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡只要在怪兽区域存在，卡名当作「龙骑士 盖亚」使用。
-- ②：自己·对方的主要阶段，以这张卡以外的场上1张卡为对象才能发动。这张卡的攻击力下降2600，作为对象的卡破坏。
-- ③：这张卡战斗破坏对方怪兽时才能发动。这张卡的攻击力上升2600。
function c15989522.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用满足条件的「暗黑骑士 盖亚」怪兽和5星龙族怪兽作为融合素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xbd),c15989522.ffilter2,true)
	-- 使该卡在场上时卡号视为「龙骑士 盖亚」
	aux.EnableChangeCode(c,66889139)
	-- ②：自己·对方的主要阶段，以这张卡以外的场上1张卡为对象才能发动。这张卡的攻击力下降2600，作为对象的卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15989522,0))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,15989522)
	e2:SetCondition(c15989522.descon)
	e2:SetTarget(c15989522.destg)
	e2:SetOperation(c15989522.desop)
	c:RegisterEffect(e2)
	-- ③：这张卡战斗破坏对方怪兽时才能发动。这张卡的攻击力上升2600。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(15989522,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCountLimit(1,15989523)
	-- 设置效果发动条件为与对方怪兽战斗时
	e3:SetCondition(aux.bdocon)
	e3:SetOperation(c15989522.atkop)
	c:RegisterEffect(e3)
end
-- 过滤器函数，用于筛选5星且龙族的怪兽
function c15989522.ffilter2(c)
	return c:IsLevel(5) and c:IsRace(RACE_DRAGON)
end
-- 判断当前是否为自己的主要阶段1或主要阶段2
function c15989522.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为自己的主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 设置效果的发动条件和目标选择逻辑
function c15989522.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc~=c end
	-- 检查是否满足发动条件：自身攻击力不低于2600且场上存在目标卡片
	if chk==0 then return c:IsAttackAbove(2600) and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上一张目标卡片
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	-- 设置连锁操作信息，确定将要破坏的卡片数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 处理效果发动后的操作
function c15989522.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡片
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsAttackAbove(2600) then
		-- 使该卡的攻击力下降2600
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-2600)
		c:RegisterEffect(e1)
		if not c:IsHasEffect(EFFECT_REVERSE_UPDATE) and tc:IsRelateToEffect(e) then
			-- 破坏目标卡片
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
-- 处理效果发动后的操作
function c15989522.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 使该卡的攻击力上升2600
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(2600)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
