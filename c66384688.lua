--マジェスペクター・オルト
-- 效果：
-- 包含「威风妖怪」怪兽的灵摆怪兽2只
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从自己的额外卡组（表侧）把最多2只「威风妖怪」灵摆怪兽加入手卡。那之后，可以从卡组把最多2只「威风妖怪」灵摆怪兽表侧加入额外卡组（同名卡最多1张）。这个效果的发动后，直到回合结束时自己不是「威风妖怪」怪兽以及「龙剑士」怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，设置连接召唤手续，并注册连接召唤成功时发动的效果。
function s.initial_effect(c)
	-- 设置连接召唤手续：需要2只灵摆怪兽作为素材，且必须包含「威风妖怪」怪兽。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_PENDULUM),2,2,s.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合才能发动。从自己的额外卡组（表侧）把最多2只「威风妖怪」灵摆怪兽加入手卡。那之后，可以从卡组把最多2只「威风妖怪」灵摆怪兽表侧加入额外卡组（同名卡最多1张）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"额外卡组灵摆怪兽加入手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
-- 检查连接素材中是否包含至少1只「威风妖怪」怪兽。
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0xd0)
end
-- 检查这张卡是否是通过连接召唤的方式特殊召唤。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤条件：自己额外卡组中表侧表示的「威风妖怪」灵摆怪兽。
function s.thfilter(c)
	return c:IsSetCard(0xd0) and c:IsType(TYPE_PENDULUM) and c:IsFaceup() and c:IsAbleToHand()
end
-- 过滤条件：卡组中的「威风妖怪」灵摆怪兽。
function s.tefilter(c)
	return c:IsSetCard(0xd0) and c:IsType(TYPE_PENDULUM)
end
-- 设置效果发动时的目标：检查额外卡组是否存在符合条件的卡，并设置将卡加入手牌的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己额外卡组（表侧）是否存在至少1只「威风妖怪」灵摆怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息：从额外卡组将卡片加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：将额外卡组的「威风妖怪」灵摆怪兽加入手牌，之后可选择将卡组的「威风妖怪」灵摆怪兽表侧加入额外卡组，并适用额外卡组特殊召唤限制。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己额外卡组（表侧）选择1到2只「威风妖怪」灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_EXTRA,0,1,2,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
		-- 洗切手牌。
		Duel.ShuffleHand(tp)
		-- 获取自己卡组中所有「威风妖怪」灵摆怪兽。
		local cg=Duel.GetMatchingGroup(s.tefilter,tp,LOCATION_DECK,0,nil)
		-- 若卡组中存在符合条件的卡，询问玩家是否选择将卡片加入额外卡组。
		if #cg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否从卡组把灵摆怪兽加入额外卡组？"
			-- 提示玩家选择要加入额外卡组的卡片。
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))  --"请选择要加入额外卡组的卡"
			-- 让玩家从卡组中选择最多2张卡名不同的「威风妖怪」灵摆怪兽。
			local hg=cg:SelectSubGroup(tp,aux.dncheck,false,1,2)
			if hg:GetCount()>0 then
				-- 中断当前效果，使后续的加入额外卡组处理与加入手牌不视为同时处理。
				Duel.BreakEffect()
				-- 将选择的卡片表侧表示送去额外卡组。
				Duel.SendtoExtraP(hg,nil,REASON_EFFECT)
			end
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是「威风妖怪」怪兽以及「龙剑士」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该回合内限制从额外卡组特殊召唤的玩家效果。
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：不能从额外卡组特殊召唤「威风妖怪」以及「龙剑士」以外的怪兽。
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0xd0,0xc7) and c:IsLocation(LOCATION_EXTRA)
end
