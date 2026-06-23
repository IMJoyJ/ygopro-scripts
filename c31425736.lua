--カプシー☆ヤミー
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：连接1怪兽或者2星同调怪兽在自己场上存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把「奶油蛋糕杯猫☆味美喵」以外的1张「味美喵」卡加入手卡。同调怪兽的效果特殊召唤的场合，作为代替让自己也能抽1张。
local s,id,o=GetID()
-- 初始化卡片效果，创建特殊召唤、检索和抽卡相关的多个效果
function s.initial_effect(c)
	-- ①：连接1怪兽或者2星同调怪兽在自己场上存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把「奶油蛋糕杯猫☆味美喵」以外的1张「味美喵」卡加入手卡。同调怪兽的效果特殊召唤的场合，作为代替让自己也能抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 记录该卡通过同调怪兽效果特殊召唤成功，以便后续检索效果中判断是否可以抽卡。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetOperation(s.checkop)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于判断场上是否存在满足条件的2星同调怪兽或连接1怪兽
function s.filter(c)
	return (c:IsLevel(2) and c:IsType(TYPE_SYNCHRO) or c:IsLink(1) and c:IsType(TYPE_LINK)) and c:IsFaceup()
end
-- 特殊召唤条件函数，判断是否满足特殊召唤的条件：场上存在2星同调怪兽或连接1怪兽，并且有空场
function s.spcon(e,c)
	if c==nil then return true end
	-- 判断当前玩家场上是否有空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 判断当前玩家场上是否存在满足条件的2星同调怪兽或连接1怪兽
		and Duel.IsExistingMatchingCard(s.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 检索过滤函数，用于筛选卡组中「味美喵」卡组中除自身外的卡
function s.thfilter(c)
	return c:IsSetCard(0x1ca) and not c:IsCode(id) and c:IsAbleToHand()
end
-- 检索效果的处理函数，判断是否可以发动检索效果
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在满足条件的「味美喵」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 判断该卡是否通过同调怪兽效果特殊召唤成功，从而可以抽卡
		or e:GetHandler():GetFlagEffect(id)>0 and Duel.IsPlayerCanDraw(tp,1) end
	if e:GetHandler():GetFlagEffect(id)>0 then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	-- 设置检索效果的操作信息，提示将从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的发动处理函数，根据条件选择是检索卡还是抽卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断卡组中是否存在满足条件的「味美喵」卡
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	-- 判断该卡是否通过同调怪兽效果特殊召唤成功，从而可以抽卡
	local b2=e:GetLabel()==1 and Duel.IsPlayerCanDraw(tp,1)
	-- 判断是否选择使用检索效果，若不选择则使用代替抽卡
	if b1 and (not b2 or not Duel.SelectYesNo(tp,aux.Stringid(id,2))) then  --"是否作为代替抽卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择满足条件的1张「味美喵」卡
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	elseif e:GetLabel()==1 then
		-- 让玩家抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 记录该卡通过同调怪兽效果特殊召唤成功，以便后续检索效果中判断是否可以抽卡
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if not re then return end
	if re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsType(TYPE_SYNCHRO) then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_TEMP_REMOVE,0,1)
	end
end
