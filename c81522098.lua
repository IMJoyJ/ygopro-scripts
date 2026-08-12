--ミミグル・ドラゴン
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。这张卡从手卡往对方场上里侧守备表示特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「迷拟宝箱鬼」魔法·陷阱卡加入手卡。
-- ③：这张卡在主要阶段反转的场合发动。以下效果各适用。
-- ●「迷拟宝箱鬼」怪兽以外的自己场上的表侧表示怪兽全部破坏。
-- ●这张卡的控制权移给对方。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含反转效果、手卡特殊召唤效果、召唤·特殊召唤成功时检索魔法·陷阱卡的效果。
function s.initial_effect(c)
	-- ③：这张卡在主要阶段反转的场合发动。以下效果各适用。 ●「迷拟宝箱鬼」怪兽以外的自己场上的表侧表示怪兽全部破坏。 ●这张卡的控制权移给对方。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏并转移控制权"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	-- 设置效果发动条件为仅在主要阶段。
	e1:SetCondition(aux.MimighoulFlipCondition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。这张卡从手卡往对方场上里侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「迷拟宝箱鬼」魔法·陷阱卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 过滤出自己场上表侧表示且不属于「迷拟宝箱鬼」系列的怪兽。
function s.filter(c)
	return c:IsFaceup() and not c:IsSetCard(0x1b7)
end
-- 反转效果的发动准备函数，检查发动合法性并设置破坏和转移控制权的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取自己场上所有满足过滤条件的怪兽（即非「迷拟宝箱鬼」的表侧表示怪兽）。
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	-- 设置连锁处理中的操作信息，表示将要破坏这些怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置连锁处理中的操作信息，表示将要转移这张卡自身的控制权。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,e:GetHandler(),1,0,0)
end
-- 反转效果的执行函数，依次处理破坏非「迷拟宝箱鬼」怪兽和转移自身控制权的效果。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前自己场上所有非「迷拟宝箱鬼」的表侧表示怪兽。
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	-- 因效果破坏获取到的怪兽。
	Duel.Destroy(g,REASON_EFFECT)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 中断当前效果处理，使后续的控制权转移处理不与破坏同时发生。
		Duel.BreakEffect()
		-- 将这张卡的控制权移给对方。
		Duel.GetControl(c,1-tp)
	end
end
-- 手卡特殊召唤效果的发动准备函数，检查自身是否能往对方场上里侧守备表示特殊召唤并设置特殊召唤操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自身是否可以往对方场上里侧守备表示特殊召唤，且对方场上是否有可用的怪兽区域空格。
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,1-tp) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 end
	-- 设置连锁处理中的操作信息，表示将要特殊召唤这张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 手卡特殊召唤效果的执行函数，将自身特殊召唤到对方场上并让己方确认。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以里侧守备表示特殊召唤到对方场上，若成功则让发动效果的玩家确认这张卡。
		if Duel.SpecialSummon(c,0,tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)>0 then Duel.ConfirmCards(tp,c) end
	end
end
-- 过滤出卡组中属于「迷拟宝箱鬼」系列的魔法·陷阱卡，且该卡能加入手牌。
function s.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x1b7) and c:IsAbleToHand()
end
-- 检索效果的发动准备函数，检查卡组中是否存在可检索的卡并设置加入手牌操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「迷拟宝箱鬼」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理中的操作信息，表示将从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行函数，让玩家选择卡组中的「迷拟宝箱鬼」魔法·陷阱卡加入手牌并向对方展示。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足条件的「迷拟宝箱鬼」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片因效果加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
