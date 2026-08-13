--水晶機巧－ハリファイバー
-- 效果：
-- 包含调整的怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤成功的场合才能发动。从手卡·卡组把1只3星以下的调整守备表示特殊召唤。这个效果特殊召唤的怪兽在这个回合不能把效果发动。
-- ②：对方的主要阶段以及战斗阶段把场上的这张卡除外才能发动。从额外卡组把1只同调怪兽调整当作同调召唤作特殊召唤。
function c50588353.initial_effect(c)
	-- 为这张卡添加连接召唤手续：需要2只怪兽作为连接素材，并且素材中必须包含至少1只调整怪兽（lcheck用于检查）。
	aux.AddLinkProcedure(c,nil,2,2,c50588353.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤成功的场合才能发动。从手卡·卡组把1只3星以下的调整守备表示特殊召唤。这个效果特殊召唤的怪兽在这个回合不能把效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50588353,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,50588353)
	e1:SetCondition(c50588353.hspcon)
	e1:SetTarget(c50588353.hsptg)
	e1:SetOperation(c50588353.hspop)
	c:RegisterEffect(e1)
	-- ②：对方的主要阶段以及战斗阶段把场上的这张卡除外才能发动。从额外卡组把1只同调怪兽调整当作同调召唤作特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50588353,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,50588354)
	e2:SetCondition(c50588353.spcon)
	-- 设置②效果的发动代价：将场上的这张卡除外（aux.bfgcost实现除外自身作为cost）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c50588353.sptg)
	e2:SetOperation(c50588353.spop)
	c:RegisterEffect(e2)
end
-- 检查所选的连接素材组g中是否至少包含1只调整怪兽，以满足连接素材“包含调整的怪兽2只”的要求。
function c50588353.lcheck(g,lc)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_TUNER)
end
-- ①效果的发动条件：这张卡以连接召唤的方式成功特殊召唤时才能发动。
function c50588353.hspcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 筛选从手卡·卡组特殊召唤的怪兽：必须是3星以下的调整怪兽，且能以表侧守备表示特殊召唤。
function c50588353.hspfilter(c,e,tp)
	return c:IsType(TYPE_TUNER) and c:IsLevelBelow(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①效果的发动合法性检查：自己场上有可用的主要怪兽区域，且手卡·卡组中存在满足hspfilter条件的调整怪兽。
function c50588353.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：自己场上是否存在可用的主要怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且手卡·卡组中是否至少存在1只满足hspfilter条件的调整怪兽（若满足则效果可发动）。
		and Duel.IsExistingMatchingCard(c50588353.hspfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记操作信息：该效果将要把来自手卡·卡组的1只怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 处理①效果：从手卡·卡组选择1只3星以下的调整怪兽，以表侧守备表示特殊召唤，并给该怪兽加上本回合不能发动效果的制约。
function c50588353.hspop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若自己场上没有可用怪兽区域空位，则直接中止效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡·卡组中选出1张满足hspfilter条件的怪兽，结果存入g。
	local g=Duel.SelectMatchingCard(tp,c50588353.hspfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若选到了怪兽，则将其以表侧守备表示进行特殊召唤步骤（SpecialSummonStep）。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 这个效果特殊召唤的怪兽在这个回合不能把效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤步骤，触发特殊召唤成功后的时点处理。
	Duel.SpecialSummonComplete()
end
-- ②效果的发动条件：当前为对方回合，且处于对方的主要阶段1、主要阶段2或战斗阶段。
function c50588353.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前回合阶段并存入局部变量ph。
	local ph=Duel.GetCurrentPhase()
	-- 判断当前回合玩家不是自己，即处于对方回合。
	return Duel.GetTurnPlayer()~=tp
		and (ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2)
end
-- 筛选额外卡组的同调调整怪兽：必须是同调怪兽且为调整，能够以同调召唤的方式特殊召唤，并且除外这张卡后有足够的区域空格。
function c50588353.spfilter(c,e,tp,mc)
	return c:IsType(TYPE_SYNCHRO) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		-- 且将这张卡除外后，额外卡组怪兽有足够的主要怪兽区域/额外怪兽区域空格可供特殊召唤。
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- ②效果的发动合法性检查：满足“必须作为同调素材”的相关检查，且额外卡组中存在满足spfilter条件的同调调整。
function c50588353.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：执行“必须作为同调素材”的检查（用于判断该特殊召唤是否合法）。
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 且额外卡组中是否存在至少1只满足spfilter条件的同调调整怪兽。
		and Duel.IsExistingMatchingCard(c50588353.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	-- 登记操作信息：该效果将要把来自额外卡组的1只怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 处理②效果：从额外卡组选择1只同调调整怪兽，视为同调召唤进行特殊召唤，并完成同调召唤手续。
function c50588353.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次进行“必须作为同调素材”的合法性检查，若不满足则中止处理。
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示（从额外卡组选择）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组中选出1张满足spfilter条件的同调调整，并取其作为tc。
	local tc=Duel.SelectMatchingCard(tp,c50588353.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil):GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 以同调召唤方式将选出的怪兽特殊召唤到自己场上，若特殊召唤成功则进入后续处理。
		if Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
			tc:CompleteProcedure()
		end
	end
end
