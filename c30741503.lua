--オルフェゴール・ガラテア
-- 效果：
-- 包含「自奏圣乐」怪兽的效果怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：连接状态的这张卡不会被战斗破坏。
-- ②：以自己的除外状态的1只机械族怪兽为对象才能发动。那只怪兽回到卡组。那之后，可以从卡组把1张「自奏圣乐」魔法·陷阱卡在自己场上盖放。
function c30741503.initial_effect(c)
	-- 添加连接召唤手续，要求使用2只满足效果怪兽类型的连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2,2,c30741503.lcheck)
	c:EnableReviveLimit()
	-- ①：连接状态的这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(c30741503.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：以自己的除外状态的1只机械族怪兽为对象才能发动。那只怪兽回到卡组。那之后，可以从卡组把1张「自奏圣乐」魔法·陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30741503,0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,30741503)
	e2:SetCondition(c30741503.tdcon1)
	e2:SetTarget(c30741503.tdtg)
	e2:SetOperation(c30741503.tdop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCondition(c30741503.tdcon2)
	c:RegisterEffect(e3)
end
-- 连接素材中必须包含1只以上「自奏圣乐」卡组的怪兽
function c30741503.lcheck(g)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x11b)
end
-- 当此卡处于连接状态时，效果才适用
function c30741503.indcon(e)
	return e:GetHandler():IsLinkState()
end
-- 判断当前是否不能将此效果变为诱发即时效果
function c30741503.tdcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 当前效果不能被转换为诱发即时效果
	return not aux.IsCanBeQuickEffect(e:GetHandler(),tp,90351981)
end
-- 判断当前是否可以将此效果变为诱发即时效果
function c30741503.tdcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 当前效果可以被转换为诱发即时效果
	return aux.IsCanBeQuickEffect(e:GetHandler(),tp,90351981)
end
-- 过滤满足条件的除外怪兽：必须是机械族且可以送回卡组
function c30741503.tdfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAbleToDeck()
end
-- 设置效果的发动条件和目标选择逻辑，确保能选择到符合条件的除外机械族怪兽
function c30741503.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c30741503.tdfilter(chkc) end
	-- 检查是否有满足条件的除外机械族怪兽
	if chk==0 then return Duel.IsExistingTarget(c30741503.tdfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要送回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c30741503.tdfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置连锁操作信息，标记将要送回卡组的怪兽
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 过滤满足条件的「自奏圣乐」魔法或陷阱卡，用于盖放
function c30741503.setfilter(c)
	return c:IsSetCard(0x11b) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 处理效果的发动和后续操作，包括将目标怪兽送回卡组并可能盖放魔法陷阱卡
function c30741503.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认目标怪兽有效且已成功送回卡组
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		-- 获取卡组中所有满足条件的「自奏圣乐」魔法或陷阱卡
		local g=Duel.GetMatchingGroup(c30741503.setfilter,tp,LOCATION_DECK,0,nil)
		-- 判断是否有满足条件的魔法陷阱卡且玩家选择盖放
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(30741503,1)) then  --"是否盖放魔法·陷阱卡？"
			-- 中断当前效果连锁，使后续处理视为错时点
			Duel.BreakEffect()
			-- 提示玩家选择要盖放的魔法或陷阱卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选中的魔法或陷阱卡在自己场上盖放
			Duel.SSet(tp,sg)
		end
	end
end
