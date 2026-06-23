--聖霊獣騎 ペトルフィン
-- 效果：
-- 「灵兽使」怪兽＋「精灵兽」怪兽
-- 把自己场上的上记的卡除外的场合才能特殊召唤。
-- ①：场上的这张卡不会被效果破坏。
-- ②：自己·对方回合，让这张卡回到额外卡组，以自己的除外状态的1只「灵兽使」怪兽和1只「精灵兽」怪兽为对象才能发动。那些怪兽守备表示特殊召唤。
function c12678870.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用一张「灵兽使」怪兽和一张「精灵兽」怪兽作为融合素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x10b5),aux.FilterBoolFunction(Card.IsFusionSetCard,0x20b5),true)
	-- 添加接触融合的特殊召唤规则，需要将自己场上的1只怪兽除外作为召唤代价
	aux.AddContactFusionProcedure(c,Card.IsAbleToRemoveAsCost,LOCATION_MZONE,0,Duel.Remove,POS_FACEUP,REASON_COST)
	-- ①：场上的这张卡不会被效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，让这张卡回到额外卡组，以自己的除外状态的1只「灵兽使」怪兽和1只「精灵兽」怪兽为对象才能发动。那些怪兽守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 发动时将自身送入额外卡组作为召唤代价
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMING_END_PHASE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(c12678870.spcost)
	e4:SetTarget(c12678870.sptg)
	e4:SetOperation(c12678870.spop)
	c:RegisterEffect(e4)
end
-- 设置特殊召唤的费用处理函数
function c12678870.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToExtraAsCost() end
	-- 将自身送入卡组顶端作为召唤的费用
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKTOP,REASON_COST)
end
-- 筛选符合条件的「灵兽使」怪兽作为特殊召唤目标
function c12678870.filter1(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x10b5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 确保存在符合条件的「精灵兽」怪兽作为特殊召唤目标
		and Duel.IsExistingTarget(c12678870.filter2,tp,LOCATION_REMOVED,0,1,c,e,tp)
end
-- 筛选符合条件的「精灵兽」怪兽作为特殊召唤目标
function c12678870.filter2(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x20b5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置特殊召唤的效果处理函数
function c12678870.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中：禁止该玩家同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 判断自己场上是否有足够的怪兽区域
		and Duel.GetMZoneCount(tp,e:GetHandler())>1
		-- 确保场上存在符合条件的「灵兽使」怪兽作为特殊召唤目标
		and Duel.IsExistingTarget(c12678870.filter1,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择符合条件的「灵兽使」怪兽作为特殊召唤目标
	local g1=Duel.SelectTarget(tp,c12678870.filter1,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择符合条件的「精灵兽」怪兽作为特殊召唤目标
	local g2=Duel.SelectTarget(tp,c12678870.filter2,tp,LOCATION_REMOVED,0,1,1,g1:GetFirst(),e,tp)
	g1:Merge(g2)
	-- 设置效果处理信息，确定将要特殊召唤的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,2,0,0)
end
-- 处理特殊召唤效果的执行函数
function c12678870.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中：禁止该玩家同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取连锁中指定的目标卡片组，并筛选出与效果相关的卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()==0 then return end
	if g:GetCount()<=ft then
		-- 将符合条件的怪兽以守备表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	else
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,ft,ft,nil)
		-- 将选定的怪兽以守备表示特殊召唤到场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		g:Sub(sg)
		-- 将未被特殊召唤的怪兽送入墓地
		Duel.SendtoGrave(g,REASON_RULE)
	end
end
