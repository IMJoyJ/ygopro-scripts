--灰滅せし都の巫女
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：场地区域有「灰灭之都 奥布西地暮」存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把「灰灭都的巫女」以外的1张「灰灭」卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果：①手卡特殊召唤的自身召唤规程，②召唤·特殊召唤成功的场合检索「灰灭」卡的效果。
function s.initial_effect(c)
	-- 记录这张卡在卡组中记载了「灰灭之都 奥布西地暮」的卡名。
	aux.AddCodeList(c,3055018)
	-- ①：场地区域有「灰灭之都 奥布西地暮」存在的场合，这张卡可以从手卡特殊召唤。（这个卡名的①的方法的特殊召唤1回合只能有1次）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.sprcon)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把「灰灭都的巫女」以外的1张「灰灭」卡加入手卡。（②的效果1回合只能使用1次）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示存在的「灰灭之都 奥布西地暮」。
function s.sprfilter(c)
	return c:IsFaceup() and c:IsCode(3055018)
end
-- 自身特殊召唤规程的出现条件：自己场上有可用的怪兽区域，且场地区域存在「灰灭之都 奥布西地暮」。
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的主要怪兽区域。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查双方场地区域是否存在至少1张满足过滤条件（表侧表示的「灰灭之都 奥布西地暮」）的卡。
		and Duel.IsExistingMatchingCard(s.sprfilter,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 过滤条件：卡组中「灰灭都的巫女」以外的「灰灭」卡片，且可以加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x1ad) and not c:IsCode(id) and c:IsAbleToHand()
end
-- 检索效果的发动准备与合法性检查（Target阶段），设置操作信息为将卡组中的1张卡加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息：将卡组中的1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行处理（Operation阶段），从卡组选择1张「灰灭」卡加入手卡并给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入玩家手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
