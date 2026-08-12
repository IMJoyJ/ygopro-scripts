--海瀧竜華－淵巴
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。从卡组把1张「登龙华海泷门」加入手卡。
-- ②：「海泷龙华-渊巴」以外的怪兽2只以上从手卡·卡组送去墓地的回合的自己主要阶段才能发动。这张卡从墓地特殊召唤。
-- ③：让自己场上1张表侧表示的「登龙华海泷门」回到卡组最下面才能发动。对方手卡全部除外，对方抽出那个数量。
local s,id,o=GetID()
-- 初始化卡片效果，注册三个起动效果并设置全局检查
function s.initial_effect(c)
	-- 记录该卡与「登龙华海泷门」的关联
	aux.AddCodeList(c,28669235)
	-- 效果①：把这张卡从手卡丢弃才能发动。从卡组把1张「登龙华海泷门」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 效果②：「海泷龙华-渊巴」以外的怪兽2只以上从手卡·卡组送去墓地的回合的自己主要阶段才能发动。这张卡从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"墓地特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 效果③：让自己场上1张表侧表示的「登龙华海泷门」回到卡组最下面才能发动。对方手卡全部除外，对方抽出那个数量。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"对方卡除外并抽卡"
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCost(s.drcost)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
	if not s.global_check then
		s.global_check=true
		-- 注册全局效果，用于检测怪兽进入墓地时的计数
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(s.checkop)
		-- 将全局效果注册到游戏环境
		Duel.RegisterEffect(ge1,0)
	end
end
-- 检查进入墓地的卡是否为怪兽且来自手牌或卡组
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 遍历进入墓地的卡组
	for tc in aux.Next(eg) do
		if tc:IsPreviousLocation(LOCATION_DECK+LOCATION_HAND) and not tc:IsCode(id)
			and tc:IsType(TYPE_MONSTER) then
			-- 为当前玩家注册标识效果
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
			-- 为对手玩家注册标识效果
			Duel.RegisterFlagEffect(1-tp,id,RESET_PHASE+PHASE_END,0,1)
		end
	end
end
-- 效果①的费用处理：丢弃自身到墓地
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将自身丢入墓地作为费用
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 检索过滤器：检索「登龙华海泷门」
function s.thfilter(c)
	return c:IsCode(28669235) and c:IsAbleToHand()
end
-- 效果①的发动条件判断：确认卡组是否存在「登龙华海泷门」
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断是否满足检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的发动处理：选择并检索「登龙华海泷门」
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「登龙华海泷门」
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到被加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动条件判断：确认己方是否已记录2次以上怪兽进入墓地
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足特殊召唤条件
	return Duel.GetFlagEffect(tp,id)>=2
end
-- 效果②的发动条件判断：确认场上是否有特殊召唤空间
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足特殊召唤条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的发动处理：将自身特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否满足特殊召唤条件
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 将自身特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 费用过滤器：选择场上表侧表示的「登龙华海泷门」
function s.costfilter(c)
	return c:IsFaceup() and c:IsCode(28669235) and c:IsAbleToDeckAsCost()
end
-- 效果③的费用处理：选择场上表侧表示的「登龙华海泷门」返回卡组
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否满足费用条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的「登龙华海泷门」
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 显示选卡动画
	Duel.HintSelection(g)
	-- 将选中的卡返回卡组最底端作为费用
	Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_COST)
end
-- 效果③的发动条件判断：确认对方手牌全部可以除外且能抽卡
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方手牌组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	local gc=g:GetCount()
	-- 判断是否满足除外并抽卡条件
	if chk==0 then return gc>0 and g:FilterCount(Card.IsAbleToRemove,nil)==gc and Duel.IsPlayerCanDraw(1-tp,gc) end
	-- 设置除外操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,gc,0,0)
	-- 设置抽卡操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,gc)
end
-- 效果③的发动处理：除外对方手牌并抽卡
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方手牌组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	local gc=g:GetCount()
	if gc>0 and g:FilterCount(Card.IsAbleToRemove,nil)==gc then
		-- 将对方手牌全部除外
		local oc=Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		if oc>0 then
			-- 让对方抽取除外卡的数量
			Duel.Draw(1-tp,oc,REASON_EFFECT)
		end
	end
end
