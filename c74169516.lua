--千年の宝を守りしゴーレム
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合才能发动。这张卡当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
-- ②：这张卡是当作永续魔法卡使用的场合，支付2000基本分或把手卡1张「千年十字」给对方观看才能发动。这张卡特殊召唤。那之后，可以从卡组把1张「石版神殿」加入手卡。
-- ③：只要这张卡在怪兽区域存在，自己的「千年十字」的发动不会被无效化。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①②③效果的注册
function s.initial_effect(c)
	-- 记录这张卡上记载了「千年十字」和「石版神殿」的卡名
	aux.AddCodeList(c,37613663,63017368)
	-- ①：这张卡在手卡存在的场合才能发动。这张卡当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"当作魔法卡放置"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡是当作永续魔法卡使用的场合，支付2000基本分或把手卡1张「千年十字」给对方观看才能发动。这张卡特殊召唤。那之后，可以从卡组把1张「石版神殿」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：只要这张卡在怪兽区域存在，自己的「千年十字」的发动不会被无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_INACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
end
-- 效果①的发动准备函数，检查魔法与陷阱区域是否有空位
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的魔法与陷阱区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
-- 效果①的处理函数，将此卡移动到魔法与陷阱区域并作为永续魔法卡使用
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 尝试将此卡表侧表示移动到自己的魔法与陷阱区域
	if Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		-- 这张卡当作永续魔法卡使用
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
	end
end
-- 效果②的发动条件：此卡当前作为永续魔法卡使用
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetType()==TYPE_SPELL+TYPE_CONTINUOUS
end
-- 过滤条件：手卡中未给对方观看的「千年十字」
function s.cfilter1(c,tp)
	return c:IsCode(37613663) and not c:IsPublic()
end
-- 效果②的Cost处理函数，处理支付2000基本分或展示手卡「千年十字」
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以给对方观看的「千年十字」
	local b1=Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_HAND,0,1,nil)
	-- 检查玩家是否能支付2000基本分
	local b2=Duel.CheckLPCost(tp,2000)
	if chk==0 then return b1 or b2 end
	-- 如果两个条件都满足，让玩家选择是否通过展示「千年十字」来作为Cost
	if b1 and b2 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否出示「千年十字」？"
		-- 提示玩家选择要给对方确认的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 让玩家从手卡选择1张「千年十字」
		local g=Duel.SelectMatchingCard(tp,s.cfilter1,tp,LOCATION_HAND,0,1,1,nil)
		-- 给对方玩家确认选择的卡片
		Duel.ConfirmCards(1-tp,g)
		-- 洗切玩家的手卡
		Duel.ShuffleHand(tp)
	elseif b2 then
		-- 扣除玩家2000基本分作为发动代价
		Duel.PayLPCost(tp,2000)
	else
		-- 提示玩家选择要给对方确认的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 让玩家从手卡选择1张「千年十字」
		local g=Duel.SelectMatchingCard(tp,s.cfilter1,tp,LOCATION_HAND,0,1,1,nil)
		-- 给对方玩家确认选择的卡片
		Duel.ConfirmCards(1-tp,g)
		-- 洗切玩家的手卡
		Duel.ShuffleHand(tp)
	end
end
-- 效果②的靶向/发动准备函数，检查是否能特殊召唤此卡并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格，且此卡是否能作为怪兽特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1ae,TYPE_MONSTER+TYPE_EFFECT,2000,2200,6,RACE_ROCK,ATTRIBUTE_EARTH) end
	-- 设置连锁操作信息，表示此效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤条件：卡组中的「石版神殿」且能加入手卡
function s.filter(c)
	return c:IsCode(63017368) and c:IsAbleToHand()
end
-- 效果②的处理函数，特殊召唤此卡，并可选地从卡组将1张「石版神殿」加入手卡
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果此卡成功特殊召唤，且卡组有「石版神殿」，则询问玩家是否将其加入手卡
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否把「石版神殿」加入手卡？"
		-- 提示玩家选择要加入手牌的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组中选择1张「石版神殿」
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 中断当前效果，使后续的检索处理与特殊召唤不视为同时处理
			Duel.BreakEffect()
			-- 将选中的卡片加入手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手卡的卡片
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 效果③的过滤函数，判断当前连锁是否为自己发动的「千年十字」的卡片发动
function s.efilter(e,ct)
	local p=e:GetHandlerPlayer()
	-- 获取指定连锁序号的效果对象和发动玩家
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return p==tp and te:IsHasType(EFFECT_TYPE_ACTIVATE) and te:GetHandler():IsCode(37613663)
end
