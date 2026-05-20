--マツボックル
-- 效果：
-- 这张卡被「小矮人橡子」的效果送去墓地的场合，这张卡可以从墓地特殊召唤。
function c67445676.initial_effect(c)
	-- 这张卡被「小矮人橡子」的效果送去墓地的场合，这张卡可以从墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67445676,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c67445676.spcon)
	e1:SetTarget(c67445676.sptg)
	e1:SetOperation(c67445676.spop)
	c:RegisterEffect(e1)
end
-- 检查发动条件：这张卡是否因效果送去墓地，且该效果的来源卡片是「小矮人橡子」
function c67445676.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT) and re and re:GetHandler():IsCode(21051977)
end
-- 检查特殊召唤的目标和场地空格是否满足条件
function c67445676.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动时己方主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，声明此效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若此卡仍与效果相关联，则将此卡特殊召唤
function c67445676.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡在己方场上以表侧表示特殊召唤
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
