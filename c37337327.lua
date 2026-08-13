--ジャンク・コネクター
-- 效果：
-- 包含调整1只以上的战士族·机械族的效果怪兽2只
-- ①：1回合1次，自己·对方的主要阶段以及战斗阶段才能发动。只用这张卡所连接区的怪兽为素材作同调召唤。
-- ②：连接召唤的这张卡被战斗或者对方的效果破坏送去墓地的场合才能发动。从额外卡组把1只「废品」同调怪兽当作同调召唤作特殊召唤。
function c37337327.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：以2只满足mfilter（效果怪兽且种族为战士族或机械族）的怪兽为连接素材，且素材组中必须至少包含1只调整怪兽（lcheck）。
	aux.AddLinkProcedure(c,c37337327.mfilter,2,2,c37337327.lcheck)
	-- ①：1回合1次，自己·对方的主要阶段以及战斗阶段才能发动。只用这张卡所连接区的怪兽为素材作同调召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37337327,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c37337327.sccon)
	e1:SetTarget(c37337327.sctg)
	e1:SetOperation(c37337327.scop)
	c:RegisterEffect(e1)
	-- ②：连接召唤的这张卡被战斗或者对方的效果破坏送去墓地的场合才能发动。从额外卡组把1只「废品」同调怪兽当作同调召唤作特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c37337327.spcon)
	e2:SetTarget(c37337327.sptg)
	e2:SetOperation(c37337327.spop)
	c:RegisterEffect(e2)
end
-- 连接素材的过滤函数：判定素材怪兽必须为效果怪兽，且种族为战士族或机械族。
function c37337327.mfilter(c)
	return c:IsLinkType(TYPE_EFFECT) and c:IsLinkRace(RACE_WARRIOR+RACE_MACHINE)
end
-- 连接素材组的追加检查：这组素材中必须至少存在1只调整怪兽（满足“包含调整1只以上”的要求）。
function c37337327.lcheck(g,lc)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_TUNER)
end
-- 效果①的发动条件：当前阶段必须是主要阶段1、主要阶段2或整个战斗阶段（从战斗阶段开始到战斗阶段结束）。
function c37337327.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前游戏阶段并存入ph，用于判断是否处于①允许发动的阶段。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2
end
-- 同调召唤候选的过滤函数：检查额外卡组的怪兽是否能够只用mg（这张卡所连接区的怪兽）作为素材进行同调召唤。
function c37337327.scfilter(c,mg)
	return c:IsSynchroSummonable(nil,mg)
end
-- 效果①发动合法性判定与操作信息设置：取得本卡所连接区的怪兽作为同调素材组mg，检查额外卡组是否存在能用mg进行同调召唤的怪兽；存在则合法，并设置操作信息为执行1只额外卡组怪兽的特殊召唤。
function c37337327.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=e:GetHandler():GetLinkedGroup()
		-- 检查额外卡组中是否存在至少1只满足scfilter的怪兽，即能够只用当前所连接区的怪兽作为素材进行同调召唤的怪兽。
		return Duel.IsExistingMatchingCard(c37337327.scfilter,tp,LOCATION_EXTRA,0,1,nil,mg)
	end
	-- 设置当前连锁的操作信息：本效果将进行从额外卡组特殊召唤1只怪兽（同调召唤），目标玩家为自己，来源为额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①的处理：确认本卡仍与效果关联后，取得所连接区的怪兽组mg，从额外卡组筛选出所有可用mg进行同调召唤的怪兽，由玩家选择1只，然后以mg为素材执行同调召唤。
function c37337327.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local mg=c:GetLinkedGroup()
	-- 获取额外卡组中所有满足scfilter的同调召唤候选怪兽，构成集合g供选择。
	local g=Duel.GetMatchingGroup(c37337327.scfilter,tp,LOCATION_EXTRA,0,nil,mg)
	if g:GetCount()>0 then
		-- 向玩家显示选择提示，内容为“请选择要特殊召唤的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将玩家选择的那只怪兽以mg（本卡所连接区的怪兽）作为素材进行同调召唤手续，使其作为同调召唤出场。
		Duel.SynchroSummon(tp,sg:GetFirst(),nil,mg)
	end
end
-- 效果②的发动条件判断：这张卡被破坏并送去墓地，且破坏原因为战斗破坏，或由对方玩家的效果破坏；并且这张卡曾经以连接召唤方式成功出场。
function c37337327.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果②的特殊召唤候选过滤：候选怪兽必须是「废品」同调怪兽，能够被当作同调召唤特殊召唤，并且从额外卡组特殊召唤到场上有空位。
function c37337327.spfilter(c,e,tp)
	return c:IsSetCard(0x43) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		-- 检查从额外卡组特殊召唤候选怪兽到自己场上是否有可用的额外/主要怪兽区空格。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果②的发动合法判定：在chk==0时，先确认没有因“必须作为同调素材”效果导致的限制，然后检查额外卡组是否存在满足spfilter的「废品」同调怪兽。
function c37337327.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前是否受“必须作为同调素材”效果影响，若有则不能进行此特殊召唤。
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 若通过素材限制检查，则确认额外卡组中是否存在至少1只满足spfilter的「废品」同调怪兽，以保证有可特殊召唤的目标。
		and Duel.IsExistingMatchingCard(c37337327.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：本效果将进行从额外卡组特殊召唤1只怪兽（同调召唤），供连锁检测等使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的处理：再次确认无同调素材限制，让玩家从额外卡组选择1只符合条件的「废品」同调怪兽，并通过Duel.SpecialSummon以同调召唤方式特殊召唤，成功后调用CompleteProcedure完成同调召唤手续。
function c37337327.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理开始时再次确认不存在“必须作为同调素材”的限制，若存在则效果不处理。
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	-- 显示选择提示，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1张满足spfilter的「废品」同调怪兽，并取为tc，准备进行特殊召唤。
	local g=Duel.SelectMatchingCard(tp,c37337327.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 以同调召唤方式（SUMMON_TYPE_SYNCHRO）将tc特殊召唤到己方场上，若特殊召唤成功（返回值>0）则继续执行后续完成处理。
		if Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
			tc:CompleteProcedure()
		end
	end
end
