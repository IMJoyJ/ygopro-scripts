--黒炎の騎士－ブラック・フレア・ナイト－
-- 效果：
-- 「黑魔术师」＋「炎之剑士」
-- ①：这张卡的战斗发生的对自己的战斗伤害变成0。
-- ②：这张卡被战斗破坏送去墓地的场合发动。从手卡·卡组把1只「幻影之骑士」特殊召唤。
function c13722870.initial_effect(c)
	-- 记录这张卡的卡文上记载了「幻影之骑士」的卡名。
	aux.AddCodeList(c,49217579)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以「黑魔术师」和「炎之剑士」作为融合素材。
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
-- 过滤函数：判断卡片是否为「幻影之骑士」且可以无视召唤条件（但检查苏生限制）被特殊召唤。
function c13722870.spfilter(c,e,tp)
	return c:IsCode(49217579) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ②效果的发动条件判定：检查这张卡是否因战斗破坏而位于墓地。
function c13722870.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- ②效果的目标处理函数：因属于必发效果直接通过可行性检测，并申报从手卡或卡组特殊召唤1只怪兽的操作信息。
function c13722870.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：预计从自己的手卡或卡组把1只怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ②效果的效果处理函数：若自己怪兽区域有空位，从手卡或卡组选择1只「幻影之骑士」无视召唤条件特殊召唤并完成正规召唤手续。
function c13722870.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己怪兽区域是否没有可用空位，若没有则结束效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向自己发送选择提示，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡和卡组中选择1只「幻影之骑士」。
	local g=Duel.SelectMatchingCard(tp,c13722870.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「幻影之骑士」无视其召唤条件以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		g:GetFirst():CompleteProcedure()
	end
end
