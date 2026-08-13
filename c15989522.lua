--竜魔道騎士ガイア
-- 效果：
-- 「暗黑骑士 盖亚」怪兽＋5星龙族怪兽
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡只要在怪兽区域存在，卡名当作「龙骑士 盖亚」使用。
-- ②：自己·对方的主要阶段，以这张卡以外的场上1张卡为对象才能发动。这张卡的攻击力下降2600，作为对象的卡破坏。
-- ③：这张卡战斗破坏对方怪兽时才能发动。这张卡的攻击力上升2600。
function c15989522.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续，融合素材为「暗黑骑士 盖亚」怪兽1只和5星龙族怪兽1只。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xbd),c15989522.ffilter2,true)
	-- 使这张卡在怪兽区域存在期间卡名当作「龙骑士 盖亚」（卡号66889139）使用。
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
	-- 设置③效果的发动条件：这张卡与对方怪兽进行战斗并将其战斗破坏。
	e3:SetCondition(aux.bdocon)
	e3:SetOperation(c15989522.atkop)
	c:RegisterEffect(e3)
end
-- 定义融合素材的第二个过滤条件：等级5的龙族怪兽。
function c15989522.ffilter2(c)
	return c:IsLevel(5) and c:IsRace(RACE_DRAGON)
end
-- 定义②效果的发动条件函数：当前阶段为主要阶段1或主要阶段2，即自己或对方的主要阶段。
function c15989522.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1或主要阶段2，以满足“自己·对方的主要阶段”的发动时机。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 定义②效果的目标选择与发动判定：检查本卡攻击力是否不低于2600，从双方场上选择这张卡以外的1张卡作为对象，并设置破坏的操作信息。
function c15989522.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc~=c end
	-- 发动时点合法性检查：这张卡当前攻击力不低于2600，且场上存在这张卡以外的卡可以作为对象。
	if chk==0 then return c:IsAttackAbove(2600) and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 向操作玩家显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方场上选择这张卡以外的1张卡作为效果对象，并将其加入连锁对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	-- 设置本连锁后续将进行破坏1张卡的操作信息，供其他卡连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果解决处理：若这张卡仍在场上表侧表示且与效果关联、攻击力不低于2600，则使其攻击力下降2600；若本卡未受攻击力变化颠倒效果影响且对象卡仍与效果关联，则将对象卡破坏。
function c15989522.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取出②效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsAttackAbove(2600) then
		-- 这张卡的攻击力下降2600。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-2600)
		c:RegisterEffect(e1)
		if not c:IsHasEffect(EFFECT_REVERSE_UPDATE) and tc:IsRelateToEffect(e) then
			-- 以效果原因将对象卡破坏。
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
-- ③效果解决处理：若这张卡仍在场上表侧表示且与效果关联，则使其攻击力上升2600。
function c15989522.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升2600。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(2600)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
