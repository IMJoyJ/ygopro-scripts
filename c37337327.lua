--ジャンク・コネクター
-- 效果：
-- 包含调整1只以上的战士族·机械族的效果怪兽2只
-- ①：1回合1次，自己·对方的主要阶段以及战斗阶段才能发动。只用这张卡所连接区的怪兽为素材作同调召唤。
-- ②：连接召唤的这张卡被战斗或者对方的效果破坏送去墓地的场合才能发动。从额外卡组把1只「废品」同调怪兽当作同调召唤作特殊召唤。
function c37337327.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，要求使用2~2个满足条件的怪兽作为连接素材，其中至少包含1个调整
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
-- 连接素材必须是效果怪兽且种族为战士族或机械族
function c37337327.mfilter(c)
	return c:IsLinkType(TYPE_EFFECT) and c:IsLinkRace(RACE_WARRIOR+RACE_MACHINE)
end
-- 连接素材中必须包含调整
function c37337327.lcheck(g,lc)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_TUNER)
end
-- 判断当前是否处于主要阶段1、战斗阶段开始到结束或主要阶段2
function c37337327.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2
end
-- 判断额外卡组中是否存在满足同调召唤条件的怪兽
function c37337327.scfilter(c,mg)
	return c:IsSynchroSummonable(nil,mg)
end
-- 检查是否满足发动条件，检索满足条件的同调怪兽
function c37337327.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=e:GetHandler():GetLinkedGroup()
		-- 检查是否存在满足条件的同调怪兽
		return Duel.IsExistingMatchingCard(c37337327.scfilter,tp,LOCATION_EXTRA,0,1,nil,mg)
	end
	-- 设置操作信息，提示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行同调召唤操作，使用连接区怪兽作为素材进行同调召唤
function c37337327.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local mg=c:GetLinkedGroup()
	-- 检索满足条件的同调怪兽
	local g=Duel.GetMatchingGroup(c37337327.scfilter,tp,LOCATION_EXTRA,0,nil,mg)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 执行同调召唤
		Duel.SynchroSummon(tp,sg:GetFirst(),nil,mg)
	end
end
-- 判断卡片被破坏送去墓地的原因是否为战斗或对方效果，并且是连接召唤
function c37337327.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- 筛选额外卡组中满足条件的「废品」同调怪兽
function c37337327.spfilter(c,e,tp)
	return c:IsSetCard(0x43) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		-- 检查场上是否有足够的位置进行特殊召唤
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 检查是否满足发动条件，检索满足条件的「废品」同调怪兽
function c37337327.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测是否满足必须成为素材的条件
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 检查是否存在满足条件的「废品」同调怪兽
		and Duel.IsExistingMatchingCard(c37337327.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息，提示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行特殊召唤操作，从额外卡组特殊召唤「废品」同调怪兽
function c37337327.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测是否满足必须成为素材的条件
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「废品」同调怪兽
	local g=Duel.SelectMatchingCard(tp,c37337327.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 执行特殊召唤操作，将怪兽特殊召唤到场上
		if Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
			tc:CompleteProcedure()
		end
	end
end
