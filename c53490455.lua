--転生炎獣ラクーン
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己的「转生炎兽」怪兽被选择作为对方怪兽的攻击对象时，把这张卡从手卡送去墓地，以那2只进行战斗的怪兽为对象才能发动。自己基本分回复作为对象的对方怪兽的攻击力的数值。这个回合，作为对象的自己怪兽不会被战斗破坏。
-- ②：这张卡在墓地存在，自己的「转生炎兽」怪兽战斗破坏对方怪兽送去墓地时才能发动。这张卡加入手卡。
function c53490455.initial_effect(c)
	-- ①：自己的「转生炎兽」怪兽被选择作为对方怪兽的攻击对象时，把这张卡从手卡送去墓地，以那2只进行战斗的怪兽为对象才能发动。自己基本分回复作为对象的对方怪兽的攻击力的数值。这个回合，作为对象的自己怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53490455,0))
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c53490455.reccon)
	e1:SetCost(c53490455.reccost)
	e1:SetTarget(c53490455.rectg)
	e1:SetOperation(c53490455.recop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己的「转生炎兽」怪兽战斗破坏对方怪兽送去墓地时才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53490455,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,53490455)
	e2:SetCondition(c53490455.thcon)
	e2:SetTarget(c53490455.thtg)
	e2:SetOperation(c53490455.thop)
	c:RegisterEffect(e2)
end
-- 效果发动条件：攻击对象是自己的「转生炎兽」怪兽且处于表侧表示
function c53490455.reccon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前被选为攻击对象的怪兽
	local at=Duel.GetAttackTarget()
	return at:IsControler(tp) and at:IsFaceup() and at:IsSetCard(0x119)
end
-- 支付效果代价：将此卡送去墓地作为代价
function c53490455.reccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡从手牌送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 设置效果对象：攻击怪兽和被攻击怪兽
function c53490455.rectg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断攻击怪兽是否在场上且可成为效果对象
	if chk==0 then return Duel.GetAttacker():IsOnField() and Duel.GetAttacker():IsCanBeEffectTarget(e)
		-- 判断被攻击怪兽是否在场上且可成为效果对象
		and Duel.GetAttackTarget():IsOnField() and Duel.GetAttackTarget():IsCanBeEffectTarget(e) end
	-- 创建包含攻击怪兽和被攻击怪兽的卡片组
	local g=Group.FromCards(Duel.GetAttacker(),Duel.GetAttackTarget())
	-- 设置连锁处理的目标卡片为上述卡片组
	Duel.SetTargetCard(g)
	-- 记录攻击怪兽作为标签对象
	e:SetLabelObject(Duel.GetAttacker())
	-- 设置操作信息：回复LP
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,Duel.GetAttacker():GetAttack())
end
-- 效果处理函数：回复LP并使目标怪兽不会被战斗破坏
function c53490455.recop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local hc=e:GetLabelObject()
	-- 获取当前连锁的效果对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==hc then tc=g:GetNext() end
	if hc:IsFaceup() and hc:IsRelateToEffect(e) then
		-- 使玩家回复攻击怪兽的攻击力数值
		Duel.Recover(tp,hc:GetAttack(),REASON_EFFECT)
	end
	if tc:IsRelateToEffect(e) then
		-- 使目标怪兽在本回合内不会被战斗破坏
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 效果发动条件：己方「转生炎兽」怪兽战斗破坏对方怪兽送去墓地
function c53490455.thcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local bc=tc:GetBattleTarget()
	return eg:GetCount()==1	and tc:IsLocation(LOCATION_GRAVE) and tc:IsReason(REASON_BATTLE)
		and bc:IsRelateToBattle() and bc:IsControler(tp) and bc:IsSetCard(0x119)
end
-- 设置效果对象：此卡本身
function c53490455.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：将此卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理函数：将此卡加入手牌
function c53490455.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡从墓地送入手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
