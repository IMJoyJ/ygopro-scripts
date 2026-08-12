--人造人間－サイコ・エナジー・ショッカー
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「人造人-念力震慑者」使用。
-- ②：这张卡召唤·特殊召唤的场合才能发动。对方场上的陷阱卡全部破坏（里侧表示卡翻开确认）。那之后，这张卡的攻击力上升破坏数量×300。
-- ③：只要除这张卡外的有「时间黑魔术师」的卡名记述的怪兽在自己的场上或墓地存在，对方不能把陷阱卡的效果发动。
local s,id,o=GetID()
-- 初始化函数：注册①的卡名变更效果、②的召唤·特殊召唤时破坏对方陷阱并上升攻击力的诱发效果，以及③的让对方不能发动陷阱卡效果的永续效果
function s.initial_effect(c)
	-- ①效果：这张卡的卡名只要在怪兽区·墓地存在，就当作「人造人-念力震慑者」（卡号77585513）使用
	aux.EnableChangeCode(c,77585513,LOCATION_MZONE+LOCATION_GRAVE)
	-- 记录这张卡的效果文本上记载着「时间黑魔术师」（卡号40235813）的卡名，供「有……卡名记述」的判定使用
	aux.AddCodeList(c,40235813)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡召唤·特殊召唤的场合才能发动。对方场上的陷阱卡全部破坏（里侧表示卡翻开确认）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ③：只要除这张卡外的有「时间黑魔术师」的卡名记述的怪兽在自己的场上或墓地存在，对方不能把陷阱卡的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TRIGGER)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,0xff)
	e3:SetCondition(s.condition)
	e3:SetTarget(s.distg)
	c:RegisterEffect(e3)
end
-- 破坏对象过滤函数：匹配对方场上的陷阱卡，或对方魔陷区（非场地区域）的里侧表示卡（里侧卡需翻开确认是否为陷阱）
function s.desfilter(c)
	return c:IsType(TYPE_TRAP) or c:IsFacedown() and c:IsLocation(LOCATION_SZONE) and c:GetSequence()~=5
end
-- 表侧陷阱卡过滤函数：匹配表侧表示的陷阱卡
function s.qdesfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TRAP)
end
-- ②效果的目标函数：检查对方场上是否存在可破坏的陷阱卡或里侧魔陷卡，并把对方表侧陷阱卡组登记为破坏的操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：对方场上存在至少1张陷阱卡或魔陷区里侧表示卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有表侧表示的陷阱卡
	local sg=Duel.GetMatchingGroup(s.qdesfilter,tp,0,LOCATION_ONFIELD,nil)
	if sg:GetCount()>0 then
		-- 将这组表侧陷阱卡及其数量设置为破坏效果的操作信息，供星尘龙等卡的发动检测使用
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
	end
end
-- 里侧魔陷卡过滤函数：匹配对方魔陷区（非场地区域）的里侧表示卡
function s.cffilter(c)
	return c:IsFacedown() and c:IsLocation(LOCATION_SZONE) and c:GetSequence()~=5
end
-- ②效果的处理：翻开确认对方魔陷区的里侧表示卡，破坏对方场上全部陷阱卡，之后若这张卡仍在场上表侧存在则使其攻击力上升破坏数量×300
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方魔陷区所有里侧表示的卡
	local sg=Duel.GetMatchingGroup(s.cffilter,tp,0,LOCATION_ONFIELD,nil)
	-- 若存在里侧表示的魔陷卡，则给发动方玩家翻开确认这些卡
	if sg:GetCount()>0 then Duel.ConfirmCards(tp,sg) end
	-- 获取对方场上所有的陷阱卡（包括刚翻开确认后为陷阱的卡）
	local dg=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_TRAP)
	if dg:GetCount()>0 then
		-- 以效果破坏这组陷阱卡，并记录实际被破坏的数量
		local atk=Duel.Destroy(dg,REASON_EFFECT)
		if atk>0 and c:IsRelateToChain() and c:IsFaceup() then
			-- 中断当前效果处理，使之后的攻击力上升处理视为不同时处理（错开时点）
			Duel.BreakEffect()
			-- 那之后，这张卡的攻击力上升破坏数量×300。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(atk*300)
			c:RegisterEffect(e2)
		end
	end
end
-- 条件过滤函数：匹配在怪兽区表侧表示或墓地存在的、效果文本记载「时间黑魔术师」卡名的怪兽
function s.cfilter(c)
	-- 该怪兽为表侧存在（场上表侧或墓地），是怪兽卡，且效果文本上记载着「时间黑魔术师」（卡号40235813）的卡名
	return c:IsFaceupEx() and aux.IsCodeListed(c,40235813) and c:IsType(TYPE_MONSTER)
end
-- ③效果的适用条件：自己场上或墓地存在除这张卡以外的有「时间黑魔术师」卡名记述的怪兽
function s.condition(e)
	-- 检查自己怪兽区·墓地（排除这张卡本身）是否存在至少1张记载「时间黑魔术师」卡名的怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE+LOCATION_GRAVE,0,1,e:GetHandler())
end
-- 把效果的作用对象限定为陷阱卡，即对方不能把陷阱卡的效果发动
function s.distg(e,c)
	return c:IsType(TYPE_TRAP)
end
