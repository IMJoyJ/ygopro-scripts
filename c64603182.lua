--古代の機械暗黒巨人
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「古代的机械巨人」使用。
-- ②：这张卡召唤·特殊召唤的场合才能发动。除「古代的机械暗黑巨人」外的「古代的机械」卡或「齿车街」合计最多2张从卡组加入手卡。那之后，选自己1张手卡丢弃。这个效果的发动后，直到回合结束时自己不能把卡盖放。
-- ③：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
function c64603182.initial_effect(c)
	-- 注册①效果的卡名变更：这张卡的卡名只要在怪兽区·墓地存在，就当作「古代的机械巨人」（卡号83104731）使用
	aux.EnableChangeCode(c,83104731,LOCATION_MZONE+LOCATION_GRAVE)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡召唤·特殊召唤的场合才能发动。除「古代的机械暗黑巨人」外的「古代的机械」卡或「齿车街」合计最多2张从卡组加入手卡。那之后，选自己1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64603182,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_HANDES_SELF)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,64603182)
	e1:SetTarget(c64603182.thtg)
	e1:SetOperation(c64603182.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ③：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(c64603182.aclimit)
	e3:SetCondition(c64603182.actcon)
	c:RegisterEffect(e3)
end
-- 检索用的过滤函数：目标卡不是「古代的机械暗黑巨人」，是「古代的机械」卡（系列0x7）或「齿车街」（卡号37694547），且可以加入手卡
function c64603182.thfilter(c)
	return not c:IsCode(64603182) and (c:IsSetCard(0x7) or c:IsCode(37694547)) and c:IsAbleToHand()
end
-- ②效果的目标设定函数：检查卡组是否存在至少1张可加入手卡的目标卡，并设置检索·加入手卡的操作信息
function c64603182.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认自己卡组存在至少1张满足条件的卡（除「古代的机械暗黑巨人」外的「古代的机械」卡或「齿车街」且可加入手卡）
	if chk==0 then return Duel.IsExistingMatchingCard(c64603182.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次连锁的操作信息：预告将以效果从卡组把1张卡加入手卡，具体卡在处理时确定，故目标为nil、数量为1、持有者为自己、位置为卡组
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理函数：从自己卡组选1～2张目标卡加入手卡并向对方展示确认，那之后选自己1张手卡丢弃，最后注册直到回合结束时自己不能把卡盖放的限制效果
function c64603182.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向自己发送选择提示消息：「请选择要加入手牌的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让自己从卡组选择1～2张满足条件的卡（除「古代的机械暗黑巨人」外的「古代的机械」卡或「齿车街」）作为加入手卡的对象
	local g=Duel.SelectMatchingCard(tp,c64603182.thfilter,tp,LOCATION_DECK,0,1,2,nil)
	if g:GetCount()>0 then
		-- 以效果原因把选择的卡从卡组加入持有者的手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认这些加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
		-- 中断当前效果处理，使之后丢弃手卡的处理与加入手卡视为不同时处理，避免错过时点
		Duel.BreakEffect()
		-- 向自己发送选择提示消息：「请选择要丢弃的手牌」
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		-- 让自己从手卡选择1张可以因效果丢弃的卡
		local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_EFFECT)
		-- 手动洗切自己的手卡，并重置洗卡检测状态
		Duel.ShuffleHand(tp)
		-- 以效果·丢弃的原因把选择的手卡送去墓地，即丢弃那1张手卡
		Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
	end
	-- 这个效果的发动后，直到回合结束时自己不能把卡盖放。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_MSET)
	e1:SetTargetRange(1,0)
	-- 把限制对象条件设为始终成立，即对自己的所有盖放行为生效
	e1:SetTarget(aux.TRUE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把「不能把怪兽盖放进行通常召唤」的限制效果作为玩家效果注册给自己，直到回合结束时有效
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SSET)
	-- 把克隆得到的「不能把魔法·陷阱卡盖放」的限制效果注册给自己，直到回合结束时有效
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_TURN_SET)
	-- 把克隆得到的「不能把场上的卡变成里侧表示」的限制效果注册给自己，直到回合结束时有效
	Duel.RegisterEffect(e3,tp)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e4:SetTarget(c64603182.sumlimit)
	-- 把克隆得到的「不能以里侧表示特殊召唤」的限制效果（适用sumlimit过滤）注册给自己，直到回合结束时有效
	Duel.RegisterEffect(e4,tp)
end
-- 特殊召唤表示形式的过滤函数：当特殊召唤的表示形式包含里侧表示时返回true，即禁止里侧表示的特殊召唤
function c64603182.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return bit.band(sumpos,POS_FACEDOWN)>0
end
-- 限制对象判断函数：当被判断的效果属于卡的发动（EFFECT_TYPE_ACTIVATE）时返回true，即禁止魔法·陷阱卡的发动
function c64603182.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- ③效果的生效条件函数：只有此次战斗的攻击怪兽是这张卡自身时，对方不能发动魔法·陷阱卡
function c64603182.actcon(e)
	-- 判断此次攻击的攻击怪兽是否为这张卡本身，是则限制效果生效
	return Duel.GetAttacker()==e:GetHandler()
end
