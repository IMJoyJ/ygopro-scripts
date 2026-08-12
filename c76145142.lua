--オルフェゴール・ロンギルス
-- 效果：
-- 包含「自奏圣乐」怪兽的效果怪兽2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：连接状态的这张卡不会被效果破坏。
-- ②：以自己的除外状态的2只机械族怪兽为对象才能发动（这个效果发动的回合，这张卡不能攻击）。那些怪兽回到卡组。那之后，可以把1只连接状态的对方怪兽送去墓地。
function c76145142.initial_effect(c)
	-- 添加连接召唤手续：效果怪兽2只以上，且必须包含「自奏圣乐」怪兽
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2,99,c76145142.lcheck)
	c:EnableReviveLimit()
	-- ①：连接状态的这张卡不会被效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetCondition(c76145142.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：以自己的除外状态的2只机械族怪兽为对象才能发动（这个效果发动的回合，这张卡不能攻击）。那些怪兽回到卡组。那之后，可以把1只连接状态的对方怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(76145142,0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,76145142)
	e2:SetCondition(c76145142.tdcon1)
	e2:SetCost(c76145142.tdcost)
	e2:SetTarget(c76145142.tdtg)
	e2:SetOperation(c76145142.tdop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e3:SetCondition(c76145142.tdcon2)
	c:RegisterEffect(e3)
end
-- 连接素材检测：过滤出包含至少1只「自奏圣乐」怪兽的素材组
function c76145142.lcheck(g)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x11b)
end
-- 抗性效果的判定条件：自身处于连接状态
function c76145142.indcon(e)
	return e:GetHandler():IsLinkState()
end
-- 起动效果的发动条件：场上不存在「自奏圣乐的巴别塔」效果影响（不能作为即时效果发动）
function c76145142.tdcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否不满足将效果转变为诱发即时效果的条件（即不能在对方回合发动）
	return not aux.IsCanBeQuickEffect(e:GetHandler(),tp,90351981)
end
-- 诱发即时效果的发动条件：场上存在「自奏圣乐的巴别塔」效果影响（可以作为即时效果发动）
function c76145142.tdcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否满足将效果转变为诱发即时效果的条件（即可以在对方回合发动）
	return aux.IsCanBeQuickEffect(e:GetHandler(),tp,90351981)
end
-- 效果②的发动代价（Cost）处理：检查本回合是否未宣言攻击，并适用“这张卡不能攻击”的誓约效果
function c76145142.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- 这个效果发动的回合，这张卡不能攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 过滤条件：表侧表示的、可以回到卡组的机械族怪兽
function c76145142.tdfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAbleToDeck()
end
-- 效果②的发动准备（Target）：选择自己除外状态的2只机械族怪兽作为对象，并声明回卡组的操作信息
function c76145142.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c76145142.tdfilter(chkc) end
	-- 检查自己除外状态是否存在至少2只满足条件的机械族怪兽
	if chk==0 then return Duel.IsExistingTarget(c76145142.tdfilter,tp,LOCATION_REMOVED,0,2,nil) end
	-- 给玩家发送提示信息：请选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家选择2只除外状态的机械族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c76145142.tdfilter,tp,LOCATION_REMOVED,0,2,2,nil)
	-- 设置当前连锁的操作信息：将选中的2张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
-- 效果②的效果处理（Operation）：将对象怪兽送回卡组，之后可选择将对方场上1只连接状态的怪兽送去墓地
function c76145142.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 若对象卡片存在，则将其送回卡组并洗卡，确认卡片成功回到主卡组或额外卡组
	if tg:GetCount()>0 and Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then
		-- 获取对方场上所有处于连接状态的怪兽
		local g=Duel.GetMatchingGroup(Card.IsLinkState,tp,0,LOCATION_MZONE,nil)
		-- 若对方场上存在连接状态的怪兽，询问玩家是否选择将其送去墓地
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(76145142,1)) then  --"是否把对方怪兽送去墓地？"
			-- 中断当前效果处理，使后续的送去墓地处理与回卡组处理不视为同时进行（造成错时点）
			Duel.BreakEffect()
			-- 给玩家发送提示信息：请选择要送去墓地的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选中的对方怪兽送去墓地
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	end
end
