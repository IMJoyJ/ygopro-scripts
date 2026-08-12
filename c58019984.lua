--新世壊成劫
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以有「维萨斯-斯塔弗罗斯特」的卡名记述的自己墓地1张魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。把速攻魔法·陷阱卡盖放的场合，那张卡在盖放的回合也能发动。
-- ②：把墓地的这张卡除外，以除「新世坏成劫」外的有「维萨斯-斯塔弗罗斯特」的卡名记述的自己墓地3张魔法·陷阱卡为对象才能发动。那些卡回到卡组。
local s,id,o=GetID()
-- 注册卡片效果：①效果（盖放墓地记述有「维萨斯-斯塔弗罗斯特」的魔陷）与②效果（墓地除外，将墓地3张记述有「维萨斯-斯塔弗罗斯特」的魔陷回到卡组）。
function s.initial_effect(c)
	-- 注册卡片记述的卡号：「维萨斯-斯塔弗罗斯特」（56099748）。
	aux.AddCodeList(c,56099748)
	-- ①：以有「维萨斯-斯塔弗罗斯特」的卡名记述的自己墓地1张魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。把速攻魔法·陷阱卡盖放的场合，那张卡在盖放的回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以除「新世坏成劫」外的有「维萨斯-斯塔弗罗斯特」的卡名记述的自己墓地3张魔法·陷阱卡为对象才能发动。那些卡回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	-- 将墓地的这张卡除外作为发动的代价。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己墓地中记述了「维萨斯-斯塔弗罗斯特」卡名且可以盖放的魔法·陷阱卡。
function s.filter(c,ft)
	-- 判定是否为有「维萨斯-斯塔弗罗斯特」卡名记述的魔法·陷阱卡。
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and aux.IsCodeListed(c,56099748)
		and c:IsSSetable(true) and (c:IsType(TYPE_FIELD) or ft>0)
end
-- ①效果的发动准备：检查魔法与陷阱区域空位，确认是否存在可盖放的目标，并选择该卡作为对象。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前玩家魔法与陷阱区域的可用空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ft=ft-1 end
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc,ft) end
	-- 检查自己墓地是否存在至少1张满足条件的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,ft) end
	-- 提示玩家选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择自己墓地1张满足条件的魔法·陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,ft)
	-- 设置效果处理信息：涉及卡片离开墓地。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- ①效果的处理：将作为对象的卡在自己场上盖放，并赋予速攻魔法·陷阱卡在盖放回合也能发动的效果。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的卡片。
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍存在于墓地，则将其在自己场上盖放。
	if tc:IsRelateToEffect(e) and Duel.SSet(tp,tc)>0 then
		if tc:IsType(TYPE_QUICKPLAY) then
			-- 把速攻魔法·陷阱卡盖放的场合，那张卡在盖放的回合也能发动。
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(58019984,2))  --"适用「新世坏成劫」的效果来发动"
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
		if tc:IsType(TYPE_TRAP) then
			-- 把速攻魔法·陷阱卡盖放的场合，那张卡在盖放的回合也能发动。
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(58019984,2))  --"适用「新世坏成劫」的效果来发动"
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
-- 过滤条件：除「新世坏成劫」外，有「维萨斯-斯塔弗罗斯特」卡名记述的自己墓地的魔法·陷阱卡，且能回到卡组。
function s.tdfilter(c)
	-- 判定是否为除「新世坏成劫」外的有「维萨斯-斯塔弗罗斯特」卡名记述的魔法·陷阱卡。
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and aux.IsCodeListed(c,56099748) and not c:IsCode(id)
		and c:IsAbleToDeck()
end
-- ②效果的发动准备：确认自己墓地是否存在3张满足条件的卡，并选择这3张卡作为对象。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	-- 检查自己墓地是否存在至少3张满足条件的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,3,nil) end
	-- 提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地3张满足条件的魔法·陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	-- 设置效果处理信息：将3张目标卡送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
end
-- ②效果的处理：将作为对象的3张卡回到卡组并洗牌。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取仍与当前连锁相关的对象卡片集合。
	local g=Duel.GetTargetsRelateToChain()
	if g:GetCount()>0 then
		-- 将目标卡片送回持有者卡组并洗牌。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
