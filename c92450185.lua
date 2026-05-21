--リミッター・ブレイク
-- 效果：
-- ①：这张卡被送去墓地的场合发动。从自己的手卡·卡组·墓地选1只「高速战士」特殊召唤。
function c92450185.initial_effect(c)
	-- ①：这张卡被送去墓地的场合发动。从自己的手卡·卡组·墓地选1只「高速战士」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92450185,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetTarget(c92450185.thtg)
	e1:SetOperation(c92450185.thop)
	c:RegisterEffect(e1)
end
-- 效果①的发动准备，作为必发效果在chk==0时直接返回true，并设置特殊召唤的操作信息
function c92450185.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置特殊召唤的操作信息，表示将从手卡、卡组或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
end
-- 过滤条件：卡名是「高速战士」（卡号9365703）且可以被特殊召唤的怪兽
function c92450185.spfilter(c,e,tp)
	return c:IsCode(9365703) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的运行空间，在怪兽区域有空位时，从手卡、卡组或墓地选择1只「高速战士」特殊召唤
function c92450185.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的主要怪兽区域是否有可用的空位，若无空位则直接结束效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示信息，要求选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手卡、卡组、墓地中选择1只满足条件的「高速战士」（适用王家长眠之谷的过滤效果）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c92450185.spfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
