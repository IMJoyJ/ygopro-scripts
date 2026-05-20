--ミミグル・フラワー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。这张卡从手卡往对方场上里侧守备表示特殊召唤。场上有里侧表示怪兽存在的场合，也能作为代替在自己场上表侧表示特殊召唤。
-- ②：这张卡在主要阶段反转的场合发动。以下效果各适用。
-- ●对方可以从自身卡组把1只反转怪兽或1张「迷拟宝箱鬼」卡加入手卡。
-- ●这张卡的控制权移给对方。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数。
function s.initial_effect(c)
	-- ②：这张卡在主要阶段反转的场合发动。以下效果各适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"反转效果"
	e1:SetCategory(CATEGORY_CONTROL+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	-- 设置效果发动条件为在主要阶段反转。
	e1:SetCondition(aux.MimighoulFlipCondition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。这张卡从手卡往对方场上里侧守备表示特殊召唤。场上有里侧表示怪兽存在的场合，也能作为代替在自己场上表侧表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 反转效果的发动准备与目标确认函数。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理的操作信息为转移这张卡的控制权。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,e:GetHandler(),1,0,0)
end
-- 过滤满足“反转怪兽”或“迷拟宝箱鬼”卡且能加入手牌的卡片。
function s.thfilter(c)
	return (c:IsSetCard(0x1b7) or c:IsType(TYPE_FLIP)) and c:IsAbleToHand()
end
-- 反转效果的实际处理函数，包含对方检索卡片和转移控制权。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方卡组中所有满足检索条件的卡片组。
	local g=Duel.GetMatchingGroup(s.thfilter,tp,0,LOCATION_DECK,nil)
	-- 如果对方卡组有符合条件的卡，则让对方选择是否将卡加入手牌。
	if g:GetCount()>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,4)) then  --"是否把卡加入手卡？"
		-- 给对方玩家发送选择加入手牌卡片的提示信息。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(1-tp,1,1,nil)
		-- 将对方选择的卡片加入对方手牌。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 让自身玩家确认对方加入手牌的卡。
		Duel.ConfirmCards(tp,sg)
	end
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 中断当前效果处理，使后续的控制权转移不与检索同时处理。
		Duel.BreakEffect()
		-- 将这张卡的控制权移给对方。
		Duel.GetControl(c,1-tp)
	end
end
-- 过滤自身场上特殊召唤的条件：场上有里侧表示怪兽存在，且此卡能以表侧表示特殊召唤。
function s.sspfilter(c,tp,e)
	-- 检查场上是否存在至少1只里侧表示的怪兽。
	return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 过滤对方场上特殊召唤的条件：此卡能以里侧守备表示特殊召唤到对方场上。
function s.ospfilter(c,tp,e)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,1-tp)
end
-- 特殊召唤效果的发动准备与目标确认函数。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足在自己场上表侧表示特殊召唤的条件及可用怪兽区域。
	if chk==0 then return s.sspfilter(c,tp,e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 或者检查是否满足在对方场上里侧守备表示特殊召唤的条件及可用怪兽区域。
		or s.ospfilter(c,tp,e) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 end
	-- 设置连锁处理的操作信息为特殊召唤这张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的实际处理函数。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() or (not s.sspfilter(c,tp,e) and not s.ospfilter(c,tp,e)) then return end
	-- 判断当前是否仍满足在自己场上表侧表示特殊召唤的条件。
	local b1=s.sspfilter(c,tp,e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- 判断当前是否仍满足在对方场上里侧守备表示特殊召唤的条件。
	local b2=s.ospfilter(c,tp,e) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
	-- 根据可行性，让发动效果的玩家选择特殊召唤的放置场地方。
	local toplayer=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,2),tp},  --"在自己场上特殊召唤"
		{b2,aux.Stringid(id,3),1-tp})  --"在对方场上特殊召唤"
	if toplayer==tp then
		-- 将这张卡在自己场上表侧表示特殊召唤。
		Duel.SpecialSummon(c,0,tp,toplayer,false,false,POS_FACEUP)
	elseif toplayer==1-tp then
		-- 将这张卡在对方场上里侧守备表示特殊召唤。
		Duel.SpecialSummon(c,0,tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 让自身玩家确认特殊召唤到对方场上的里侧表示的这张卡。
		Duel.ConfirmCards(tp,c)
	else
		-- 如果双方场上都没有可用的怪兽区域。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then
			-- 根据规则将这张卡送去墓地。
			Duel.SendtoGrave(c,REASON_RULE)
		end
	end
end
