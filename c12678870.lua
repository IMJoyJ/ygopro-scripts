--聖霊獣騎 ペトルフィン
-- 效果：
-- 「灵兽使」怪兽＋「精灵兽」怪兽
-- 把自己场上的上记的卡除外的场合才能特殊召唤。
-- ①：场上的这张卡不会被效果破坏。
-- ②：自己·对方回合，让这张卡回到额外卡组，以自己的除外状态的1只「灵兽使」怪兽和1只「精灵兽」怪兽为对象才能发动。那些怪兽守备表示特殊召唤。
function c12678870.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续，素材为「灵兽使」怪兽和「精灵兽」怪兽各1只。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x10b5),aux.FilterBoolFunction(Card.IsFusionSetCard,0x20b5),true)
	-- 添加接触融合特殊召唤手续：将自己场上的融合素材怪兽除外作为特殊召唤方式。
	aux.AddContactFusionProcedure(c,Card.IsAbleToRemoveAsCost,LOCATION_MZONE,0,Duel.Remove,POS_FACEUP,REASON_COST)
	-- 把自己场上的上记的卡除外的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：场上的这张卡不会被效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ②：自己·对方回合，让这张卡回到额外卡组，以自己的除外状态的1只「灵兽使」怪兽和1只「精灵兽」怪兽为对象才能发动。那些怪兽守备表示特殊召唤。
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
-- 发动代价函数：确认这张卡可作为代价返回额外卡组，并支付将这张卡返回额外卡组的代价。
function c12678870.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToExtraAsCost() end
	-- 将这张卡返回额外卡组（顶端）作为发动代价。
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKTOP,REASON_COST)
end
-- 定义「灵兽使」怪兽的选择条件：表侧表示、属于「灵兽使」字段、可守备表示特殊召唤，且除外区还存在符合条件的「精灵兽」怪兽。
function c12678870.filter1(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x10b5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 追加确认除外区存在至少1只符合条件的「精灵兽」怪兽，以保证能选择完整的一组目标。
		and Duel.IsExistingTarget(c12678870.filter2,tp,LOCATION_REMOVED,0,1,c,e,tp)
end
-- 定义「精灵兽」怪兽的选择条件：表侧表示、属于「精灵兽」字段、可守备表示特殊召唤。
function c12678870.filter2(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x20b5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 目标判定：确认不处于青眼精灵龙限制效果下，自己可用怪兽区数量大于1，且除外区存在一组符合条件的「灵兽使」和「精灵兽」怪兽。
function c12678870.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 确认自己场上至少有2个可用怪兽区域，以便特殊召唤2只怪兽。
		and Duel.GetMZoneCount(tp,e:GetHandler())>1
		-- 确认除外区存在至少1只符合条件的「灵兽使」怪兽，且通过其追加条件也确认了「精灵兽」目标存在。
		and Duel.IsExistingTarget(c12678870.filter1,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 给玩家显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1只除外状态的「灵兽使」怪兽作为效果对象并加入连锁。
	local g1=Duel.SelectTarget(tp,c12678870.filter1,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 给玩家显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1只除外状态的「精灵兽」怪兽作为效果对象并加入连锁，排除已选的「灵兽使」怪兽。
	local g2=Duel.SelectTarget(tp,c12678870.filter2,tp,LOCATION_REMOVED,0,1,1,g1:GetFirst(),e,tp)
	g1:Merge(g2)
	-- 设置操作信息：本次效果将特殊召唤这2只对象怪兽，数量为2。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,2,0,0)
end
-- 效果处理：根据可用怪兽区域数量及青眼精灵龙限制，将对象怪兽守备表示特殊召唤；若区域不足，则选择可召唤的数量，其余送去墓地。
function c12678870.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己当前可用的主要怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取连锁对象卡组，并过滤出仍与效果相关的卡（对象仍存在于除外区等）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()==0 then return end
	if g:GetCount()<=ft then
		-- 将2只对象怪兽全部守备表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	else
		-- 给玩家显示“请选择要特殊召唤的卡”的提示信息（用于区域不足时选择召唤哪几只）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,ft,ft,nil)
		-- 将选中的怪兽守备表示特殊召唤。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		g:Sub(sg)
		-- 将因区域不足而未能特殊召唤的剩余怪兽送去墓地。
		Duel.SendtoGrave(g,REASON_RULE)
	end
end
