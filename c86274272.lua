--聖霊獣騎 アペライオ
-- 效果：
-- 「灵兽使」怪兽＋「精灵兽」怪兽
-- 把自己场上的上记的卡除外的场合才能特殊召唤。
-- ①：这张卡攻击的场合，直到伤害步骤结束时不受其他卡的效果影响。
-- ②：自己·对方回合，让这张卡回到额外卡组，以自己的除外状态的1只「灵兽使」怪兽和1只「精灵兽」怪兽为对象才能发动。那些怪兽守备表示特殊召唤。
function c86274272.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合素材为1只「灵兽使」怪兽和1只「精灵兽」怪兽
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x10b5),aux.FilterBoolFunction(Card.IsFusionSetCard,0x20b5),true)
	-- 设置接触融合的特殊召唤手续：将自己场上的素材怪兽正面表示除外
	aux.AddContactFusionProcedure(c,Card.IsAbleToRemoveAsCost,LOCATION_MZONE,0,Duel.Remove,POS_FACEUP,REASON_COST)
	-- 把自己场上的上记的卡除外的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：这张卡攻击的场合，直到伤害步骤结束时不受其他卡的效果影响。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetCondition(c86274272.immcon)
	e3:SetValue(c86274272.efilter)
	c:RegisterEffect(e3)
	-- ②：自己·对方回合，让这张卡回到额外卡组，以自己的除外状态的1只「灵兽使」怪兽和1只「精灵兽」怪兽为对象才能发动。那些怪兽守备表示特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMING_END_PHASE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(c86274272.spcost)
	e4:SetTarget(c86274272.sptg)
	e4:SetOperation(c86274272.spop)
	c:RegisterEffect(e4)
end
-- 定义免疫效果的生效条件：这张卡进行攻击的场合
function c86274272.immcon(e)
	-- 判定当前攻击的怪兽是否为这张卡自身
	return Duel.GetAttacker()==e:GetHandler()
end
-- 定义免疫效果的过滤条件：不受除这张卡以外的其他卡片效果影响
function c86274272.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 定义效果②的发动代价：将自身回到额外卡组
function c86274272.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToExtraAsCost() end
	-- 作为发动代价，将自身送回额外卡组
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKTOP,REASON_COST)
end
-- 过滤除外状态、可守备表示特殊召唤的正面表示「灵兽使」怪兽，且此时必须存在可成为对象的「精灵兽」怪兽
function c86274272.filter1(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x10b5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 判定除外状态是否存在另一只满足条件的「精灵兽」怪兽（排除当前选择的「灵兽使」怪兽）
		and Duel.IsExistingTarget(c86274272.filter2,tp,LOCATION_REMOVED,0,1,c,e,tp)
end
-- 过滤除外状态、可守备表示特殊召唤的正面表示「精灵兽」怪兽
function c86274272.filter2(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x20b5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果②的发动准备与目标选择：检测是否满足特殊召唤2只怪兽的场地和效果限制条件
function c86274272.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 判定在这张卡离开场上后，自己场上是否有2个以上的空余怪兽区域
		and Duel.GetMZoneCount(tp,e:GetHandler())>1
		-- 判定除外状态是否存在满足特殊召唤条件的「灵兽使」和「精灵兽」怪兽各1只
		and Duel.IsExistingTarget(c86274272.filter1,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择除外状态的1只「灵兽使」怪兽作为效果对象
	local g1=Duel.SelectTarget(tp,c86274272.filter1,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择除外状态的1只「精灵兽」怪兽作为效果对象（排除已选择的「灵兽使」怪兽）
	local g2=Duel.SelectTarget(tp,c86274272.filter2,tp,LOCATION_REMOVED,0,1,1,g1:GetFirst(),e,tp)
	g1:Merge(g2)
	-- 设置特殊召唤2只怪兽的效果处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,2,0,0)
end
-- 效果②的效果处理：将作为对象的2只怪兽在自己场上守备表示特殊召唤（若格子不足或受限则尽可能特殊召唤）
function c86274272.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取当前连锁中仍与效果相关的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()==0 then return end
	if g:GetCount()<=ft then
		-- 将对象怪兽守备表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	else
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,ft,ft,nil)
		-- 将选择的符合数量限制的怪兽守备表示特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		g:Sub(sg)
		-- 将因格子不足无法特殊召唤的其余对象怪兽因规则送去墓地
		Duel.SendtoGrave(g,REASON_RULE)
	end
end
