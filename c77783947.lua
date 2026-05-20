--竜星の極み
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，可以攻击的对方怪兽必须作出攻击。
-- ②：自己或者对方的主要阶段以及战斗阶段把魔法与陷阱区域表侧表示存在的这张卡送去墓地才能把这个效果发动。用包含「龙星」怪兽1只以上的怪兽为素材把1只同调怪兽同调召唤。
function c77783947.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，可以攻击的对方怪兽必须作出攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_MUST_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e2)
	-- ②：自己或者对方的主要阶段以及战斗阶段把魔法与陷阱区域表侧表示存在的这张卡送去墓地才能把这个效果发动。用包含「龙星」怪兽1只以上的怪兽为素材把1只同调怪兽同调召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_END)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c77783947.sccon)
	e4:SetCost(c77783947.sccost)
	e4:SetTarget(c77783947.sctg)
	e4:SetOperation(c77783947.scop)
	c:RegisterEffect(e4)
end
-- 检查当前阶段是否为自己或对方的主要阶段或战斗阶段
function c77783947.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2
end
-- 过滤「龙星」怪兽卡的条件函数
function c77783947.mfilter(c)
	return c:IsSetCard(0x9e) and c:IsType(TYPE_MONSTER)
end
-- 检查选定的同调素材组是否包含至少1只「龙星」怪兽、是否满足手卡同调限制，并且能用于同调召唤指定的同调怪兽
function c77783947.syncheck(g,tp,syncard)
	-- 检查素材组中是否存在「龙星」怪兽，且满足手卡同调校验，且目标怪兽能以该素材组进行同调召唤
	return g:IsExists(c77783947.mfilter,1,nil) and aux.SynMixHandCheck(g,tp,syncard) and syncard:IsSynchroSummonable(nil,g,#g-1,#g-1)
end
-- 过滤额外卡组中可以进行同调召唤的同调怪兽
function c77783947.spfilter(c,tp,mg)
	if not c:IsType(TYPE_SYNCHRO) then return false end
	-- 设置同调召唤素材等级校验的辅助函数，用于剪枝优化
	aux.GCheckAdditional=aux.SynGroupCheckLevelAddition(c)
	local res=mg:CheckSubGroup(c77783947.syncheck,2,#mg,tp,c)
	-- 清除同调召唤素材等级校验的辅助函数
	aux.GCheckAdditional=nil
	return res
end
-- 效果②的发动代价：将表侧表示的这张卡送去墓地
function c77783947.sccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 作为发动代价，将这张卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 效果②的发动准备（Target）：检查玩家是否能特殊召唤，获取可用的同调素材（含手卡），并确认额外卡组是否存在可同调召唤的怪兽，最后设置特殊召唤的操作信息
function c77783947.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查玩家当前是否能够进行特殊召唤，若不能则无法发动
		if not Duel.IsPlayerCanSpecialSummon(tp) then return false end
		-- 获取玩家场上可用的同调素材怪兽
		local mg=Duel.GetSynchroMaterial(tp)
		if mg:IsExists(Card.GetHandSynchro,1,nil) then
			-- 获取玩家手卡中的所有卡片（用于后续手卡同调素材的合并）
			local mg2=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
			if mg2:GetCount()>0 then mg:Merge(mg2) end
		end
		-- 检查额外卡组中是否存在至少1只可以使用当前素材进行同调召唤的同调怪兽
		return Duel.IsExistingMatchingCard(c77783947.spfilter,tp,LOCATION_EXTRA,0,1,nil,tp,mg)
	end
	-- 设置连锁的操作信息，表示该效果包含从额外卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的效果处理（Operation）：获取同调素材，筛选出可同调召唤的怪兽，让玩家选择要召唤的同调怪兽及对应的同调素材，并进行同调召唤
function c77783947.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的同调素材怪兽
	local mg=Duel.GetSynchroMaterial(tp)
	if mg:IsExists(Card.GetHandSynchro,1,nil) then
		-- 获取玩家手卡中的所有卡片（用于后续手卡同调素材的合并）
		local mg2=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
		if mg2:GetCount()>0 then mg:Merge(mg2) end
	end
	-- 过滤出额外卡组中当前可以进行同调召唤的同调怪兽组
	local g=Duel.GetMatchingGroup(c77783947.spfilter,tp,LOCATION_EXTRA,0,nil,tp,mg)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的同调怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		local sc=sg:GetFirst()
		-- 提示玩家选择要作为同调素材的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)  --"请选择要作为同调素材的卡"
		local tg=mg:SelectSubGroup(tp,c77783947.syncheck,false,2,#mg,tp,sc)
		-- 让玩家使用选定的素材对选定的同调怪兽进行同调召唤
		Duel.SynchroSummon(tp,sc,nil,tg,#tg-1,#tg-1)
	end
end
