--剣闘獣アンダバタエ
-- 效果：
-- 「剑斗兽 奥古斯都」＋「剑斗兽」怪兽×2
-- 让自己场上的上记卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）。
-- ①：这张卡用上记的方法特殊召唤成功的场合才能发动。从额外卡组把1只7星以下的「剑斗兽」融合怪兽无视召唤条件特殊召唤。
-- ②：这张卡进行战斗的战斗阶段结束时让这张卡回到持有者的额外卡组才能发动。从卡组把2只「剑斗兽」怪兽特殊召唤。
function c3779662.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡注册融合召唤手续：融合素材为1只「剑斗兽 奥古斯都」和2只「剑斗兽」怪兽。
	aux.AddFusionProcCodeFun(c,7573135,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1019),2,true,true)
	-- 为这张卡添加接触融合手续：以自己场上满足cfilter的怪兽为素材，通过将它们送回持有者卡组来特殊召唤（无需「融合」），并设定该召唤方式为自身效果/条件（SUMMON_VALUE_SELF）。
	aux.AddContactFusionProcedure(c,c3779662.cfilter,LOCATION_ONFIELD,0,aux.ContactFusionSendToDeck(c)):SetValue(SUMMON_VALUE_SELF)
	-- 让自己场上的上记卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c3779662.splimit)
	c:RegisterEffect(e1)
	-- ①：这张卡用上记的方法特殊召唤成功的场合才能发动。从额外卡组把1只7星以下的「剑斗兽」融合怪兽无视召唤条件特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(3779662,4))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c3779662.espcon)
	e3:SetTarget(c3779662.esptg)
	e3:SetOperation(c3779662.espop)
	c:RegisterEffect(e3)
	-- ②：这张卡进行战斗的战斗阶段结束时让这张卡回到持有者的额外卡组才能发动。从卡组把2只「剑斗兽」怪兽特殊召唤。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(3779662,5))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(c3779662.spcon)
	e6:SetCost(c3779662.spcost)
	e6:SetTarget(c3779662.sptg)
	e6:SetOperation(c3779662.spop)
	c:RegisterEffect(e6)
end
-- 特殊召唤条件判定：仅当这张卡位于额外卡组时才允许被特殊召唤，防止从墓地、除外等区域特殊召唤。
function c3779662.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
-- 接触融合素材条件：素材为「剑斗兽 奥古斯都」或「剑斗兽」怪兽，且该素材可作为代价送回卡组/额外卡组。
function c3779662.cfilter(c)
	return (c:IsFusionCode(7573135) or c:IsFusionSetCard(0x1019) and c:IsType(TYPE_MONSTER))
		and c:IsAbleToDeckOrExtraAsCost()
end
-- ①效果的发动条件：这张卡是以自身记载的接触融合方式特殊召唤成功的（召唤类型为特殊召唤+自身效果值SUMMON_VALUE_SELF）。
function c3779662.espcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 选择对象的过滤条件：额外卡组中7星以下、属于「剑斗兽」的融合怪兽，且能被当前效果无视召唤条件特殊召唤，并有额外的额外怪兽区空格可特殊召唤。
function c3779662.espfilter(c,e,tp)
	return c:IsSetCard(0x1019) and c:IsType(TYPE_FUSION) and c:IsLevelBelow(7)
		-- 额外判定：目标融合怪兽可被当前效果特殊召唤（无视召唤条件），且从额外卡组出场时有充足的额外怪兽区空格。
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ①效果发动时的目标检查：确认额外卡组中存在至少1只符合条件的「剑斗兽」融合怪兽，并登记效果类别为特殊召唤。
function c3779662.esptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在至少1只满足 espfilter 条件的「剑斗兽」融合怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c3779662.espfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：本效果将从额外卡组特殊召唤1只怪兽，供系统进行连锁/时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果处理：让玩家从符合条件的额外卡组融合怪兽中选择1只，无视召唤条件特殊召唤。
function c3779662.espop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从额外卡组中选择1只满足 espfilter 的「剑斗兽」融合怪兽。
	local g=Duel.SelectMatchingCard(tp,c3779662.espfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤（nocheck=true 忽略召唤条件，但保留苏生限制检查）。
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：这张卡在本次战斗阶段中进行过战斗（有战斗记录）。
function c3779662.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- ②效果的代价：将这张卡自身送回持有者的额外卡组。
function c3779662.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtraAsCost() end
	-- 执行代价：将此卡送回持有者的额外卡组（额外卡组怪兽自动回到额外卡组）。
	Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_COST)
end
-- 选择对象的过滤条件：卡组中的「剑斗兽」怪兽，且能够被当前效果正常特殊召唤。
function c3779662.spfilter(c,e,tp)
	return c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动条件：有至少2个可用主要怪兽区空格（本卡在主要怪兽区时其弹回可多提供1格）、玩家tp不受【青眼精灵龙】的同时特殊召唤限制，且卡组中存在至少2只符合条件的「剑斗兽」怪兽；同时登记特殊召唤2只的操作信息。
function c3779662.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 取得当前玩家tp主要怪兽区可用的空格数。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if e:GetHandler():GetSequence()<5 then ft=ft+1 end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return ft>1 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 检查卡组中是否存在至少2只满足 spfilter 的「剑斗兽」怪兽。
			and Duel.IsExistingMatchingCard(c3779662.spfilter,tp,LOCATION_DECK,0,2,nil,e,tp)
	end
	-- 设置操作信息：本效果将从卡组特殊召唤2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- ②效果处理：再次确认青眼精灵龙效果未适用且主要怪兽区有至少2个空格；从卡组选出2只「剑斗兽」怪兽，依次特殊召唤，并给每只特殊召唤的怪兽注册一个以自身原始卡号为编号的独立标志。
function c3779662.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 若当前主要怪兽区空格不足2个，则不进行特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 取得卡组中所有满足 spfilter 的「剑斗兽」怪兽集合。
	local g=Duel.GetMatchingGroup(c3779662.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()>=2 then
		-- 显示提示：请选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,2,2,nil)
		local tc=sg:GetFirst()
		-- 将选择的第一只怪兽以表侧表示加入特殊召唤处理（暂存，待统一完成）。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
		tc=sg:GetNext()
		-- 将选择的第二只怪兽以表侧表示加入特殊召唤处理（暂存，待统一完成）。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
		-- 完成连锁的特殊召唤步骤，正式特殊召唤并触发特殊召唤成功时点。
		Duel.SpecialSummonComplete()
	end
end
