--剣闘獣アンダバタエ
-- 效果：
-- 「剑斗兽 奥古斯都」＋「剑斗兽」怪兽×2
-- 让自己场上的上记卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）。
-- ①：这张卡用上记的方法特殊召唤成功的场合才能发动。从额外卡组把1只7星以下的「剑斗兽」融合怪兽无视召唤条件特殊召唤。
-- ②：这张卡进行战斗的战斗阶段结束时让这张卡回到持有者的额外卡组才能发动。从卡组把2只「剑斗兽」怪兽特殊召唤。
function c3779662.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为7573135的怪兽和2个满足过滤条件的「剑斗兽」怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,7573135,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1019),2,true,true)
	-- 添加接触融合特殊召唤规则，通过将场上符合条件的卡送回卡组来特殊召唤此卡
	aux.AddContactFusionProcedure(c,c3779662.cfilter,LOCATION_ONFIELD,0,aux.ContactFusionSendToDeck(c)):SetValue(SUMMON_VALUE_SELF)
	-- 「剑斗兽 奥古斯都」＋「剑斗兽」怪兽×2让自己场上的上记卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c3779662.splimit)
	c:RegisterEffect(e1)
	-- ①：这张卡用上记的方法特殊召唤成功的场合才能发动。从额外卡组把1只7星以下的「剑斗兽」融合怪兽无视召唤条件特殊召唤
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
	-- ②：这张卡进行战斗的战斗阶段结束时让这张卡回到持有者的额外卡组才能发动。从卡组把2只「剑斗兽」怪兽特殊召唤
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
-- 限制此卡不能从额外卡组特殊召唤，只能通过接触融合方式特殊召唤
function c3779662.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
-- 接触融合的素材过滤函数，筛选「剑斗兽 奥古斯都」或「剑斗兽」怪兽且能送回卡组作为召唤代价
function c3779662.cfilter(c)
	return (c:IsFusionCode(7573135) or c:IsFusionSetCard(0x1019) and c:IsType(TYPE_MONSTER))
		and c:IsAbleToDeckOrExtraAsCost()
end
-- 效果发动条件，判断此卡是否通过接触融合方式特殊召唤成功
function c3779662.espcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 筛选满足条件的「剑斗兽」融合怪兽，等级不超过7，可特殊召唤且有召唤空间
function c3779662.espfilter(c,e,tp)
	return c:IsSetCard(0x1019) and c:IsType(TYPE_FUSION) and c:IsLevelBelow(7)
		-- 判断目标融合怪兽是否有足够的召唤空间
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 设置连锁操作信息，表示将从额外卡组特殊召唤1只融合怪兽
function c3779662.esptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测场上是否存在满足条件的融合怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c3779662.espfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将从额外卡组特殊召唤1只融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 发动效果时选择并特殊召唤1只融合怪兽
function c3779662.espop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足条件的融合怪兽
	local g=Duel.SelectMatchingCard(tp,c3779662.espfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的融合怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
-- 判断此卡是否参与过战斗
function c3779662.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 发动效果时将此卡送回卡组作为召唤代价
function c3779662.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtraAsCost() end
	-- 将此卡送回卡组
	Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_COST)
end
-- 筛选满足条件的「剑斗兽」怪兽，可特殊召唤
function c3779662.spfilter(c,e,tp)
	return c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置连锁操作信息，表示将从卡组特殊召唤2只怪兽
function c3779662.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家场上可用的召唤空间数量
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if e:GetHandler():GetSequence()<5 then ft=ft+1 end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return ft>1 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 检测场上是否存在至少2只满足条件的「剑斗兽」怪兽
			and Duel.IsExistingMatchingCard(c3779662.spfilter,tp,LOCATION_DECK,0,2,nil,e,tp)
	end
	-- 设置连锁操作信息，表示将从卡组特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 发动效果时选择并特殊召唤2只「剑斗兽」怪兽
function c3779662.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 判断玩家场上是否至少有2个召唤空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取卡组中所有满足条件的「剑斗兽」怪兽
	local g=Duel.GetMatchingGroup(c3779662.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()>=2 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,2,2,nil)
		local tc=sg:GetFirst()
		-- 将第一只选中的怪兽特殊召唤到场上
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
		tc=sg:GetNext()
		-- 将第二只选中的怪兽特殊召唤到场上
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
		-- 完成一次特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
