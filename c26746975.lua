--闇の守護神－ダーク・ガーディアン
-- 效果：
-- 这个卡名在规则上也当作「门之守护神」卡使用。这张卡不能通常召唤，用「暗元素」的效果以及以下方法才能特殊召唤。
-- ●可以让自己的手卡·场上（表侧表示）·墓地·除外状态的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」各1张回到卡组，从手卡·墓地特殊召唤。
-- ①：这张卡不会被战斗破坏。
-- ②：「暗元素」的效果特殊召唤的这张卡不受其他怪兽以及对方发动的魔法卡的效果影响。
local s,id,o=GetID()
-- 初始化效果注册：登记关联卡名、设定仅能通过规定手续特殊召唤、赋予战斗破坏耐性、并为「暗元素」特殊召唤后的免疫效果做准备。
function s.initial_effect(c)
	-- 将该卡效果文中提到的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」和「暗元素」的卡号登记到代码列表，以便识别相关卡名。
	aux.AddCodeList(c,25955164,62340868,98434877,53194323)
	c:EnableReviveLimit()
	-- 对应特殊召唤限制规则：这张卡不能通常召唤，用「暗元素」的效果以及以下方法才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件判定值固定为假，使这张卡不能通过其他卡的效果被特殊召唤（只能使用自身手续）。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 对应以下特殊召唤手续：可以让自己的手卡·场上（表侧表示）·墓地·除外状态的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」各1张回到卡组，从手卡·墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ①：这张卡不会被战斗破坏。
	local e12=Effect.CreateEffect(c)
	e12:SetType(EFFECT_TYPE_SINGLE)
	e12:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e12:SetValue(1)
	c:RegisterEffect(e12)
	-- ②：「暗元素」的效果特殊召唤的这张卡不受其他怪兽以及对方发动的魔法卡的效果影响。
	local e13=Effect.CreateEffect(c)
	e13:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e13:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e13:SetCode(EVENT_SPSUMMON_SUCCESS)
	e13:SetCondition(s.regcon)
	e13:SetOperation(s.regop)
	c:RegisterEffect(e13)
end
-- 筛选符合条件的素材：怪兽必须表侧表示、可作为返回卡组的代价，并且卡号是雷魔神-桑迦、风魔神-修迦、水魔神-斯迦之一。
function s.mfilter(c)
	return c:IsFaceupEx() and c:IsAbleToDeckAsCost() and c:IsCode(25955164,62340868,98434877)
end
-- 检查选中的3张素材是否满足：卡名种类有3种（即三种魔神各1），且这些卡离开后自己场上仍有可用的怪兽区。
function s.fselect(g,c,tp)
	-- 返回真当且仅当自己场上存在足够空格（计算选中的卡离开后）且选中的卡包含3种不同的卡号（雷/风/水魔神各1）。
	return Duel.GetMZoneCount(tp,g)>0 and g:GetClassCount(Card.GetCode)==3
end
-- 定义特殊召唤手续的发动条件：若c为空（规则询问）直接通过；否则在自己手牌、场上（表侧）、墓地、除外区中寻找三魔神，并确认能选出3张满足条件的素材。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取当前玩家（tp）手牌、场上（表侧）、墓地、除外区中满足s.mfilter条件的三魔神素材卡集合。
	local g=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_HAND+LOCATION_REMOVED,0,nil)
	return g:CheckSubGroup(s.fselect,3,3,c,tp)
end
-- 定义特殊召唤手续的选择目标阶段：提示玩家选择3张要返回卡组的素材，若选择成功则暂存这些卡并允许发动，否则不发动。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取当前玩家手牌、场上（表侧）、墓地、除外区中满足s.mfilter条件的三魔神素材卡集合。
	local g=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_HAND+LOCATION_REMOVED,0,nil)
	-- 弹出“请选择要返回卡组的卡”的选择提示消息，供玩家进行素材选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:SelectSubGroup(tp,s.fselect,true,3,3,c,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤手续：取回之前选择的素材，将它们返回卡组并洗牌（作为特殊召唤代价），然后完成特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的3张素材卡返回持有者卡组并洗牌，处理原因为代价（REASON_COST）。
	Duel.SendtoDeck(g,tp,SEQ_DECKSHUFFLE,REASON_COST)
	g:DeleteGroup()
end
-- 判断这次特殊召唤是否由「暗元素」的效果处理而来（效果来源卡为暗元素，卡号53194323），是则条件成立。
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsCode(53194323)
end
-- 特殊召唤成功时，若由「暗元素」效果特殊召唤，则为这张卡注册免疫效果。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ②：「暗元素」的效果特殊召唤的这张卡不受其他怪兽以及对方发动的魔法卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"「暗元素」的效果特殊召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efilter)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
-- 定义免疫效果的过滤条件：免疫其他怪兽的效果（效果来源不是这张卡自身）以及对方玩家发动的魔法卡的效果。
function s.efilter(e,te)
	return (te:IsActiveType(TYPE_MONSTER) and te:GetOwner()~=e:GetOwner()) or (te:GetOwnerPlayer()~=e:GetOwnerPlayer() and te:IsActivated()
		and te:IsActiveType(TYPE_SPELL))
end
