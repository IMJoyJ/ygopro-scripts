--百鬼羅刹 冷血ミアンダ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从手卡把「百鬼罗刹 冷血米安德」以外的1只「哥布林」怪兽特殊召唤。
-- ②：这张卡在墓地存在的场合，自己主要阶段才能发动。场上1个超量素材取除，这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c64257161.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从手卡把「百鬼罗刹 冷血米安德」以外的1只「哥布林」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64257161,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,64257161)
	e1:SetTarget(c64257161.sptg)
	e1:SetOperation(c64257161.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡在墓地存在的场合，自己主要阶段才能发动。场上1个超量素材取除，这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(64257161,1))  --"这张卡特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,64257161+1)
	e3:SetTarget(c64257161.sptg2)
	e3:SetOperation(c64257161.spop2)
	c:RegisterEffect(e3)
end
-- 过滤条件：手卡中除「百鬼罗刹 冷血米安德」以外的「哥布林」怪兽
function c64257161.spfilter(c,e,tp)
	return c:IsSetCard(0xac) and not c:IsCode(64257161) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与效果处理信息注册
function c64257161.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域，以及手卡中是否存在满足条件的怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c64257161.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的特殊召唤效果处理
function c64257161.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c64257161.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动准备与效果处理信息注册
function c64257161.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否可以取除至少1个超量素材，以及自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理信息：特殊召唤墓地的这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的取除素材与特殊召唤效果处理
function c64257161.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取除场上1个超量素材，并检查这张卡是否仍与效果相关
	if Duel.RemoveOverlayCard(tp,1,1,1,1,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) then
		-- 尝试将这张卡以表侧表示特殊召唤到自己场上
		if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
			-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			c:RegisterEffect(e1,true)
		end
		-- 完成特殊召唤的后续处理
		Duel.SpecialSummonComplete()
	end
end
