--闇の守護神－ダーク・ガーディアン
-- 效果：
-- 这个卡名在规则上也当作「门之守护神」卡使用。这张卡不能通常召唤，用「暗元素」的效果以及以下方法才能特殊召唤。
-- ●可以让自己的手卡·场上（表侧表示）·墓地·除外状态的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」各1张回到卡组，从手卡·墓地特殊召唤。
-- ①：这张卡不会被战斗破坏。
-- ②：「暗元素」的效果特殊召唤的这张卡不受其他怪兽以及对方发动的魔法卡的效果影响。
local s,id,o=GetID()
-- 初始化卡片效果，注册关联卡号并启用特殊召唤限制
function s.initial_effect(c)
	-- 记录该卡与「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」「暗元素」的关联
	aux.AddCodeList(c,25955164,62340868,98434877,53194323)
	c:EnableReviveLimit()
	-- 设置此卡不能通常召唤
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件设为无效（即不能通常召唤）
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 设置此卡可通过特定条件特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 此卡不会被战斗破坏
	local e12=Effect.CreateEffect(c)
	e12:SetType(EFFECT_TYPE_SINGLE)
	e12:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e12:SetValue(1)
	c:RegisterEffect(e12)
	-- 此卡特殊召唤成功时获得效果免疫
	local e13=Effect.CreateEffect(c)
	e13:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e13:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e13:SetCode(EVENT_SPSUMMON_SUCCESS)
	e13:SetCondition(s.regcon)
	e13:SetOperation(s.regop)
	c:RegisterEffect(e13)
end
-- 筛选场上/手牌/墓地/除外区的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」卡
function s.mfilter(c)
	return c:IsFaceupEx() and c:IsAbleToDeckAsCost() and c:IsCode(25955164,62340868,98434877)
end
-- 判断所选卡组是否满足条件：有足够怪兽区且包含三种不同卡名
function s.fselect(g,c,tp)
	-- 判断所选卡组是否满足条件：有足够怪兽区且包含三种不同卡名
	return Duel.GetMZoneCount(tp,g)>0 and g:GetClassCount(Card.GetCode)==3
end
-- 判断是否满足特殊召唤条件：是否有满足条件的3张卡
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上/手牌/墓地/除外区的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」卡
	local g=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_HAND+LOCATION_REMOVED,0,nil)
	return g:CheckSubGroup(s.fselect,3,3,c,tp)
end
-- 设置特殊召唤目标，选择3张符合条件的卡并标记
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取场上/手牌/墓地/除外区的「雷魔神-桑迦」「风魔神-修迦」「水魔神-斯迦」卡
	local g=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_HAND+LOCATION_REMOVED,0,nil)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:SelectSubGroup(tp,s.fselect,true,3,3,c,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤操作，将选中的卡送回卡组
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的卡送回卡组并洗牌
	Duel.SendtoDeck(g,tp,SEQ_DECKSHUFFLE,REASON_COST)
	g:DeleteGroup()
end
-- 判断是否为「暗元素」的效果特殊召唤
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsCode(53194323)
end
-- 设置效果免疫，使此卡不受其他怪兽及对方魔法卡效果影响
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 使此卡不受其他怪兽及对方魔法卡效果影响
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
-- 定义效果免疫的判断条件：非自己怪兽效果或对方发动的魔法卡效果
function s.efilter(e,te)
	return (te:IsActiveType(TYPE_MONSTER) and te:GetOwner()~=e:GetOwner()) or (te:GetOwnerPlayer()~=e:GetOwnerPlayer() and te:IsActivated()
		and te:IsActiveType(TYPE_SPELL))
end
