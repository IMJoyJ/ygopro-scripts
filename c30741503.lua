--オルフェゴール・ガラテア
-- 效果：
-- 包含「自奏圣乐」怪兽的效果怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：连接状态的这张卡不会被战斗破坏。
-- ②：以自己的除外状态的1只机械族怪兽为对象才能发动。那只怪兽回到卡组。那之后，可以从卡组把1张「自奏圣乐」魔法·陷阱卡在自己场上盖放。
function c30741503.initial_effect(c)
	-- 为这张卡添加连接召唤手续：需要2只效果怪兽作为素材，且素材中必须包含至少1只「自奏圣乐」怪兽。
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
	-- 这个卡名的②的效果1回合只能使用1次。②：以自己的除外状态的1只机械族怪兽为对象才能发动。那只怪兽回到卡组。那之后，可以从卡组把1张「自奏圣乐」魔法·陷阱卡在自己场上盖放。
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
-- 检查连接素材怪兽组中是否存在至少1只「自奏圣乐」怪兽，以满足连接召唤条件。
function c30741503.lcheck(g)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x11b)
end
-- 判断这张卡是否处于连接状态，作为其不会被战斗破坏效果的适用条件。
function c30741503.indcon(e)
	return e:GetHandler():IsLinkState()
end
-- 判断当前情况下这张卡的②效果是否未被二速化，即只能作为起动效果在主要阶段发动。
function c30741503.tdcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前不能作为二速效果发动的判定结果，用于控制②效果只能作为起动效果使用。
	return not aux.IsCanBeQuickEffect(e:GetHandler(),tp,90351981)
end
-- 判断当前情况下这张卡的②效果是否已被二速化，可以作为诱发即时效果在对方回合发动。
function c30741503.tdcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前可以作为二速效果发动的判定结果，用于控制②效果可作为诱发即时效果使用。
	return aux.IsCanBeQuickEffect(e:GetHandler(),tp,90351981)
end
-- 筛选对象：除外状态、表侧表示、机械族、且可以返回卡组的怪兽。
function c30741503.tdfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAbleToDeck()
end
-- ②效果的发动处理：选择自己除外状态1只符合条件的机械族怪兽为对象，并登记回卡组的操作信息。
function c30741503.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c30741503.tdfilter(chkc) end
	-- 发动合法时检查：自己除外区是否存在至少1只符合条件的机械族怪兽。
	if chk==0 then return Duel.IsExistingTarget(c30741503.tdfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 向玩家显示选择对象的提示：请选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家选择自己除外区的1只符合条件的机械族怪兽，并将其作为效果对象。
	local g=Duel.SelectTarget(tp,c30741503.tdfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 登记包含将对象卡返回卡组的分类信息，供连锁判定等使用。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 筛选卡组中持有的「自奏圣乐」魔法·陷阱卡，且该卡可以盖放。
function c30741503.setfilter(c)
	return c:IsSetCard(0x11b) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 处理②效果：先将对象怪兽返回卡组洗牌，若成功则再选择卡组中1张「自奏圣乐」魔法·陷阱卡盖放到自己场上。
function c30741503.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时需要操作的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与效果关联，将其返回卡组洗牌；若成功且其位于卡组或额外卡组，则继续后续处理。
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		-- 从卡组筛选出所有符合条件的「自奏圣乐」魔法·陷阱卡。
		local g=Duel.GetMatchingGroup(c30741503.setfilter,tp,LOCATION_DECK,0,nil)
		-- 若存在可盖放的卡，则询问玩家是否要盖放；玩家选择‘是’才继续。
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(30741503,1)) then  --"是否盖放魔法·陷阱卡？"
			-- 中断当前效果处理，使‘回卡组’与‘盖放’视为不同时处理，避免错失时点。
			Duel.BreakEffect()
			-- 向玩家显示选择要盖放的卡的提示：请选择要盖放的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选中的卡盖放到自己场上。
			Duel.SSet(tp,sg)
		end
	end
end
