--ワンモア・ザ・ワイト
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在墓地存在当作「白骨」使用。
-- ②：这张卡召唤·特殊召唤的场合才能发动。把「翌夜之白骨骑士」以外的1只「白骨」或者1张有那个卡名记述的卡从卡组加入手卡。这个回合，自己不是不死族怪兽不能特殊召唤。
-- ③：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只4星以下的不死族怪兽召唤。
local s,id,o=GetID()
-- 注册卡片效果，包括变更卡号、检索效果和额外召唤效果
function s.initial_effect(c)
	-- 使该卡在墓地时视为「白骨」卡
	aux.EnableChangeCode(c,32274490,LOCATION_GRAVE)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。把「翌夜之白骨骑士」以外的1只「白骨」或者1张有那个卡名记述的卡从卡组加入手卡。这个回合，自己不是不死族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ③：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只4星以下的不死族怪兽召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"使用「翌夜之白骨骑士」的效果召唤"
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e3:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e3:SetTarget(s.sumtg)
	c:RegisterEffect(e3)
end
-- 定义检索过滤器，用于筛选满足条件的卡
function s.thfilter(c)
	-- 筛选条件：不是自身卡号、是「白骨」卡或其记述卡、可以送入手牌
	return not c:IsCode(id) and aux.IsCodeOrListed(c,32274490) and c:IsAbleToHand()
end
-- 设置检索效果的处理目标
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果的操作
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
	-- 设置不能特殊召唤非不死族怪兽的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤的效果
	Duel.RegisterEffect(e1,tp)
end
-- 设置不能特殊召唤的条件：不是不死族
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_ZOMBIE)
end
-- 设置额外召唤的条件：是不死族且等级不超过4
function s.sumtg(e,c)
	return c:IsRace(RACE_ZOMBIE) and c:IsLevelBelow(4)
end
