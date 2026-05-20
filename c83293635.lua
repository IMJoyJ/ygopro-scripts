--七皇覚醒
-- 效果：
-- ①：战斗阶段，怪兽被战斗·效果破坏的场合，以自己墓地1只「No.」超量怪兽为对象才能发动。种族和那只怪兽相同而阶级高1阶的1只「混沌No.」怪兽从额外卡组特殊召唤，把作为对象的怪兽作为那超量素材。这个效果把「混沌No.101」～「混沌No.107」怪兽的其中任意种特殊召唤的场合，可以再把除「七皇觉醒」外的「七皇」魔法·陷阱卡、「异晶人的」魔法·陷阱卡、「升阶魔法」速攻魔法卡的其中1张从卡组加入手卡。
local s,id,o=GetID()
-- 定义卡片效果的初始化函数，注册该卡的发动效果、分类、时点等属性
function s.initial_effect(c)
	-- ①：战斗阶段，怪兽被战斗·效果破坏的场合，以自己墓地1只「No.」超量怪兽为对象才能发动。种族和那只怪兽相同而阶级高1阶的1只「混沌No.」怪兽从额外卡组特殊召唤，把作为对象的怪兽作为那超量素材。这个效果把「混沌No.101」～「混沌No.107」怪兽的其中任意种特殊召唤的场合，可以再把除「七皇觉醒」外的「七皇」魔法·陷阱卡、「异晶人的」魔法·陷阱卡、「升阶魔法」速攻魔法卡的其中1张从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 检查发动条件：当前是否为战斗阶段，且是否有怪兽被战斗或效果破坏
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
		and eg:IsExists(Card.IsReason,1,nil,REASON_BATTLE+REASON_EFFECT)
end
-- 过滤自己墓地中可以作为超量素材的「No.」超量怪兽
function s.tfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x48) and c:IsCanOverlay()
end
-- 过滤墓地中满足条件的「No.」超量怪兽，且额外卡组存在能以其为素材进行特殊召唤的「混沌No.」怪兽
function s.cfilter(c,e,tp)
	-- 检查该卡是否为合法的「No.」超量怪兽，且额外卡组中是否存在对应的「混沌No.」怪兽
	return s.tfilter(c) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,c,e,tp)
end
-- 过滤额外卡组中与目标怪兽种族相同、阶级高1阶、且能特殊召唤的「混沌No.」超量怪兽
function s.filter(c,tc,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x1048) and c:IsRace(tc:GetRace()) and c:IsRank(tc:GetRank()+1)
		-- 检查额外卡组怪兽特殊召唤所需的怪兽区域空格，并确认该怪兽是否可以特殊召唤
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与处理，包括检查合法对象、选择墓地的「No.」怪兽作为对象，并设置特殊召唤和卡片离开墓地的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tfilter(chkc) end
	-- 步骤0：检查自己墓地是否存在满足条件的「No.」超量怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 玩家选择自己墓地1只满足条件的「No.」超量怪兽作为对象
	local g=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：对象怪兽离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 过滤卡组中除「七皇觉醒」外，满足条件的「七皇」魔陷、「异晶人的」魔陷或「升阶魔法」速攻魔法
function s.sfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(id) and (c:IsSetCard(0x176,0x175) or c:IsSetCard(0x95)
		and c:IsType(TYPE_QUICKPLAY)) and c:IsAbleToHand()
end
-- 效果处理：特殊召唤「混沌No.」怪兽并重叠素材，若满足条件则可选择从卡组检索1张特定魔陷
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的墓地中的「No.」超量怪兽对象
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从额外卡组选择1只满足条件的「混沌No.」怪兽
	local sc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,tc,e,tp):GetFirst()
	-- 如果成功将选择的「混沌No.」怪兽以表侧表示特殊召唤
	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP) then
		-- 将作为对象的墓地怪兽重叠作为该特殊召唤怪兽的超量素材
		Duel.Overlay(sc,tc)
		-- 获取特殊召唤的「混沌No.」怪兽的「No.」编号
		local no=aux.GetXyzNumber(sc)
		-- 获取卡组中所有满足检索条件的魔陷卡
		local g=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_DECK,0,nil)
		-- 若特殊召唤的是「混沌No.101」～「混沌No.107」且卡组有可检索的卡，询问玩家是否发动追加检索效果
		if no and no>=101 and no<=107 and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否从卡组把卡加入手卡？"
			-- 中断当前效果处理，使后续的检索处理与特殊召唤不视为同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选择的卡加入玩家手牌
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 向对方玩家确认加入手牌的卡
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
