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
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡在墓地存在，自己的「转生炎兽」怪兽战斗破坏对方怪兽送去墓地时才能发动。这张卡加入手卡。
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
-- ①效果的发动条件：被选择为攻击对象的我方怪兽必须表侧表示且属于「转生炎兽」系列。
function c53490455.reccon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前被选择为攻击对象的怪兽（攻击目标）。
	local at=Duel.GetAttackTarget()
	return at:IsControler(tp) and at:IsFaceup() and at:IsSetCard(0x119)
end
-- ①的发动代价：把手卡的这张卡送去墓地作为代价；检查时确认这张卡能否作为代价送去墓地。
function c53490455.reccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 把手卡的这张卡送去墓地，送去原因是作为发动代价（REASON_COST）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- ①的发动目标：以进行战斗的两只怪兽（攻击者和攻击对象）为对象，并确认它们都在场上且能成为效果对象；若指定对象不合法则不能发动。
function c53490455.rectg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动合法性检查：对方攻击者怪兽在场上且能成为效果对象。
	if chk==0 then return Duel.GetAttacker():IsOnField() and Duel.GetAttacker():IsCanBeEffectTarget(e)
		-- 发动合法性检查：作为攻击对象的我方怪兽在场上且能成为效果对象。
		and Duel.GetAttackTarget():IsOnField() and Duel.GetAttackTarget():IsCanBeEffectTarget(e) end
	-- 把攻击者和攻击对象组成一个卡组，作为本效果的对象。
	local g=Group.FromCards(Duel.GetAttacker(),Duel.GetAttackTarget())
	-- 将这两只怪兽设置为当前连锁效果的对象（取对象）。
	Duel.SetTargetCard(g)
	-- 将攻击者（对方怪兽）记录到效果的LabelObject中，便于处理时区分攻击者和攻击对象。
	e:SetLabelObject(Duel.GetAttacker())
	-- 设置操作信息：本效果涉及回复基本分，预计回复数值为攻击者（对方怪兽）的当前攻击力。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,Duel.GetAttacker():GetAttack())
end
-- ①的效果处理：回复对方怪兽攻击力数值的LP，并给作为对象的我方怪兽赋予本回合不会被战斗破坏的效果。
function c53490455.recop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local hc=e:GetLabelObject()
	-- 获取当前连锁处理的效果对象组（即之前选择的攻击者和攻击对象）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==hc then tc=g:GetNext() end
	if hc:IsFaceup() and hc:IsRelateToEffect(e) then
		-- 回复我方基本分，数值为攻击者（对方怪兽）的当前攻击力。
		Duel.Recover(tp,hc:GetAttack(),REASON_EFFECT)
	end
	if tc:IsRelateToEffect(e) then
		-- 这个回合，作为对象的自己怪兽不会被战斗破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- ②效果的发动条件：这张卡在墓地存在，自己的「转生炎兽」怪兽战斗破坏对方怪兽并将其送去墓地时；此处还确认被破坏的怪兽只有一只，且与它战斗的我方怪兽确实属于「转生炎兽」。
function c53490455.thcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local bc=tc:GetBattleTarget()
	return eg:GetCount()==1	and tc:IsLocation(LOCATION_GRAVE) and tc:IsReason(REASON_BATTLE)
		and bc:IsRelateToBattle() and bc:IsControler(tp) and bc:IsSetCard(0x119)
end
-- ②的发动目标：将墓地存在的这张卡加入手卡；检查这张卡能否加入手卡，能则登记操作信息。
function c53490455.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：本效果将把这张卡加入手卡1张。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②的效果处理：如果这张卡仍与效果相关（仍在墓地），将其加入持有者手卡。
function c53490455.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡加入其持有者的手卡，原因：效果。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
