--闘炎の剣士
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把有「炎之剑士」的卡名记述的1张魔法·陷阱卡加入手卡。
-- ②：这张卡被送去墓地的场合才能发动。除「斗炎之剑士」外的1只「炎之剑士」或者有那个卡名记述的怪兽从卡组·额外卡组送去墓地。
local s,id,o=GetID()
-- 初始化效果注册：为这张卡添加「炎之剑士」的卡名记述，并注册①的召唤·特殊召唤诱发检索效果（e1、e2）和②的被送去墓地的诱发送墓效果（e3）。
function s.initial_effect(c)
	-- 将卡号45231177（炎之剑士）登记为本卡效果文本中记述的卡名，供后续IsCodeListed判断使用。
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
-- 定义检索过滤函数：筛选出效果文本中记述了「炎之剑士」的魔法·陷阱卡，且该卡能够加入手卡。
function s.filter(c)
	-- 判断条件为：卡名记述中有「炎之剑士」、是魔法或陷阱卡、并且能被加入手卡。
	return aux.IsCodeListed(c,45231177) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设为①效果的发动目标判定：确认卡组存在符合条件的魔法·陷阱卡，并声明本效果将把卡加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时合法性检查：卡组中是否存在至少1张满足s.filter的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：预计从卡组将1张卡加入手卡，用于后续的时点·效果检测（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理①效果：让玩家从卡组选择1张符合条件的魔法·陷阱卡加入手卡，并向对方展示。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，告知玩家正在选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的卡组中筛选并选择1张满足s.filter的卡。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入其持有者的手卡（nil表示送入手卡），原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义②效果的送墓过滤函数：筛选出不是本卡（斗炎之剑士），且是「炎之剑士」或效果文本中记述了「炎之剑士」的怪兽，并且能被送去墓地。
function s.tgfilter(c)
	-- 判断条件为：不是这张卡（斗炎之剑士）、（是「炎之剑士」或记述了「炎之剑士」）、是怪兽、且可以送去墓地。
	return not c:IsCode(id) and (c:IsCode(45231177) or aux.IsCodeListed(c,45231177)) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 设为②效果的发动目标判定：确认卡组·额外卡组存在符合条件的怪兽，并声明本效果将把卡送去墓地。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时合法性检查：卡组·额外卡组中是否存在至少1只满足s.tgfilter的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁操作信息：预计从卡组·额外卡组将1张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 处理②效果：让玩家从卡组·额外卡组选择1只符合条件的怪兽送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，告知玩家正在选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组·额外卡组中选择1只满足s.tgfilter的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地，原因为效果。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
