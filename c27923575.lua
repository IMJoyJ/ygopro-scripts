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
-- 判断是否满足①效果的发动条件，即自己在本次战斗中受到的伤害大于0。
function c27923575.atcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回玩家在本次战斗中受到的伤害是否大于0。
	return Duel.GetBattleDamage(tp)>0
end
-- 创建一个影响全场的永续效果，使玩家在本次战斗中不会受到战斗伤害。
function c27923575.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 将效果注册到玩家的全局环境，使其生效。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 判断盖放的此卡被对方效果破坏送去墓地时是否满足②效果的发动条件。
	Duel.RegisterEffect(e1,tp)
end
-- 筛选墓地中满足条件的通常陷阱卡（非蠢贼游戏且可盖放）。
function c27923575.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,REASON_DESTROY+REASON_EFFECT)==REASON_DESTROY+REASON_EFFECT and rp==1-tp and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- 设置选择目标时的筛选条件，即选择墓地中的通常陷阱卡。
function c27923575.setfilter(c)
	return c:GetType()==TYPE_TRAP and not c:IsCode(27923575) and c:IsSSetable()
end
-- 提示玩家选择要盖放的卡，并根据场上空位数量限制选择数量。
function c27923575.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c27923575.setfilter(chkc) end
	-- 检查是否有满足条件的卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c27923575.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送提示信息，提示选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 计算玩家场上可盖放陷阱卡的最大数量。
	local ct=math.min((Duel.GetLocationCount(tp,LOCATION_SZONE)),2)
	-- 根据计算出的数量选择目标卡。
	local g=Duel.SelectTarget(tp,c27923575.setfilter,tp,LOCATION_GRAVE,0,1,ct,nil)
end
-- 处理②效果的发动，将选中的卡盖放到场上。
function c27923575.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 获取玩家场上可用的陷阱卡区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if #tg==0 or ft<=0 then return end
	if #tg>ft then
		-- 向玩家发送提示信息，提示选择要放置到场上的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		tg=tg:Select(tp,1,ft,nil)
	end
	-- 将选中的卡盖放到场上。
	Duel.SSet(tp,tg)
	-- 遍历所有盖放的卡，为每张卡添加效果。
	for tc in aux.Next(tg) do
		-- 为盖放的卡添加效果，使其在盖放的回合也能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(27923575,2))  --"适用「蠢贼游戏」的效果来发动"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
