--ヤミー★スナッチー
-- 效果：
-- 4星以下的兽族·光属性怪兽1只
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从手卡·卡组把1张「味美喵」场地魔法卡在自己场上表侧表示放置。这个回合，自己不能把连接3以上的连接怪兽连接召唤。
-- ②：自己·对方的主要阶段以及对方战斗阶段，支付100基本分才能发动（同一连锁上最多1次）。用包含「味美喵」怪兽的自己场上的怪兽为素材进行同调召唤。
local s,id,o=GetID()
-- 注册该卡：先设置连接召唤素材条件（1只光属性·兽族·4星以下怪兽）并赋予苏生限制，再分别注册①的诱发选发效果（特殊召唤成功时放置场地魔法）和②的诱发即时效果（二速同调召唤）。
function s.initial_effect(c)
	-- 为这张卡添加连接召唤手续，要求以1只满足matfilter条件的怪兽作为连接素材，素材数量为1只。
	aux.AddLinkProcedure(c,s.matfilter,1,1)
	c:EnableReviveLimit()
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡特殊召唤的场合才能发动。从手卡·卡组把1张「味美喵」场地魔法卡在自己场上表侧表示放置。（后续自肃在效果处理中设置）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"放置场地魔法"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.actg)
	e1:SetOperation(s.acop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的主要阶段以及对方战斗阶段，支付100基本分才能发动（同一连锁上最多1次）。用包含「味美喵」怪兽的自己场上的怪兽为素材进行同调召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"同调召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(s.sccon)
	e2:SetCost(s.sccost)
	e2:SetTarget(s.sctg)
	e2:SetOperation(s.scop)
	c:RegisterEffect(e2)
end
-- 连接素材过滤条件：连接怪兽必须为光属性、兽族、且等级在4星以下。
function s.matfilter(c)
	return c:IsLinkAttribute(ATTRIBUTE_LIGHT) and c:IsLinkRace(RACE_BEAST) and c:IsLevelBelow(4)
end
-- 场地魔法卡过滤条件：是「味美喵」字段（0x1ca）的场地魔法卡，未被禁止，且自己场上不存在同名卡（满足场上同名唯一限制）。
function s.stfilter(c,tp)
	return c:IsSetCard(0x1ca) and c:IsType(TYPE_FIELD) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- ①效果的发动条件判定函数：仅在效果发动的check阶段（chk==0）能够从手卡·卡组找到至少1张满足stfilter的场地魔法卡时，才允许发动。
function s.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡·卡组中是否存在至少1张满足stfilter条件（「味美喵」场地魔法卡）的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,tp) end
end
-- ①效果处理：让玩家从手卡·卡组选择1张「味美喵」场地魔法卡，若自己场地区域已有卡则先将其按规则送去墓地，再将选择的卡表侧表示放置到场地区域；随后给自己附加“本回合不能连接召唤连接3以上的怪兽”的自肃效果。
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出卡片选择提示，提示玩家选择要放置到场上的卡（HINTMSG_TOFIELD）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 玩家从手卡·卡组选择1张满足stfilter的「味美喵」场地魔法卡，并取其唯一对象。
	local tc=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 获取自己场地区域（LOCATION_SZONE的sequence 5）上当前存在的卡片，用于处理场地魔法替换规则。
		local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
		if fc then
			-- 若已有场地魔法卡，则将其以规则理由（REASON_RULE）送去墓地，即场地魔法卡的替换处理。
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果处理，使此后放置场地魔法的处理与之前场地卡送墓不在同一时点处理，避免误触发“时”类时点。
			Duel.BreakEffect()
		end
		-- 将选择的场地魔法卡以表侧表示放置到自己场上的场地区域（LOCATION_FZONE），并立刻适用其效果。
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	end
	-- 这个回合，自己不能把连接3以上的连接怪兽连接召唤。②：自己·对方的主要阶段以及对方战斗阶段，支付100基本分才能发动（同一连锁上最多1次）。用包含「味美喵」怪兽的自己场上的怪兽为素材进行同调召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能特殊召唤连接3以上怪兽”的自肃效果作为场地型效果注册到当前玩家，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃效果的判定函数：若被特殊召唤的怪兽是连接3以上的连接怪兽，且召唤方式为连接召唤，则禁止该特殊召唤。
