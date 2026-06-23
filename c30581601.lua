--ヤミー★スナッチー
-- 效果：
-- 4星以下的兽族·光属性怪兽1只
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从手卡·卡组把1张「味美喵」场地魔法卡在自己场上表侧表示放置。这个回合，自己不能把连接3以上的连接怪兽连接召唤。
-- ②：自己·对方的主要阶段以及对方战斗阶段，支付100基本分才能发动（同一连锁上最多1次）。用包含「味美喵」怪兽的自己场上的怪兽为素材进行同调召唤。
local s,id,o=GetID()
-- 初始化卡片效果，添加连接召唤手续并启用复活限制
function s.initial_effect(c)
	-- 为该卡添加连接召唤手续，要求使用1~1个满足matfilter条件的怪兽作为连接素材
	aux.AddLinkProcedure(c,s.matfilter,1,1)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合才能发动。从手卡·卡组把1张「味美喵」场地魔法卡在自己场上表侧表示放置。
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
-- 连接素材过滤器，筛选4星以下的光属性兽族怪兽
function s.matfilter(c)
	return c:IsLinkAttribute(ATTRIBUTE_LIGHT) and c:IsLinkRace(RACE_BEAST) and c:IsLevelBelow(4)
end
-- 场地魔法卡过滤器，筛选「味美喵」场地魔法卡且未被禁止且可放置
function s.stfilter(c,tp)
	return c:IsSetCard(0x1ca) and c:IsType(TYPE_FIELD) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 效果处理目标函数，检查是否存在满足条件的场地魔法卡
function s.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的场地魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,tp) end
end
-- 效果处理函数，选择并放置场地魔法卡，同时设置不能特殊召唤连接3以上的连接怪兽的效果
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要放置到场上的场地魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 选择满足条件的场地魔法卡
	local tc=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 获取玩家场上5号位置的场地卡
		local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
		if fc then
			-- 将场上已有的场地卡送入墓地
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果处理
			Duel.BreakEffect()
		end
		-- 将选中的场地魔法卡移至场上
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	end
	-- 创建并注册一个禁止特殊召唤连接3以上连接怪兽的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的条件，禁止召唤连接3以上的连接怪兽
function s.splimit(e,c,tp,sumtp,sumpos)
	return c:IsLinkAbove(3) and bit.band(sumtp,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end
-- 同调召唤发动条件函数，判断是否在主要阶段或对方战斗阶段
function s.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否在主要阶段或对方战斗阶段
	return Duel.IsMainPhase() or Duel.GetTurnPlayer()~=tp and Duel.IsBattlePhase()
end
-- 同调召唤支付费用函数，检查是否能支付100基本分
function s.sccost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付100基本分
	if chk==0 then return Duel.CheckLPCost(tp,100) end
	-- 支付100基本分
	Duel.PayLPCost(tp,100)
end
-- 同调素材过滤器，筛选「味美喵」怪兽且处于表侧表示
function s.mfilter(c)
	return c:IsSetCard(0x1ca) and c:IsType(TYPE_MONSTER) and c:IsFaceup()
end
-- 同调召唤素材合法性检查函数，验证是否包含味美喵怪兽且满足手卡同调条件
function s.syncheck(g,tp,syncard)
	-- 验证是否包含味美喵怪兽且满足手卡同调条件
	return g:IsExists(s.mfilter,1,nil) and aux.SynMixHandCheck(g,tp,syncard) and syncard:IsSynchroSummonable(nil,g,#g-1,#g-1)
end
-- 同调召唤目标过滤器，筛选满足同调召唤条件的怪兽
function s.scfilter(c,tp,mg)
	if not c:IsType(TYPE_SYNCHRO) then return false end
	-- 设置同调等级加成检查函数
	aux.GCheckAdditional=aux.SynGroupCheckLevelAddition(c)
	local res=mg:CheckSubGroup(s.syncheck,2,#mg,tp,c)
	-- 清除同调等级加成检查函数
	aux.GCheckAdditional=nil
	return res
end
-- 同调召唤处理目标函数，检查是否存在满足条件的同调怪兽
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查玩家是否可以特殊召唤
		if not Duel.IsPlayerCanSpecialSummon(tp) then return false end
		-- 获取玩家的同调素材
		local mg=Duel.GetSynchroMaterial(tp)
		if mg:IsExists(Card.GetHandSynchro,1,nil) then
			-- 获取玩家手卡中的同调素材
			local mg2=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
			if mg2:GetCount()>0 then mg:Merge(mg2) end
		end
		-- 检查是否存在满足条件的同调怪兽
		return Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_EXTRA,0,1,nil,tp,mg)
	end
	-- 提示对方玩家选择了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息，表示将要特殊召唤同调怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 同调召唤处理函数，选择并进行同调召唤
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家的同调素材
	local mg=Duel.GetSynchroMaterial(tp)
	if mg:IsExists(Card.GetHandSynchro,1,nil) then
		-- 获取玩家手卡中的同调素材
		local mg2=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
		if mg2:GetCount()>0 then mg:Merge(mg2) end
	end
	-- 获取满足同调召唤条件的怪兽
	local g=Duel.GetMatchingGroup(s.scfilter,tp,LOCATION_EXTRA,0,nil,tp,mg)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的同调怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		local sc=sg:GetFirst()
		-- 提示玩家选择作为同调素材的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)  --"请选择要作为同调素材的卡"
		local tg=mg:SelectSubGroup(tp,s.syncheck,false,2,#mg,tp,sc)
		-- 执行同调召唤手续
		Duel.SynchroSummon(tp,sc,nil,tg,#tg-1,#tg-1)
	end
end
