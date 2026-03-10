--剣闘獣の闘技場－フラヴィス
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：丢弃1张手卡才能发动。从卡组把1只「剑斗兽」怪兽加入手卡。
-- ②：对方怪兽的攻击宣言时才能发动。从卡组把1只「剑斗兽」怪兽特殊召唤。这个效果特殊召唤的怪兽不会被战斗破坏。
-- ③：这个回合从自己卡组有「剑斗兽」怪兽特殊召唤的场合，结束阶段才能发动。从卡组把1张「剑斗」陷阱卡在自己场上盖放。
local s,id,o=GetID()
-- 初始化卡片效果，注册场地魔法卡的发动和三个效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：丢弃1张手卡才能发动。从卡组把1只「剑斗兽」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：对方怪兽的攻击宣言时才能发动。从卡组把1只「剑斗兽」怪兽特殊召唤。这个效果特殊召唤的怪兽不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"卡组特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- ③：这个回合从自己卡组有「剑斗兽」怪兽特殊召唤的场合，结束阶段才能发动。从卡组把1张「剑斗」陷阱卡在自己场上盖放。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"卡组盖放"
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCategory(CATEGORY_SSET)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCondition(s.setcon)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
	if not s.global_check then
		s.global_check=true
		-- 全局监听特殊召唤成功事件，用于记录是否在本回合从卡组特殊召唤过剑斗兽怪兽
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.chk)
		-- 注册全局效果，用于监听特殊召唤成功的事件
		Duel.RegisterEffect(ge1,0)
	end
end
-- 检查特殊召唤的怪兽是否为剑斗兽且来自卡组
function s.chkfilter(c,tp)
	return c:GetOwner()==tp and c:IsSummonLocation(LOCATION_DECK) and c:IsSetCard(0x1019)
end
-- 遍历所有特殊召唤成功的怪兽，若满足条件则为玩家注册标识效果
function s.chk(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		local tc=eg:GetFirst()
		while tc do
			if s.chkfilter(tc,p) then
				-- 为玩家注册一个在结束阶段重置的标识效果，表示本回合已从卡组特殊召唤过剑斗兽怪兽
				Duel.RegisterFlagEffect(p,id,RESET_PHASE+PHASE_END,0,1)
			end
			tc=eg:GetNext()
		end
	end
end
-- ①效果的费用处理函数，检查并丢弃一张手牌作为代价
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃手牌的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃手牌的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 检索过滤器，筛选剑斗兽怪兽
function s.thfilter(c)
	return c:IsSetCard(0x1019) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的目标设定函数，检查卡组是否存在符合条件的怪兽
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将要从卡组检索一张怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理函数，选择并把符合条件的怪兽加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到被送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的发动条件函数，判断是否为对方怪兽攻击宣言时
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击方不是自己
	return Duel.GetAttacker():GetControler()~=tp
end
-- 特殊召唤过滤器，筛选剑斗兽怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的目标设定函数，检查卡组是否存在符合条件的怪兽并判断是否有足够的召唤位置
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要从卡组特殊召唤一只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理函数，选择并特殊召唤符合条件的怪兽，并赋予其不会被战斗破坏的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足特殊召唤条件（场地魔法卡存在且有召唤位置）
	if not e:GetHandler():IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		-- 为特殊召唤的怪兽添加不会被战斗破坏的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		g:GetFirst():RegisterEffect(e1)
	end
end
-- ③效果的发动条件函数，判断本回合是否从卡组特殊召唤过剑斗兽怪兽
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断玩家是否拥有该标识效果
	return Duel.GetFlagEffect(tp,id)~=0
end
-- 盖放过滤器，筛选剑斗陷阱卡
function s.setfilter(c)
	return c:IsSetCard(0x19) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- ③效果的目标设定函数，检查卡组是否存在符合条件的陷阱卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足盖放条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ③效果的处理函数，选择并盖放符合条件的陷阱卡
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择满足条件的陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 执行盖放操作
		Duel.SSet(tp,g:GetFirst())
	end
end
