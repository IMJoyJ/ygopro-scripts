--捕食植物フライ・ヘル
-- 效果：
-- ①：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。给那只怪兽放置1个捕食指示物。有捕食指示物放置的2星以上的怪兽的等级变成1星。
-- ②：这张卡和持有这张卡的等级以下的等级的怪兽进行战斗的伤害步骤开始时才能发动。那只怪兽破坏。那之后，这张卡的等级上升破坏的那只怪兽的原本等级数值。
function c96622984.initial_effect(c)
	-- ①：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。给那只怪兽放置1个捕食指示物。有捕食指示物放置的2星以上的怪兽的等级变成1星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96622984,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c96622984.target)
	e1:SetOperation(c96622984.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡和持有这张卡的等级以下的等级的怪兽进行战斗的伤害步骤开始时才能发动。那只怪兽破坏。那之后，这张卡的等级上升破坏的那只怪兽的原本等级数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(96622984,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetTarget(c96622984.destg)
	e2:SetOperation(c96622984.desop)
	c:RegisterEffect(e2)
end
-- 效果①的对象选择与发动检测函数：选择对方场上1只可以放置捕食指示物的表侧表示怪兽。
function c96622984.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsCanAddCounter(0x1041,1) end
	-- 在发动时，检测对方场上是否存在可以放置捕食指示物的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x1041,1) end
	-- 向发动效果的玩家发送提示信息，要求选择表侧表示的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择对方场上1只可以放置捕食指示物的表侧表示怪兽作为效果对象。
	Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,1,nil,0x1041,1)
end
-- 效果①的效果处理函数：给对象怪兽放置1个捕食指示物，若其为2星以上则将其等级变为1星。
function c96622984.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的第一个效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:AddCounter(0x1041,1) and tc:IsLevelAbove(2) then
		-- 有捕食指示物放置的2星以上的怪兽的等级变成1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(c96622984.lvcon)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
-- 等级变更效果的适用条件：该怪兽身上放置有至少1个捕食指示物。
function c96622984.lvcon(e)
	return e:GetHandler():GetCounter(0x1041)>0
end
-- 效果②的发动检测与效果对象确认：在伤害步骤开始时，确认进行战斗的怪兽是否表侧表示且等级在这张卡以下。
function c96622984.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if chk==0 then return tc and tc:IsFaceup() and tc:IsLevelBelow(c:GetLevel()) end
	-- 设置当前连锁的操作信息，表明该效果将破坏1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- 效果②的效果处理函数：破坏进行战斗的怪兽，并使这张卡的等级上升该怪兽的原本等级数值。
function c96622984.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	-- 若进行战斗的怪兽仍处于战斗状态，则将其因效果破坏。
	if tc:IsRelateToBattle() and Duel.Destroy(tc,REASON_EFFECT)>0 then
		-- 中断当前效果处理，使后续的等级上升处理与破坏不视为同时发生。
		Duel.BreakEffect()
		-- 那之后，这张卡的等级上升破坏的那只怪兽的原本等级数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(tc:GetOriginalLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
