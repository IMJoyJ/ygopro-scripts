--ブービーゲーム
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己要受到战斗伤害的伤害计算时才能发动。那次战斗发生的对自己的战斗伤害变成0。
-- ②：盖放的这张卡被对方的效果破坏送去墓地的场合，以「蠢贼游戏」以外的自己墓地最多2张通常陷阱卡为对象才能发动。那些卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
function c27923575.initial_effect(c)
	-- ①：自己要受到战斗伤害的伤害计算时才能发动。那次战斗发生的对自己的战斗伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27923575,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(c27923575.atcon)
	e1:SetOperation(c27923575.atop)
	c:RegisterEffect(e1)
	-- ②：盖放的这张卡被对方的效果破坏送去墓地的场合，以「蠢贼游戏」以外的自己墓地最多2张通常陷阱卡为对象才能发动。那些卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27923575,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,27923575)
	e2:SetCondition(c27923575.setcon)
	e2:SetTarget(c27923575.settg)
	e2:SetOperation(c27923575.setop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：自己在伤害计算时将要受到的战斗伤害大于0时才能发动。
function c27923575.atcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己即将受到的战斗伤害是否大于0。
	return Duel.GetBattleDamage(tp)>0
end
-- ①效果处理：给己方玩家赋予本次伤害步骤中防止战斗伤害的效果，使那次对自己的战斗伤害变成0。
function c27923575.atop(e,tp,eg,ep,ev,re,r,rp)
	-- ①：那次战斗发生的对自己的战斗伤害变成0。②：盖放的这张卡被对方的效果破坏送去墓地的场合，以「蠢贼游戏」以外的自己墓地最多2张通常陷阱卡为对象才能发动。那些卡在自己场上盖放。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 将免伤效果注册给玩家tp，在其持续期间内免疫对自己造成的战斗伤害。
	Duel.RegisterEffect(e1,tp)
end
-- ②效果的发动条件：这张卡原本控制者为自己，里侧表示在场上被对方效果破坏并送去墓地。
function c27923575.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,REASON_DESTROY+REASON_EFFECT)==REASON_DESTROY+REASON_EFFECT and rp==1-tp and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- 筛选对象：是陷阱卡、不是「蠢贼游戏」、且可以盖放到场上的卡（对应效果原文中的通常陷阱卡）。
function c27923575.setfilter(c)
	return c:GetType()==TYPE_TRAP and not c:IsCode(27923575) and c:IsSSetable()
end
-- ②效果的发动目标处理：从自己墓地选择1～最多2张满足条件的通常陷阱卡作为对象，数量不超过魔陷区可用的空格数。
function c27923575.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c27923575.setfilter(chkc) end
	-- 发动时检查自己墓地是否存在至少1张满足条件的通常陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(c27923575.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示选择提示，让玩家选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 计算可选择数量：取魔陷区空位数与效果上限2中的较小值，作为可选择的卡片张数。
	local ct=math.min((Duel.GetLocationCount(tp,LOCATION_SZONE)),2)
	-- 让玩家从自己墓地选择1～ct张满足条件的陷阱卡，并将这些卡设为效果对象。
	local g=Duel.SelectTarget(tp,c27923575.setfilter,tp,LOCATION_GRAVE,0,1,ct,nil)
end
-- ②效果处理：获取对象卡，若对象仍与效果相关且魔陷区有空位，则选择要放置的卡并盖放到场上，同时赋予这些卡在盖放回合也能发动效果的能力。
function c27923575.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中②效果选择的对象卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 获取自己场上魔陷区可用的空格数，用于判断能否盖放及可盖放数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if #tg==0 or ft<=0 then return end
	if #tg>ft then
		-- 提示玩家选择要放置到场上的卡（用于处理对象数超过魔陷区空位时的选择）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		tg=tg:Select(tp,1,ft,nil)
	end
	-- 将选中的对象卡以里侧表示盖放到自己场上。
	Duel.SSet(tp,tg)
	-- 遍历所有被盖放的卡，逐一为它们赋予“盖放回合也能发动”的效果。
	for tc in aux.Next(tg) do
		-- 这个效果盖放的卡在盖放的回合也能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(27923575,2))  --"适用「蠢贼游戏」的效果来发动"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
