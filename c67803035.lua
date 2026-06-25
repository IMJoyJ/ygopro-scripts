--破械転生
local s,id,o=GetID()
-- 注册发动时从卡组检索破械魔法卡或双王之械、以及将墓地破械卡回收并破坏场上其他卡的两个效果
function s.initial_effect(c)
	-- 在系统卡片信息中注册本卡关联的卡片密码「双王之械」
	aux.AddCodeList(c,27412542)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把1张「破械转生」以外的「破械」魔法卡或「双王之械」加入手手卡
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以「破械转生」以外的自己墓地最多3张「破械」卡为对象才能发动。那些卡回到卡组。那之后，可以把最多有回去数量的自己场上的其他卡破坏
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 过滤条件：卡组中除此卡外，卡名为「双王之械」或属于「破械」字段的魔法卡，且可以加入手牌
function s.thfilter(c)
	return not c:IsCode(id) and (c:IsCode(27412542) or c:IsSetCard(0x130) and c:IsType(TYPE_SPELL)) and c:IsAbleToHand()
end
-- 效果①的Operation函数：在发动成功且卡组有符合条件的卡时，让玩家选择是否检索，若选择是，则选择1张并加入手牌
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有符合过滤条件的卡片组
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	-- 若存在可检索卡片，询问玩家是否要将其加入手牌
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		-- 提示玩家选择要加入手牌的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将所选的卡片加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 给对方玩家确认所加入手牌的卡片
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 过滤条件：除此卡外墓地中属于「破械」字段且可以回到卡组的卡
function s.tdfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x130) and c:IsAbleToDeck()
end
-- 效果②的Target函数：确认或选择墓地1到3张非本名的「破械」卡作为效果对象，并设置回到卡组的操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) and chkc~=e:GetHandler() end
	-- 检查墓地中是否存在至少1张满足过滤条件的「破械」卡且此卡没有在连锁中进行发动
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler())
		and not e:GetHandler():IsStatus(STATUS_CHAINING) end
	-- 提示玩家选择要回到卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择墓地中1到3张满足过滤条件的「破械」卡作为效果对象
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,3,e:GetHandler())
	-- 设置当前效果的操作信息为将选中的墓地卡片送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果②的Operation函数：将选中的对象卡片送回卡组并洗卡，随后玩家可选择破坏自己场上最多相当于送回数量的其他卡
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与当前连锁相关的对象卡片
	local g=Duel.GetTargetsRelateToChain()
	-- 若存在可处理的对象且成功将它们送回卡组并洗卡
	if g:GetCount()>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
		-- 计算实际成功送回卡组或额外卡组的卡片数量
		local ct=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
		-- 若送回数量大于0且自己场上存在除此卡外的其他卡片
		if ct>0 and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,0,1,aux.ExceptThisCard(e))
			-- 询问玩家是否要破坏自己场上的卡片
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			-- 中断当前效果处理，建立“那之后”的时点
			Duel.BreakEffect()
			-- 提示玩家选择要破坏的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 选择自己场上最多相当于送回卡组卡片数量的除此卡外的其他卡片
			local sg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,ct,aux.ExceptThisCard(e))
			-- 在场上亮出被选择的卡片以示确认
			Duel.HintSelection(sg)
			-- 将选中的卡片因效果破坏
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
