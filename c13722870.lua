--黒炎の騎士－ブラック・フレア・ナイト－
-- 效果：
-- 「黑魔术师」＋「炎之剑士」
-- ①：这张卡的战斗发生的对自己的战斗伤害变成0。
-- ②：这张卡被战斗破坏送去墓地的场合发动。从手卡·卡组把1只「幻影之骑士」特殊召唤。
function c13722870.initial_effect(c)
	c:EnableReviveLimit()
	-- 为「黑炎之骑士」添加融合召唤手续：以「黑魔术师」（卡号46986414）和「炎之剑士」（卡号45231177）作为融合素材，允许使用融合素材代用等条件。
	aux.AddFusionProcCode2(c,46986414,45231177,true,true)
	-- ②：这张卡被战斗破坏送去墓地的场合发动。从手卡·卡组把1只「幻影之骑士」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13722870,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c13722870.spcon)
	e1:SetTarget(c13722870.sptg)
	e1:SetOperation(c13722870.spop)
	c:RegisterEffect(e1)
	-- ①：这张卡的战斗发生的对自己的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 定义特殊召唤候选卡的过滤函数：从手卡·卡组中筛选出卡号49217579的「幻影之骑士」，且该卡可以被当前效果特殊召唤（允许不检查召唤条件但需符合苏生限制）。
function c13722870.spfilter(c,e,tp)
	return c:IsCode(49217579) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果②的发动条件：这张卡存在于墓地，且被战斗破坏（破坏原因为REASON_BATTLE）。
function c13722870.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 效果②发动时的目标处理：在发动确认阶段（chk==0）直接允许发动；并设置操作信息，预告将从手卡·卡组特殊召唤1只怪兽。
function c13722870.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次连锁的操作信息：类别为特殊召唤，数量为1，从手卡·卡组区域特殊召唤，供相关效果进行检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果②的发动处理：若我方主要怪兽区有空位，则选择1只符合条件的「幻影之骑士」；从手卡·卡组将其以表侧攻击表示特殊召唤到我方场上，并补记其正规特殊召唤手续（满足苏生限制要求）。
function c13722870.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查我方主要怪兽区是否有可用空位；若没有空格，则不能进行特殊召唤，效果处理停止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示提示信息，要求我方玩家选择要特殊召唤的卡片（提示类型为特殊召唤选择）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从我方的手卡·卡组中选取1张满足spfilter条件的「幻影之骑士」作为特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c13722870.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选取的「幻影之骑士」以表侧攻击表示特殊召唤到我方场上（nocheck=true表示不检查召唤条件，nolimit=false表示仍需符合苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		g:GetFirst():CompleteProcedure()
	end
end