function s.splimit(e,c,tp,sumtp,sumpos)
	return c:IsLinkAbove(3) and bit.band(sumtp,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end
-- ②效果的发动条件判定：当前处于主要阶段（自己或对方均可），或者处于对方战斗阶段时，才能发动。
function s.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定发动时机：满足“当前是主要阶段”或“当前为对方回合的战斗阶段”时返回true。
	return Duel.IsMainPhase() or Duel.GetTurnPlayer()~=tp and Duel.IsBattlePhase()
end
-- ②效果的发动代价：先检查能否支付100基本分，确认后实际支付100基本分。
function s.sccost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动cost的check阶段：检查自己是否能支付100基本分。
	if chk==0 then return Duel.CheckLPCost(tp,100) end
	-- 实际支付100基本分作为发动②效果的代价。
	Duel.PayLPCost(tp,100)
end
-- 同调素材怪兽过滤条件：是「味美喵」字段的怪兽，且为表侧表示怪兽。
function s.mfilter(c)
	return c:IsSetCard(0x1ca) and c:IsType(TYPE_MONSTER) and c:IsFaceup()
end
-- 同调素材组合法性判定：素材组中至少包含1只「味美喵」怪兽，且通过手牌同调素材规则检查，并且目标同调怪兽能够用该素材组进行同调召唤（素材数量限制为#g-1）。
function s.syncheck(g,tp,syncard)
	-- 判断素材组g是否合法：组内存在至少1只味美喵怪兽，且满足手牌同调辅助检查，且目标同调怪兽可用该组素材进行同调召唤。
	return g:IsExists(s.mfilter,1,nil) and aux.SynMixHandCheck(g,tp,syncard) and syncard:IsSynchroSummonable(nil,g,#g-1,#g-1)
end
-- 额外卡组同调怪兽筛选函数：目标必须是同调怪兽，并且现有素材中能找到满足syncheck条件（含味美喵怪兽、等级条件、数量条件）的子组来同调召唤它。
function s.scfilter(c,tp,mg)
	if not c:IsType(TYPE_SYNCHRO) then return false end
	-- 设置额外的同调素材等级判定闭包（根据目标同调怪兽计算素材等级限制），供后续CheckSubGroup筛选素材组时使用。
	aux.GCheckAdditional=aux.SynGroupCheckLevelAddition(c)
	local res=mg:CheckSubGroup(s.syncheck,2,#mg,tp,c)
	-- 清除之前设置的额外等级判定函数，避免影响其他同调召唤检查。
	aux.GCheckAdditional=nil
	return res
end
-- ②效果发动时的目标处理：确认自己可以进行特殊召唤，取得可用的同调素材（手牌中有手牌同调素材则并入），并检查额外卡组是否存在可同调召唤的目标；若满足则向对手提示发动，并设置特殊召唤的操作信息。
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 发动前检查自己是否处于可以进行特殊召唤的状态，若不能则禁止发动②效果。
		if not Duel.IsPlayerCanSpecialSummon(tp) then return false end
		-- 获取自己场上可用于同调召唤的素材怪兽集合（包含调整和非调整）。
		local mg=Duel.GetSynchroMaterial(tp)
		if mg:IsExists(Card.GetHandSynchro,1,nil) then
			-- 获取自己手牌中的所有怪兽，用于在手牌同调素材存在时把它们也加入素材候选。
			local mg2=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
			if mg2:GetCount()>0 then mg:Merge(mg2) end
		end
		-- 检查额外卡组中是否存在至少1只满足scfilter条件的同调怪兽，即能用当前素材实际同调召唤出来的目标。
		return Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_EXTRA,0,1,nil,tp,mg)
	end
	-- 向对方玩家提示自己发动了②效果，并展示该效果的描述信息。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置当前连锁的操作信息为“特殊召唤”分类，目标是从额外卡组特殊召唤1只怪兽（数量1）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果处理：重新获取同调素材（含手牌同调素材），在额外卡组中检索可同调召唤的目标，让玩家选择要召唤的同调怪兽，再从素材中选出符合条件的一组，执行同调召唤。
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用于同调召唤的素材怪兽集合（包含调整和非调整）。
	local mg=Duel.GetSynchroMaterial(tp)
	if mg:IsExists(Card.GetHandSynchro,1,nil) then
		-- 获取自己手牌中的所有怪兽，若存在手牌同调素材则并入素材候选。
		local mg2=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
		if mg2:GetCount()>0 then mg:Merge(mg2) end
	end
	-- 获取额外卡组中所有满足scfilter条件（可作为当前同调召唤目标）的同调怪兽集合。
	local g=Duel.GetMatchingGroup(s.scfilter,tp,LOCATION_EXTRA,0,nil,tp,mg)
	if g:GetCount()>0 then
		-- 弹出选择提示，让玩家选择要特殊召唤的同调怪兽（HINTMSG_SPSUMMON）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		local sc=sg:GetFirst()
		-- 弹出选择提示，让玩家选择要作为同调素材的怪兽（HINTMSG_SMATERIAL）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)  --"请选择要作为同调素材的卡"
		local tg=mg:SelectSubGroup(tp,s.syncheck,false,2,#mg,tp,sc)
		-- 执行同调召唤：以选择的目标同调怪兽作为召唤结果，用选出的素材组tg完成同调召唤手续（minc=maxc=#tg-1）。
		Duel.SynchroSummon(tp,sc,nil,tg,#tg-1,#tg-1)
	end
end
