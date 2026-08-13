--妖精伝姫－シンデレラ
-- 效果：
-- ①：只要这张卡在怪兽区域存在，双方不能把场上的其他怪兽作为魔法卡的效果的对象。
-- ②：1回合1次，从手卡丢弃1张魔法卡才能发动。把这张卡可以装备的1张装备魔法卡从自己的手卡·卡组·墓地装备。那张装备魔法卡在结束阶段回到手卡。
function c52022648.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，双方不能把场上的其他怪兽作为魔法卡的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c52022648.tglimit)
	e1:SetValue(c52022648.tgval)
	c:RegisterEffect(e1)
	-- ②：1回合1次，从手卡丢弃1张魔法卡才能发动。把这张卡可以装备的1张装备魔法卡从自己的手卡·卡组·墓地装备。那张装备魔法卡在结束阶段回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52022648,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c52022648.eqcost)
	e2:SetTarget(c52022648.eqtg)
	e2:SetOperation(c52022648.eqop)
	c:RegisterEffect(e2)
end
-- 限制效果的目标筛选：使辛德瑞拉自身以外的场上其他怪兽成为“不能成为效果对象”的适用对象。
function c52022648.tglimit(e,c)
	return c~=e:GetHandler()
end
-- 限制效果的适用条件：当试图将其作为对象的效果是魔法卡效果时返回真，使该限制只针对魔法卡效果生效。
function c52022648.tgval(e,re,rp)
	return re:IsActiveType(TYPE_SPELL)
end
-- 代价筛选：判断一张手卡能否作为代价丢弃——它必须是魔法卡、可以丢弃，并且己方手卡·卡组·墓地存在至少一张可装备给辛德瑞拉的装备魔法卡（且不是这张手卡）。
function c52022648.costfilter(c,ec,tp)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
		-- 确认存在至少一张可装备给辛德瑞拉的装备魔法卡（从己方手卡·卡组·墓地中检索，且排除待丢弃的这张卡），保证发动后确实有装备对象。
		and Duel.IsExistingMatchingCard(c52022648.eqfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,c,ec)
end
-- 发动代价函数：检测时确认手卡中有可丢弃的魔法卡；实际发动时从手卡选择1张满足条件的魔法卡丢弃作为代价。
function c52022648.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：确认手卡中至少存在1张可作为代价的魔法卡（且该卡满足后续可装备对象的条件），否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c52022648.costfilter,tp,LOCATION_HAND,0,1,nil,e:GetHandler(),tp) end
	-- 执行代价：从手卡选择1张符合条件的魔法卡丢弃，丢弃原因设为代价+丢弃。
	Duel.DiscardHand(tp,c52022648.costfilter,1,1,REASON_COST+REASON_DISCARD,nil,e:GetHandler(),tp)
end
-- 装备筛选：选择是装备魔法卡且能够装备给辛德瑞拉的卡（通过装备限制判定）。
function c52022648.eqfilter(c,ec)
	return c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(ec)
end
-- 效果发动条件：自己的魔法与陷阱区域存在至少1个空位，用于放置将要装备的装备魔法卡。
function c52022648.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动条件：己方的魔法与陷阱区域有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
-- 效果处理：若条件满足，从己方手卡·卡组·墓地选择1张可装备的装备魔法卡装备给辛德瑞拉；并为该装备卡注册在结束阶段回手的效果。
function c52022648.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理前安全检查：若魔陷区无空位、辛德瑞拉变成里侧表示或与发动效果失去关联，则中止效果处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 向玩家显示选择装备卡片的提示，提示内容为“请选择要装备的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从自己的手卡·卡组·墓地中选择1张不受王家长眠之谷影响且可装备给辛德瑞拉的装备魔法卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c52022648.eqfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,c)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的装备魔法卡装备给辛德瑞拉。
		Duel.Equip(tp,tc,c)
		-- 那张装备魔法卡在结束阶段回到手卡。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetRange(LOCATION_SZONE)
		e1:SetOperation(c52022648.thop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 结束阶段时的处理：将该装备卡送回其持有者的手卡。
function c52022648.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 将装备魔法卡以效果原因送回持有者的手卡。
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
end
