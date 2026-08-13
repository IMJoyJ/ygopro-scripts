--火車
-- 效果：
-- 这张卡不能通常召唤。自己场上的不死族怪兽是2只以上的场合才能特殊召唤。
-- ①：这张卡特殊召唤成功的场合发动。这张卡以外的场上的怪兽全部回到持有者卡组。原本种族是不死族的表侧表示怪兽回到卡组的场合，这张卡的攻击力变成那些怪兽数量×1000。
function c52512994.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。自己场上的不死族怪兽是2只以上的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件设为永远 false，使这张卡无法被其他效果特殊召唤，只能依靠后续 EFFECT_SPSUMMON_PROC 的特殊召唤手续。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 自己场上的不死族怪兽是2只以上的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c52512994.spcon)
	c:RegisterEffect(e2)
	-- ①：这张卡特殊召唤成功的场合发动。这张卡以外的场上的怪兽全部回到持有者卡组。原本种族是不死族的表侧表示怪兽回到卡组的场合，这张卡的攻击力变成那些怪兽数量×1000。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(52512994,0))  --"返回卡组"
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(c52512994.tdtg)
	e3:SetOperation(c52512994.tdop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断怪兽是否为表侧表示且当前种族为不死族。
function c52512994.spfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE)
end
-- 特殊召唤手续的条件：c 为 nil 时返回 true 表示该手续可被查询；否则要求控制者有空格，且其场上有至少2只表侧不死族怪兽。
function c52512994.spcon(e,c)
	if c==nil then return true end
	-- 检查控制者场上是否存在可用的主要怪兽区空格。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查控制者自己场上是否存在至少2只满足 spfilter（表侧不死族）的怪兽。
		and Duel.IsExistingMatchingCard(c52512994.spfilter,c:GetControler(),LOCATION_MZONE,0,2,nil)
end
-- 必发诱发效果的发动条件确认：特殊召唤成功即可发动，并将场上可回卡组的怪兽登记为效果对象信息。
function c52512994.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 取得双方场上除这张卡自身以外所有能返回卡组的怪兽，作为本次效果涉及的对象组。
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	-- 登记操作信息：将对象组 g 中全部卡作为 CATEGORY_TODECK 返回卡组处理。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 过滤在弹回操作后位于卡组或额外卡组、原本种族为不死族、且移动前是表侧表示的怪兽。
function c52512994.rfilter(c)
	return c:IsLocation(LOCATION_DECK+LOCATION_EXTRA) and c:IsRace(RACE_ZOMBIE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 效果处理：把场上除自身外可回卡组的怪兽全部送回持有者卡组并洗牌，统计实际弹回的不死族表侧怪兽数 rt；若 rt>0 且这张卡仍在场并关联，则将攻击力变为 rt×1000。
function c52512994.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时重新获取场上除自身以外所有可回卡组的怪兽（以实际处理时为准）。
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	-- 将这些怪兽以效果原因送回各持有者卡组，并执行洗牌。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 统计本次实际操作中满足 rfilter 的怪兽数量，即原本不死族且表侧表示的弹回卡组怪兽数。
	local rt=Duel.GetOperatedGroup():FilterCount(c52512994.rfilter,nil)
	if rt>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 原本种族是不死族的表侧表示怪兽回到卡组的场合，这张卡的攻击力变成那些怪兽数量×1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(rt*1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
