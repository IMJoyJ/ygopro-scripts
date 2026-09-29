--天霆異解△ヨミ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。这张卡里侧除外，5星怪兽以外的自己的除外状态（里侧）的1张「异解△」卡加入手卡。
-- ②：这张卡召唤·特殊召唤的场合发动。从自己卡组上面把5张卡里侧除外。
-- ③：1回合1次，对方把怪兽的效果发动时才能发动。和那只怪兽相同属性的自己的除外状态（里侧）的1只「异解△」怪兽回到卡组，那个发动无效。
local s,id,o=GetID()
-- 初始化卡片效果：注册手卡展示自身里侧除外检索里侧除外的「异解△」卡、召·特召从卡组顶里侧除外5张卡、无效对方怪兽效果发动并让里侧除外怪兽回到卡组的效果
function s.initial_effect(c)
	-- ①：把手卡的这张卡给对方观看才能发动。这张卡里侧除外，5星怪兽以外的自己的除外状态（里侧）的1张「异解△」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合发动。从自己卡组上面把5张卡里侧除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：1回合1次，对方把怪兽的效果发动时才能发动。和那只怪兽相同属性的自己的除外状态（里侧）的1只「异解△」怪兽回到卡组，那个发动无效。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"发动无效"
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.negcon)
	e4:SetTarget(s.negtg)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)
end
-- 效果发动Cost：把手卡的这张卡给对方观看
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤除外状态（里侧）且等级非5星的可加入手卡的「异解△」卡
function s.thfilter(c)
	return c:IsFacedown() and c:IsSetCard(0x1ed) and not c:IsLevel(5) and c:IsAbleToHand()
end
-- 效果发动目标判定：检查除外区是否存在满足条件的卡且自身可以里侧除外
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查除外区是否存在满足条件的「异解△」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_REMOVED,0,1,nil)
		and c:IsAbleToRemove(tp,POS_FACEDOWN) end
	-- 设置操作信息：从除外区将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
-- 效果处理：自身里侧除外，将除外状态（里侧）的1张「异解△」卡加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身与连锁的联系并将自身里侧除外
	if c:IsRelateToChain() and Duel.Remove(c,POS_FACEDOWN,REASON_EFFECT)~=0 then
		if c:IsFacedown() and c:IsLocation(LOCATION_REMOVED) then
			c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"因「天霆异解△幽谜」①被里侧除外"
		end
		-- 提示选择要加入手卡的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从除外区选择1张满足条件的「异解△」卡
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡加入手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方展示加入手卡的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 效果发动目标判定：获取卡组顶5张卡并设置除外操作信息
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己卡组最上方的5张卡
	local dg=Duel.GetDecktopGroup(tp,5)
	if chk==0 then return true end
	-- 设置操作信息：将卡组顶的5张卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,dg,dg:GetCount(),0,0)
	-- 向对方提示发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果处理：从自己卡组上面把5张卡里侧除外并注册标记
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组最上方的5张卡
	local dg=Duel.GetDecktopGroup(tp,5)
	if dg and dg:GetCount()>0 then
		-- 使紧接着的除外操作不进行洗卡检测
		Duel.DisableShuffleCheck()
		-- 将卡组顶的卡里侧除外
		if Duel.Remove(dg,POS_FACEDOWN,REASON_EFFECT)~=0 then
			-- 遍历被除外的卡片并注册效果标记
			for tc in aux.Next(dg) do
				if tc:IsFacedown() and tc:IsLocation(LOCATION_REMOVED) then
					tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,4))  --"因「天霆异解△幽谜」②被里侧除外"
				end
			end
		end
	end
end
-- 效果发动条件：对方发动怪兽效果且自身未被战斗破坏
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为对方发动的怪兽效果且自身未被战斗破坏以及发动可被无效
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 过滤除外状态（里侧）且与发动怪兽相同属性的可回到卡组的「异解△」怪兽
function s.disfilter(c,att)
	return c:IsFacedown() and c:IsSetCard(0x1ed) and c:IsAttribute(att) and c:IsAbleToDeck()
end
-- 辅助函数：获取连锁中怪兽在场或触发时的属性
function s.getchainatt(c,ev)
	if c:IsRelateToChain(ev) then
		return c:GetAttribute()
	end
	-- 从连锁信息中获取触发效果时的属性
	return Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_ATTRIBUTE)
end
-- 效果发动目标判定：检查是否存在对应属性的卡并设置无效和回卡组操作信息
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local att=s.getchainatt(re:GetHandler(),ev)
	-- 检查除外区是否存在相同属性且能回到卡组的「异解△」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_REMOVED,0,1,nil,att) end
	-- 设置操作信息：使怪兽效果的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 设置操作信息：从除外区将1张卡回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_REMOVED)
	-- 向对方提示发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果处理：除外状态（里侧）的「异解△」怪兽回到卡组，那个发动无效
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	local att=s.getchainatt(rc,ev)
	-- 提示选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从除外区选择1只相同属性的「异解△」怪兽
	local g=Duel.SelectMatchingCard(tp,s.disfilter,tp,LOCATION_REMOVED,0,1,1,nil,att)
	if #g>0 then
		-- 为选中的卡显示对象标记
		Duel.HintSelection(g)
		-- 向对方确认选中的里侧卡片
		Duel.ConfirmCards(1-tp,g)
		-- 将选中的怪兽送回卡组洗切
		if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
			and g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then
			-- 使连锁的发动无效
			Duel.NegateActivation(ev)
		end
	end
end
