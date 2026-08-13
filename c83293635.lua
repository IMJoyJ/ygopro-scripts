--七皇覚醒
-- 效果：
-- ①：战斗阶段，怪兽被战斗·效果破坏的场合，以自己墓地1只「No.」超量怪兽为对象才能发动。种族和那只怪兽相同而阶级高1阶的1只「混沌No.」怪兽从额外卡组特殊召唤，把作为对象的怪兽作为那超量素材。这个效果把「混沌No.101」～「混沌No.107」怪兽的其中任意种特殊召唤的场合，可以再把除「七皇觉醒」外的「七皇」魔法·陷阱卡、「异晶人的」魔法·陷阱卡、「升阶魔法」速攻魔法卡的其中1张从卡组加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果：注册一个魔陷发动型（可在伤害步骤发动、场合型、取对象）的效果，分类为特殊召唤·卡组检索·加入手卡，触发时点为怪兽被破坏时，并设定其发动条件、对象选择和效果处理函数
function s.initial_effect(c)
	-- ①：战斗阶段，怪兽被战斗·效果破坏的场合，以自己墓地1只「No.」超量怪兽为对象才能发动。
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
-- 发动条件：当前处于战斗阶段，且被破坏的怪兽中存在被战斗或效果破坏的怪兽
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前所处的阶段
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
		and eg:IsExists(Card.IsReason,1,nil,REASON_BATTLE+REASON_EFFECT)
end
-- 墓地对象过滤函数：是「No.」系列的超量怪兽且可以作为超量素材
function s.tfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x48) and c:IsCanOverlay()
end
-- 可选为对象的卡的过滤函数：本身是「No.」超量怪兽，且额外卡组存在与之对应的可特殊召唤的「混沌No.」怪兽
function s.cfilter(c,e,tp)
	-- 要求该卡满足墓地对象条件，并且额外卡组至少存在1只种族与其相同、阶级高1阶且可以特殊召唤的「混沌No.」怪兽
	return s.tfilter(c) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,c,e,tp)
end
-- 特殊召唤候选过滤函数：是「混沌No.」系列的超量怪兽，种族与对象怪兽相同、阶级比对象怪兽高1阶
function s.filter(c,tc,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x1048) and c:IsRace(tc:GetRace()) and c:IsRank(tc:GetRank()+1)
		-- 并且场上有可供额外卡组怪兽出场的空格，该卡满足可以被特殊召唤的条件
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 对象选择处理：检查自己墓地是否存在可作为对象的「No.」超量怪兽，存在则选择1只作为对象，并设置特殊召唤与离开墓地的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tfilter(chkc) end
	-- 发动时的合法性检查：自己墓地存在能成为效果对象且满足条件的「No.」超量怪兽
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家提示选择要作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 让自己玩家选择自己墓地1只满足条件的「No.」超量怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：将从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：作为对象的1只卡将离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 检索过滤函数：是除「七皇觉醒」外的「七皇」魔法·陷阱卡、「异晶人的」魔法·陷阱卡或「升阶魔法」速攻魔法卡，且可以加入手卡
function s.sfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(id) and (c:IsSetCard(0x176,0x175) or c:IsSetCard(0x95)
		and c:IsType(TYPE_QUICKPLAY)) and c:IsAbleToHand()
end
-- 效果处理：确认对象仍与连锁关联后，从额外卡组特殊召唤1只满足条件的「混沌No.」怪兽并把对象作为其超量素材；若特殊召唤的是编号101～107的「混沌No.」，则可以再把卡组中满足条件的1张卡加入手卡
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的效果对象（自己墓地的「No.」超量怪兽）
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() then return end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让自己玩家从额外卡组选择1只满足条件的「混沌No.」怪兽
	local sc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,tc,e,tp):GetFirst()
	-- 将选择的「混沌No.」怪兽以表侧表示特殊召唤到自己场上，特殊召唤成功才继续处理
	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 把作为对象的怪兽作为那只特殊召唤怪兽的超量素材叠放
		Duel.Overlay(sc,tc)
		-- 获取特殊召唤的怪兽的「No.」编号
		local no=aux.GetXyzNumber(sc)
		-- 检索卡组中所有满足条件的可加入手卡的魔法·陷阱卡
		local g=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_DECK,0,nil)
		-- 若特殊召唤的是「混沌No.101」～「混沌No.107」怪兽，且卡组存在可加入手卡的卡，则询问玩家是否从卡组把卡加入手卡
		if no and no>=101 and no<=107 and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否从卡组把卡加入手卡？"
			-- 中断当前效果处理，使之后的加入手卡处理与特殊召唤视为不同时处理
			Duel.BreakEffect()
			-- 向玩家提示选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 把选择的卡从卡组加入手卡
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 向对方玩家公开确认加入手卡的卡
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
