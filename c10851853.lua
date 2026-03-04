--フラワーダイノ
-- 效果：
-- 这张卡不能通常召唤，用这张卡的效果才能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：自己把陷阱卡的效果发动的场合或者对方把魔法卡的效果发动的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡被送去墓地的场合，从除外的自己以及对方的魔法·陷阱卡之中以合计3张为对象才能发动。那些卡用喜欢的顺序回到持有者卡组下面。那之后，自己从卡组抽1张。
local s,id,o=GetID()
-- 初始化卡片效果函数
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：自己把陷阱卡的效果发动的场合或者对方把魔法卡的效果发动的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡不能通常召唤，只能通过效果特殊召唤
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合，从除外的自己以及对方的魔法·陷阱卡之中以合计3张为对象才能发动。那些卡用喜欢的顺序回到持有者卡组下面。那之后，自己从卡组抽1张。
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
	-- 检查是否满足效果①的发动条件
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
-- 设置效果①的目标选择函数
function s.condition1(e,tp,eg,ep,ev,re,r,rp)
	return (rp==1-tp and re:IsActiveType(TYPE_SPELL)) or (rp==tp and re:IsActiveType(TYPE_TRAP))
end
-- 检查效果①是否可以发动
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断场上是否有足够的特殊召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false) end
	-- 设置效果①的发动信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 设置效果①的发动处理函数
function s.activate1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 执行效果①的特殊召唤操作
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)>0 then
		c:CompleteProcedure()
	end
end
-- 定义效果②中用于筛选除外卡的函数
function s.filter2(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck()
end
-- 设置效果②的目标选择函数
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查效果②是否可以发动
	if chk==0 then return Duel.IsExistingTarget(s.filter2,tp,LOCATION_REMOVED,LOCATION_REMOVED,3,nil)
		-- 判断玩家是否可以抽卡
		and Duel.IsPlayerCanDraw(tp,1) end
	-- 提示玩家选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	-- 选择3张除外的魔法·陷阱卡
	local g=Duel.SelectTarget(tp,s.filter2,tp,LOCATION_REMOVED,LOCATION_REMOVED,3,3,nil)
	-- 设置效果②的发动信息（送回卡组）
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	-- 设置效果②的发动信息（抽卡）
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 设置效果②的发动处理函数
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②选择的目标卡
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 执行效果②的送回卡组和抽卡操作
	if #tg>0 and aux.PlaceCardsOnDeckBottom(tp,tg)>0 then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 执行抽卡操作
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
