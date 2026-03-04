--闘炎の剣士
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把有「炎之剑士」的卡名记述的1张魔法·陷阱卡加入手卡。
-- ②：这张卡被送去墓地的场合才能发动。除「斗炎之剑士」外的1只「炎之剑士」或者有那个卡名记述的怪兽从卡组·额外卡组送去墓地。
local s,id,o=GetID()
-- 初始化卡片效果函数
function s.initial_effect(c)
	-- 为卡片注册“有炎之剑士”记述的卡片代码列表
	aux.AddCodeList(c,45231177)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把有「炎之剑士」的卡名记述的1张魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
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
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
end
-- 定义检索过滤函数
function s.filter(c)
	-- 过滤条件：卡片有炎之剑士记述且为魔法·陷阱卡且能加入手牌
	return aux.IsCodeListed(c,45231177) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 定义效果①的处理目标函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足效果①的发动条件：卡组中存在符合条件的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果①的处理信息：将1张魔法·陷阱卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义效果①的处理函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择满足条件的1张魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义效果②的过滤函数
function s.tgfilter(c)
	-- 过滤条件：不是斗炎之剑士且为炎之剑士或有炎之剑士记述的怪兽且能送去墓地
	return not c:IsCode(id) and (c:IsCode(45231177) or aux.IsCodeListed(c,45231177)) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 定义效果②的处理目标函数
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足效果②的发动条件：卡组或额外卡组中存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	-- 设置效果②的处理信息：将1只怪兽从卡组·额外卡组送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 定义效果②的处理函数
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
