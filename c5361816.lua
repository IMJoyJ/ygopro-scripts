--聖騎士ペリノア
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：以这张卡装备的1张「圣剑」装备魔法卡和对方场上1只表侧表示怪兽为对象才能发动。那些卡破坏。那之后，自己从卡组抽1张。这个效果的发动后，直到回合结束时这张卡不能攻击。
function c5361816.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：以这张卡装备的1张「圣剑」装备魔法卡和对方场上1只表侧表示怪兽为对象才能发动。那些卡破坏。那之后，自己从卡组抽1张。这个效果的发动后，直到回合结束时这张卡不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5361816,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c5361816.destg)
	e1:SetOperation(c5361816.desop)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选出表侧表示且卡名属于「圣剑」字段、并且位于本卡装备区中的装备魔法卡，用于确定可作为对象的「圣剑」装备卡。
function c5361816.desfilter(c,g)
	return c:IsFaceup() and c:IsSetCard(0x207a) and g:IsContains(c)
end
-- 目标选择与发动合法性判定：先取得这张卡当前装备的卡组；若处于效果发动前的合法性检查，则确认自己能否抽1张卡，并检测场上是否存在符合条件的「圣剑」装备卡和对方表侧表示怪兽，以决定效果能否发动。
function c5361816.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=e:GetHandler():GetEquipGroup()
	if chkc then return false end
	-- 检查自己是否能够通过效果抽1张卡，作为发动条件之一。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查是否存在至少1张以这张卡装备的、表侧表示的「圣剑」装备魔法卡能够成为对象。
		and Duel.IsExistingTarget(c5361816.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,g)
		-- 检查对方场上是否存在至少1只表侧表示怪兽能够成为对象。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 给操作者显示“请选择要破坏的卡”的选择提示，用于后续选择装备魔法卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从自己或对方魔陷区选择1张符合条件的「圣剑」装备魔法卡作为效果对象，并自动与当前连锁建立联系。
	local g1=Duel.SelectTarget(tp,c5361816.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,g)
	-- 给操作者显示“请选择要破坏的卡”的选择提示，用于后续选择对方怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1只表侧表示怪兽作为效果对象，并自动与当前连锁建立联系。
	local g2=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	-- 将两个对象合并后写入操作信息，声明本次连锁确定会破坏这2张卡，以便相关效果进行检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
	-- 写入操作信息，声明本次连锁后续会让自己抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：取回发动时选择且仍与效果关联的对象卡，若破坏成功则抽1张；随后若这张卡仍在场上，则给它附加直到回合结束不能攻击的效果。
function c5361816.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡组，并过滤出仍然与效果e存在关联的对象（即没有因离场等原因失去联系的卡）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 若存在可破坏的关联对象且实际破坏成功，则进入后续抽卡处理。
	if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 中断当前效果处理流程，使后续抽卡视为另一次效果处理，避免错过时点。
		Duel.BreakEffect()
		-- 自己从卡组抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 这个效果的发动后，直到回合结束时这张卡不能攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
