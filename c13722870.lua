--黒炎の騎士－ブラック・フレア・ナイト－
-- 效果：
-- 「黑魔术师」＋「炎之剑士」
-- ①：这张卡的战斗发生的对自己的战斗伤害变成0。
-- ②：这张卡被战斗破坏送去墓地的场合发动。从手卡·卡组把1只「幻影之骑士」特殊召唤。
function c13722870.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为46986414和45231177的2只怪兽为融合素材
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
-- 过滤函数，用于检索满足条件的「幻影之骑士」怪兽
function c13722870.spfilter(c,e,tp)
	return c:IsCode(49217579) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 判断效果发动条件，确认此卡是否因战斗破坏而送去墓地
function c13722870.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 设置效果目标，确定将要特殊召唤的怪兽
function c13722870.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，指定将要特殊召唤的怪兽来源为手牌或卡组
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理函数，执行特殊召唤操作
function c13722870.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够空间进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示消息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的「幻影之骑士」怪兽
	local g=Duel.SelectMatchingCard(tp,c13722870.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		g:GetFirst():CompleteProcedure()
	end
end
