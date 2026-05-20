--ギミック・パペット－ハンプティ・ダンプティ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功时才能发动。从手卡把1只「机关傀儡」怪兽特殊召唤。
function c8226374.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡召唤·特殊召唤成功时才能发动。从手卡把1只「机关傀儡」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8226374,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,8226374)
	e1:SetTarget(c8226374.sptg)
	e1:SetOperation(c8226374.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选手卡中可以特殊召唤的「机关傀儡」怪兽
function c8226374.filter(c,e,tp)
	return c:IsSetCard(0x1083) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的可行性检查：判断自己场上是否有空位且手卡中是否存在可特殊召唤的「机关傀儡」怪兽
function c8226374.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足过滤条件的「机关傀儡」怪兽
		and Duel.IsExistingMatchingCard(c8226374.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁的操作信息：表示该效果包含从手卡特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理的执行函数：从手卡选择1只「机关傀儡」怪兽并特殊召唤
function c8226374.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，检查自己场上是否仍有可用的怪兽区域空格，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足过滤条件的「机关傀儡」怪兽
	local g=Duel.SelectMatchingCard(tp,c8226374.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
