--闘炎の剣士
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把有「炎之剑士」的卡名记述的1张魔法·陷阱卡加入手卡。
-- ②：这张卡被送去墓地的场合才能发动。除「斗炎之剑士」外的1只「炎之剑士」或者有那个卡名记述的怪兽从卡组·额外卡组送去墓地。
local s,id,o=GetID()
-- 注册卡片效果，设置效果描述和触发条件
function s.initial_effect(c)
	-- 记录该卡具有「炎之剑士」的卡名记述
	aux.AddCodeList(c,45231177)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把有「炎之剑士」的卡名记述的1张魔法·陷阱卡加入手卡。
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
	-- ②：这张卡被送去墓地的场合才能发动。除「斗炎之剑士」外的1只「炎之剑士」或者有那个卡名记述的怪兽从卡组·额外卡组送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"送去墓地"
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
end
-- 定义检索过滤函数，用于筛选满足条件的魔法·陷阱卡
function s.filter(c)
	-- 筛选条件：该卡记载着「炎之剑士」的卡名记述，且为魔法或陷阱卡，且可以加入手牌
	return aux.IsCodeListed(c,45231177) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置检索效果的发动条件，检查卡组中是否存在满足条件的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判断：检查卡组中是否存在满足条件的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的操作信息，指定将要加入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果的操作，选择并加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义墓地效果的过滤函数，用于筛选满足条件的怪兽
function s.tgfilter(c)
	-- 筛选条件：该卡不是「斗炎之剑士」，且为「炎之剑士」或记载着「炎之剑士」的卡名记述，且为怪兽卡，且可以送去墓地
	return not c:IsCode(id) and (c:IsCode(45231177) or aux.IsCodeListed(c,45231177)) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 设置墓地效果的发动条件，检查卡组或额外卡组中是否存在满足条件的卡
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判断：检查卡组或额外卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	-- 设置墓地效果的操作信息，指定将要送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 执行墓地效果的操作，选择并送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的怪兽卡
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
