--守護者スフィンクス
-- 效果：
-- 这张卡1个回合可以有1次变回里侧守备表示。这张卡反转召唤成功时，对方场上的全部怪兽回到持有者手卡。
function c40659562.initial_effect(c)
	-- 这张卡1个回合可以有1次变回里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40659562,0))  --"变成里侧守备表示"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c40659562.target)
	e1:SetOperation(c40659562.operation)
	c:RegisterEffect(e1)
	-- 这张卡反转召唤成功时，对方场上的全部怪兽回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40659562,1))  --"对方场上的全部怪兽返回手牌"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e2:SetTarget(c40659562.thtg)
	e2:SetOperation(c40659562.thop)
	c:RegisterEffect(e2)
end
-- 起动效果的发动条件检测：检查这张卡当前能否变成里侧表示，且本回合尚未使用过该效果；若满足，则注册FlagEffect标记本回合已使用过此效果。
function c40659562.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(40659562)==0 end
	c:RegisterFlagEffect(40659562,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 向系统登记本次操作信息：将这张卡的表示形式变更归类为改变表示形式效果（CATEGORY_POSITION），并指定对象为这张卡。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 效果处理时的操作：若这张卡仍与效果相关且为表侧表示，则将其变成里侧守备表示。
function c40659562.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将这张卡的表示形式变更为里侧守备表示（POS_FACEDOWN_DEFENSE）。
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 反转召唤成功时的诱发效果发动检测：无特殊条件，恒可通过；随后获取对方场上所有能加入手卡的怪兽，并登记回手牌的操作信息。
function c40659562.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上（LOCATION_MZONE）全部满足“可以加入手卡”条件的怪兽，作为可能回手牌的对象。
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_MZONE,nil)
	-- 向系统登记本次效果处理会将上述怪兽送回手牌（CATEGORY_TOHAND），数量为获取到的怪兽数量。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 反转召唤成功时效果的实际处理：重新获取当前对方场上的全部可加入手卡的怪兽，并将它们全部送去持有者手卡。
function c40659562.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有可以加入手卡的怪兽，用于实际处理（避免使用发动时保存的旧对象，以场上现状为准）。
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_MZONE,nil)
	-- 将这些怪兽以效果原因（REASON_EFFECT）送回持有者的手卡。
	Duel.SendtoHand(g,nil,REASON_EFFECT)
end
