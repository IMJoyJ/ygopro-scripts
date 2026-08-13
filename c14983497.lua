--霞の谷の幼怪鳥
-- 效果：
-- ①：这张卡从手卡送去墓地时才能发动。这张卡特殊召唤。
function c14983497.initial_effect(c)
	-- ①：这张卡从手卡送去墓地时才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14983497,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c14983497.spcon)
	e1:SetTarget(c14983497.sptg)
	e1:SetOperation(c14983497.spop)
	c:RegisterEffect(e1)
end
-- 发动条件：这张卡之前所在的位置为手卡，即必须是从手卡被送去墓地时才能发动。
function c14983497.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 发动时的合法性检查：在发动时确认自己场上主要怪兽区有空位，且这张卡能够被特殊召唤。
function c14983497.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否存在可用的空格（特殊召唤所需）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，声明本次连锁将特殊召唤这张卡：对象为这张卡，数量为1，持有者和位置未知则填0。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理时的操作：先确认这张卡仍与当前效果保持联系（没有被重置或离场），然后将其特殊召唤。
function c14983497.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 执行特殊召唤：将这张卡以表侧表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
