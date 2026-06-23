--三段腹ナイト
-- 效果：
-- 超量素材的这张卡为让超量怪兽把效果发动而被取除送去墓地的场合，可以从手卡把1只3星以下的怪兽特殊召唤。
function c32696942.initial_effect(c)
	-- 创建一个诱发选发效果，用于在特定条件下特殊召唤怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32696942,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c32696942.spcon)
	e1:SetTarget(c32696942.sptg)
	e1:SetOperation(c32696942.spop)
	c:RegisterEffect(e1)
end
-- 效果发动的条件：这张卡因支付代价而送去墓地，并且是超量怪兽的效果发动导致的，且之前在超量素材区
function c32696942.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
		and c:IsPreviousLocation(LOCATION_OVERLAY)
end
-- 过滤函数，用于筛选手卡中等级3以下且可以特殊召唤的怪兽
function c32696942.filter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的发动宣言阶段，检查是否满足特殊召唤的条件
function c32696942.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c32696942.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理时的操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果的处理阶段，执行特殊召唤操作
function c32696942.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查玩家场上是否有足够的怪兽区域，如果没有则返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示信息，提示选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c32696942.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
