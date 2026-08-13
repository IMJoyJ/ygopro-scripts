--ワンモア・ザ・ワイト
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在墓地存在当作「白骨」使用。
-- ②：这张卡召唤·特殊召唤的场合才能发动。把「翌夜之白骨骑士」以外的1只「白骨」或者1张有那个卡名记述的卡从卡组加入手卡。这个回合，自己不是不死族怪兽不能特殊召唤。
-- ③：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只4星以下的不死族怪兽召唤。
local s,id,o=GetID()
-- 为「翌夜之白骨骑士」注册全部效果：①墓地中卡名当作「白骨」；②召唤/特殊召唤时的检索效果（含同名卡1回合1次限制）；③在场时追加1次4星以下不死族怪兽的通常召唤。
function s.initial_effect(c)
	-- 注册①效果：这张卡的卡名只要在墓地存在当作「白骨」使用。
	aux.EnableChangeCode(c,32274490,LOCATION_GRAVE)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡召唤·特殊召唤的场合才能发动。把「翌夜之白骨骑士」以外的1只「白骨」或者1张有那个卡名记述的卡从卡组加入手卡。这个回合，自己不是不死族怪兽不能特殊召唤。
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
-- 定义②检索用的过滤函数，用于筛选卡组中可加入手牌的「白骨」或记述有「白骨」卡名的卡。
function s.thfilter(c)
	-- 过滤条件：不是本卡自身，且是「白骨」（32274490）或效果文本中记述有「白骨」卡名的卡，并且能够加入手牌。
	return not c:IsCode(id) and aux.IsCodeOrListed(c,32274490) and c:IsAbleToHand()
end
-- ②检索效果的发动判定与操作信息设置：发动时检查卡组是否存在符合条件的检索目标，并声明本效果将把1张卡从卡组加入手牌。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件：自己卡组中存在至少1张满足s.thfilter的卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，声明本连锁处理将把1张卡从卡组加入手卡（CATEGORY_TOHAND），位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：选择1张符合条件的「白骨」相关卡加入手牌并给对方确认，然后给发动者附加本回合不能特殊召唤非不死族怪兽的自肃效果。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家tp从卡组中选出1张满足s.thfilter的卡，存入g。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡送去持有者手牌（即加入手卡），原因是效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对方玩家确认（公开检索信息）。
		Duel.ConfirmCards(1-tp,g)
	end
	-- 这个回合，自己不是不死族怪兽不能特殊召唤。③：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只4星以下的不死族怪兽召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册到玩家tp，使其在本回合内适用不能特殊召唤非不死族怪兽的限制。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃判定函数：当要特殊召唤的怪兽不是不死族时，禁止该特殊召唤。
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_ZOMBIE)
end
-- ③追加通常召唤的适用判定：只有4星以下的不死族怪兽可以进行这次追加的通常召唤。
function s.sumtg(e,c)
	return c:IsRace(RACE_ZOMBIE) and c:IsLevelBelow(4)
end
