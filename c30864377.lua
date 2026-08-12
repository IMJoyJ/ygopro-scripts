--剣闘獣総監エーディトル
-- 效果：
-- 5星以上的「剑斗兽」怪兽×2
-- 让自己场上的上记卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）。这张卡不能作为融合素材。
-- ①：1回合1次，可以发动。从额外卡组把「剑斗兽总监 主斗」以外的1只「剑斗兽」融合怪兽无视召唤条件特殊召唤。
-- ②：自己的「剑斗兽」怪兽进行战斗的战斗阶段结束时让那1只怪兽回到持有者的卡组·额外卡组才能发动。从卡组把1只「剑斗兽」怪兽特殊召唤。
function c30864377.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用2个满足条件的「剑斗兽」怪兽作为融合素材
	aux.AddFusionProcFunRep(c,c30864377.matfilter,2,true)
	-- 添加接触融合特殊召唤规则，通过将自己场上的符合条件的怪兽送回卡组来特殊召唤此卡
	aux.AddContactFusionProcedure(c,Card.IsAbleToDeckOrExtraAsCost,LOCATION_MZONE,0,aux.ContactFusionSendToDeck(c))
	-- 这张卡不能从额外卡组特殊召唤（需要满足接触融合条件）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c30864377.splimit)
	c:RegisterEffect(e1)
	-- 这张卡不能作为融合素材
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ①：1回合1次，可以发动。从额外卡组把「剑斗兽总监 主斗」以外的1只「剑斗兽」融合怪兽无视召唤条件特殊召唤
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(30864377,3))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c30864377.esptg)
	e4:SetOperation(c30864377.espop)
	c:RegisterEffect(e4)
	-- ②：自己的「剑斗兽」怪兽进行战斗的战斗阶段结束时让那1只怪兽回到持有者的卡组·额外卡组才能发动。从卡组把1只「剑斗兽」怪兽特殊召唤
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(30864377,4))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1)
	e6:SetCost(c30864377.spcost)
	e6:SetTarget(c30864377.sptg)
	e6:SetOperation(c30864377.spop)
	c:RegisterEffect(e6)
end
-- 融合素材过滤函数，筛选5星以上且为「剑斗兽」的怪兽
function c30864377.matfilter(c)
	return c:IsLevelAbove(5) and c:IsFusionSetCard(0x1019)
end
-- 特殊召唤条件函数，确保此卡不能从额外卡组特殊召唤
function c30864377.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
-- 额外卡组特殊召唤过滤函数，筛选「剑斗兽」融合怪兽且满足特殊召唤条件
function c30864377.espfilter(c,e,tp)
	return c:IsSetCard(0x1019) and c:IsType(TYPE_FUSION) and not c:IsCode(30864377)
		-- 额外卡组特殊召唤过滤函数，确保有足够召唤位置
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果发动时检查是否有满足条件的融合怪兽可特殊召唤
function c30864377.esptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时检查是否有满足条件的融合怪兽可特殊召唤
	if chk==0 then return Duel.IsExistingMatchingCard(c30864377.espfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果发动处理，选择并特殊召唤1只融合怪兽
function c30864377.espop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的融合怪兽
	local g=Duel.SelectMatchingCard(tp,c30864377.espfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的融合怪兽特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
-- 战斗后特殊召唤的素材过滤函数，筛选已参与战斗且可送回卡组的「剑斗兽」怪兽
function c30864377.spcfilter(c,ft)
	return c:IsFaceup() and c:IsSetCard(0x1019) and c:GetBattledGroupCount()>0
		and c:IsAbleToDeckOrExtraAsCost() and (ft>0 or c:GetSequence()<5)
end
-- 效果发动时处理战斗后特殊召唤的素材，将符合条件的怪兽送回卡组
function c30864377.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 效果发动时检查是否有满足条件的怪兽可作为素材送回卡组
	if chk==0 then return ft>-1 and Duel.IsExistingMatchingCard(c30864377.spcfilter,tp,LOCATION_MZONE,0,1,nil,ft) end
	-- 提示玩家选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择要送回卡组的怪兽
	local g=Duel.SelectMatchingCard(tp,c30864377.spcfilter,tp,LOCATION_MZONE,0,1,1,nil,ft)
	-- 确认对方玩家看到被选中的怪兽
	Duel.ConfirmCards(1-tp,g)
	-- 将选中的怪兽送回卡组
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 卡组特殊召唤过滤函数，筛选「剑斗兽」怪兽
function c30864377.spfilter(c,e,tp)
	return c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时检查是否有满足条件的「剑斗兽」怪兽可特殊召唤
function c30864377.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时检查是否有满足条件的「剑斗兽」怪兽可特殊召唤
	if chk==0 then return Duel.IsExistingMatchingCard(c30864377.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果发动处理，选择并特殊召唤1只「剑斗兽」怪兽
function c30864377.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「剑斗兽」怪兽
	local g=Duel.SelectMatchingCard(tp,c30864377.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽特殊召唤
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
