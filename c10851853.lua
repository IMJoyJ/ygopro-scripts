--フラワーダイノ
-- 效果：
-- 这张卡不能通常召唤，用这张卡的效果才能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：自己把陷阱卡的效果发动的场合或者对方把魔法卡的效果发动的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡被送去墓地的场合，从除外的自己以及对方的魔法·陷阱卡之中以合计3张为对象才能发动。那些卡用喜欢的顺序回到持有者卡组下面。那之后，自己从卡组抽1张。
local s,id,o=GetID()
-- 初始化效果函数，启用复活限制并注册三个效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 效果①：这张卡不能通常召唤，用这张卡的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡无法被通常召唤，必须通过效果特殊召唤
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 效果②：自己把陷阱卡的效果发动的场合或者对方把魔法卡的效果发动的场合才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.condition1)
	e2:SetTarget(s.target1)
	e2:SetOperation(s.activate1)
	c:RegisterEffect(e2)
	-- 效果③：这张卡被送去墓地的场合，从除外的自己以及对方的魔法·陷阱卡之中以合计3张为对象才能发动。那些卡用喜欢的顺序回到持有者卡组下面。那之后，自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.target2)
	e3:SetOperation(s.activate2)
	c:RegisterEffect(e3)
end
-- 效果②的发动条件：自己把陷阱卡的效果发动的场合或者对方把魔法卡的效果发动的场合
function s.condition1(e,tp,eg,ep,ev,re,r,rp)
	return (rp==1-tp and re:IsActiveType(TYPE_SPELL)) or (rp==tp and re:IsActiveType(TYPE_TRAP))
end
-- 效果②的发动准备：检查是否满足特殊召唤条件
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false) end
	-- 设置特殊召唤的发动信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果②的发动处理：将卡特殊召唤
function s.activate1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡是否还在场上并执行特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)>0 then
		c:CompleteProcedure()
	end
end
-- 效果③的目标筛选函数：选择场上正面表示的魔法·陷阱卡
function s.filter2(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck()
end
-- 效果③的发动准备：检查是否有3张除外的魔法·陷阱卡可选且自己可以抽卡
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查是否有3张除外的魔法·陷阱卡可选
	if chk==0 then return Duel.IsExistingTarget(s.filter2,tp,LOCATION_REMOVED,LOCATION_REMOVED,3,nil)
		-- 检查自己是否可以抽卡
		and Duel.IsPlayerCanDraw(tp,1) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择3张除外的魔法·陷阱卡作为目标
	local g=Duel.SelectTarget(tp,s.filter2,tp,LOCATION_REMOVED,LOCATION_REMOVED,3,3,nil)
	-- 设置将目标卡返回卡组的发动信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	-- 设置自己抽卡的发动信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果③的发动处理：将卡返回卡组并抽卡
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选定的目标卡组并筛选出与当前效果相关的卡
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 判断是否有符合条件的卡返回卡组并执行返回操作
	if #tg>0 and aux.PlaceCardsOnDeckBottom(tp,tg)>0 then
		-- 中断当前效果处理，使后续效果视为错时处理
		Duel.BreakEffect()
		-- 执行抽卡效果
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
