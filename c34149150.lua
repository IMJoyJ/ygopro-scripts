--葬角のカルノヴルス
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段以及战斗阶段才能发动。用包含这张卡的自己场上的怪兽为素材进行1只恐龙族同调怪兽的同调召唤。
-- ②：自己或对方的怪兽的攻击宣言时才能发动。从手卡把1只恐龙族怪兽无视召唤条件特殊召唤。这个效果的发动后，直到回合结束时自己不是恐龙族怪兽不能特殊召唤。
local s,id,o=GetID()
-- 初始化该卡的效果：注册同调召唤手续（调整为任意、调整以外怪兽1只以上），并注册①（自由时点同调召唤）和②（攻击宣言时手牌恐龙特召）两个效果，分别设置各自的发动条件、发动时处理和效果处理。
function s.initial_effect(c)
	-- 为这张卡添加同调召唤手续：作为同调素材时，需要“调整＋调整以外的怪兽1只以上”，其中调整不限种族，调整以外怪兽也不限种族，数量合计1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：自己·对方的主要阶段以及战斗阶段才能发动。用包含这张卡的自己场上的怪兽为素材进行1只恐龙族同调怪兽的同调召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"同调召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.sccon)
	e1:SetTarget(s.sctg)
	e1:SetOperation(s.scop)
	c:RegisterEffect(e1)
	-- ②：自己或对方的怪兽的攻击宣言时才能发动。从手卡把1只恐龙族怪兽无视召唤条件特殊召唤。这个效果的发动后，直到回合结束时自己不是恐龙族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从手卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：当前阶段为自己/对方的主要阶段（主要阶段1或主要阶段2）或战斗阶段（从战斗阶段开始到战斗阶段结束）时才可发动。
function s.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段并保存到局部变量ph中。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2
end
-- 额外卡组怪兽的过滤条件：该怪兽是可以以这张卡（mc）为素材进行同调召唤的恐龙族同调怪兽。
function s.scfilter(c,mc)
	return c:IsSynchroSummonable(mc) and c:IsRace(RACE_DINOSAUR)
end
-- 效果①发动时的处理：先确认额外卡组存在可用的恐龙族同调怪兽；若存在，则设置同调召唤的操作信息，并向对方发送已选择发动此效果的提示。
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时判定：额外卡组是否存在至少1只可以以这张卡为素材进行同调召唤的恐龙族同调怪兽，若存在则允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
	-- 设置操作信息：本次连锁将进行1只特殊召唤（同调召唤），召唤来源为额外卡组，目标怪兽在效果处理时再确定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 向对方玩家提示“选择了该效果”，并展示此效果的文字描述。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果①的处理：确认此卡仍在场上且与效果关联且非里侧表示后，从额外卡组选择1只恐龙族同调怪兽，以包含这张卡的自己场上怪兽为素材进行同调召唤。
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取额外卡组中所有满足条件的恐龙族同调怪兽（能以这张卡为素材进行同调召唤）的集合。
	local g=Duel.GetMatchingGroup(s.scfilter,tp,LOCATION_EXTRA,0,nil,c)
	if g:GetCount()>0 then
		-- 弹出选择提示，要求玩家选择要特殊召唤（同调召唤）的恐龙族怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 以这张卡作为同调素材中的调整，对选择的额外怪兽执行同调召唤手续（从自己场上选择其他素材并完成特殊召唤）。
		Duel.SynchroSummon(tp,sg:GetFirst(),c)
	end
end
-- 手牌怪兽的过滤条件：该怪兽是恐龙族，并且可以被无视召唤条件地特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_DINOSAUR) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果②的发动判定：自己主要怪兽区有空位，且手牌中存在恐龙族且可无视召唤条件特殊召唤的怪兽时才可发动。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有空余区域可用来特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查手牌中是否存在满足s.spfilter条件的恐龙族怪兽（恐龙族且可无视召唤条件特殊召唤），作为发动条件之一。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本次连锁将从手卡进行1只特殊召唤，目标卡在手卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 向对方玩家提示“选择了该效果”，并展示此效果的文字描述。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果②的处理：若自己主要怪兽区有空位，则从手牌选择1只恐龙族怪兽无视召唤条件特殊召唤；之后给自己附加直到回合结束时不能特殊召唤恐龙族以外怪兽的自肃效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 确认自己主要怪兽区仍有空位时才执行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 弹出选择提示，要求玩家选择要特殊召唤的恐龙族怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手牌中选择1只满足条件（恐龙族且可无视召唤条件特殊召唤）的怪兽。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的恐龙族怪兽无视召唤条件以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是恐龙族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册给玩家tp，使其影响该玩家后续的特殊召唤行为。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃判定：当被特殊召唤的怪兽不是恐龙族时返回true，即禁止该特殊召唤。
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_DINOSAUR)
end
