--ワイバーンの竜騎士
local s,id,o=GetID()
-- 初始化效果函数，注册所有卡片效果
function s.initial_effect(c)
	-- 记录该卡记载着40235813这张卡名
	aux.AddCodeList(c,40235813)
	-- 创建一个起动效果，可以在手牌中发动，将自己特殊召唤到场上
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 创建一个诱发选发效果，通常召唤成功时发动，可以从卡组检索魔法陷阱卡并加入手牌，然后自己丢弃一张手牌
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_HANDES_SELF)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 创建一个永续效果，使该卡获得直接攻击能力
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于检查手牌中是否包含40235813且未公开的卡片
function s.cfilter(c)
	-- 返回true表示该卡是40235813且未公开
	return aux.IsCodeListed(c,40235813) and not c:IsPublic()
end
-- 特殊召唤的费用处理函数，需要确认一张手牌并洗切手牌
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否手牌中有满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,c) end
	-- 提示玩家选择要确认的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择满足条件的一张手牌
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,c)
	-- 向对方确认所选卡片
	Duel.ConfirmCards(1-tp,g)
	-- 将自己的手牌洗切
	Duel.ShuffleHand(tp)
end
-- 特殊召唤的目标函数，检查是否有足够的场地区域和是否可以特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有足够的场地区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示要特殊召唤该卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤的操作函数，如果该卡在连锁中则将其特殊召唤到场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将该卡以0方式特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于检索卡组中40235813的魔法陷阱卡
function s.thfilter(c)
	-- 返回true表示该卡是40235813且为魔法陷阱类型并能加入手牌
	return aux.IsCodeListed(c,40235813) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 检索效果的目标函数，检查卡组中是否有满足条件的卡片
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否有满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示要将一张魔法陷阱卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的操作函数，从卡组选择1-2张40235813的魔法陷阱卡加入手牌，并丢弃一张手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的魔法陷阱卡组
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()==0 then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足“卡名不同”条件的卡组
	local tg1=g:SelectSubGroup(tp,aux.dncheck,false,1,2)
	-- 将选中的卡加入手牌，如果成功则继续处理后续效果
	if Duel.SendtoHand(tg1,nil,REASON_EFFECT)>0 then
		-- 向对方确认所选加入手牌的卡
		Duel.ConfirmCards(1-tp,tg1)
		-- 中断当前效果，使之后的效果视为不同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要丢弃的手牌
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		-- 选择一张可丢弃的手牌
		local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_EFFECT)
		-- 将自己的手牌洗切
		Duel.ShuffleHand(tp)
		-- 将选中的手牌送入墓地
		Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
	end
end
