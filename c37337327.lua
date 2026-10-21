--ジャンク・コネクター
-- 效果：
-- 包含调整1只以上的战士族·机械族的效果怪兽2只
-- ①：1回合1次，自己·对方的主要阶段以及战斗阶段才能发动。只用这张卡所连接区的怪兽为素材作同调召唤。
-- ②：连接召唤的这张卡被战斗或者对方的效果破坏送去墓地的场合才能发动。从额外卡组把1只「废品」同调怪兽当作同调召唤作特殊召唤。
function c37337327.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤手续：包含调整1只以上的战士族·机械族效果怪兽2只
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
-- 过滤条件：战士族或机械族的效果怪兽
function c37337327.mfilter(c)
	return c:IsLinkType(TYPE_EFFECT) and c:IsLinkRace(RACE_WARRIOR+RACE_MACHINE)
end
-- 素材检查：包含至少1只调整怪兽
function c37337327.lcheck(g,lc)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_TUNER)
end
-- 发动条件：自己·对方的主要阶段以及战斗阶段
function c37337327.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2
end
-- 过滤条件：能用指定的素材组进行同调召唤的怪兽
function c37337327.scfilter(c,mg)
	return c:IsSynchroSummonable(nil,mg)
end
-- 发动目标：额外卡组存在能用所连接区的怪兽为素材进行同调召唤的怪兽
function c37337327.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=e:GetHandler():GetLinkedGroup():Filter(Card.IsFaceup,nil)
		-- 判断额外卡组是否存在可以同调召唤的怪兽
		return Duel.IsExistingMatchingCard(c37337327.scfilter,tp,LOCATION_EXTRA,0,1,nil,mg)
	end
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：从额外卡组选1只怪兽，只用所连接区的怪兽为素材作同调召唤
function c37337327.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local mg=c:GetLinkedGroup():Filter(Card.IsFaceup,nil)
	-- 获取额外卡组中能以所连接区怪兽为素材同调召唤的怪兽
	local g=Duel.GetMatchingGroup(c37337327.scfilter,tp,LOCATION_EXTRA,0,nil,mg)
	if g:GetCount()>0 then
		-- 提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 以所连接区的怪兽为素材进行同调召唤
		Duel.SynchroSummon(tp,sg:GetFirst(),nil,mg)
	end
end
-- 发动条件：连接召唤的这张卡被战斗或者对方的效果破坏送去墓地
function c37337327.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤条件：额外卡组能当作同调召唤特殊召唤的「废品」同调怪兽
function c37337327.spfilter(c,e,tp)
	return c:IsSetCard(0x43) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		-- 检查额外卡组怪兽出场可用空格数
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 发动目标：额外卡组存在可以当作同调召唤特殊召唤的「废品」同调怪兽
function c37337327.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查必须作为同调素材的效果限制
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 判断额外卡组是否存在可以特殊召唤的「废品」同调怪兽
		and Duel.IsExistingMatchingCard(c37337327.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：从额外卡组把1只「废品」同调怪兽当作同调召唤特殊召唤
function c37337327.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查必须作为同调素材的效果限制
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只「废品」同调怪兽
	local g=Duel.SelectMatchingCard(tp,c37337327.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 以同调召唤方式表侧表示特殊召唤
		if Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
			tc:CompleteProcedure()
		end
	end
end
