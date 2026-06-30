--破械転生
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 将「双极之破械神」的卡片密码加入关联卡片列表
	aux.AddCodeList(c,27412542)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「双极之破械神」或1张「破械转生」以外的「破械」魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：以自己墓地最多3张「破械」卡为对象才能发动。那些卡回到卡组。那之后，可以选最多有回到卡组数量的自己场上的卡破坏。
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
-- 过滤卡组中除自身以外的「双极之破械神」或「破械」魔法卡
function s.thfilter(c)
	return not c:IsCode(id) and (c:IsCode(27412542) or c:IsSetCard(0x130) and c:IsType(TYPE_SPELL)) and c:IsAbleToHand()
end
-- 卡片发动时的效果处理函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有符合条件的卡片
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	-- 若卡组存在符合条件的卡片，询问玩家是否将其加入手牌
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择的卡片加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 过滤自己墓地中除自身以外可以回到卡组的「破械」卡片
function s.tdfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x130) and c:IsAbleToDeck()
end
-- 效果②（回到卡组并破坏自己场上的卡）的发动检测与对象选择
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) and chkc~=e:GetHandler() end
	-- 在发动准备阶段，检测自己墓地是否存在可作为对象的「破械」卡，且该效果不在同一连锁中连续发动
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler())
		and not e:GetHandler():IsStatus(STATUS_CHAINING) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1到3张可作为对象的「破械」卡
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,3,e:GetHandler())
	-- 设置效果处理的操作信息为将选中的卡片送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果②（回到卡组并破坏自己场上的卡）的效果处理函数
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中仍与效果有关联且不受王家长眠之谷影响的对象卡片
	local g=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	-- 若存在有效的对象卡，则将其送回卡组并洗牌，若成功送回的数量不为0则继续处理
	if g:GetCount()>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
		-- 计算实际回到主卡组或额外卡组的卡片数量
		local ct=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
		-- 若成功回到卡组的卡片数量大于0，且自己场上存在除本卡以外的卡片
		if ct>0 and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,0,1,aux.ExceptThisCard(e))
			-- 询问玩家是否选择破坏自己场上的卡片
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			-- 中断当前效果，使后续的破坏处理不与回到卡组同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要破坏的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 选择最多有回到卡组数量的自己场上的卡片（排除自身）
			local sg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,ct,aux.ExceptThisCard(e))
			-- 为选中的破坏目标卡片显示被选择的动画
			Duel.HintSelection(sg)
			-- 破坏被选中的己方卡片
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
