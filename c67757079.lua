--キング・オブ・ビースト
-- 效果：
-- 可以把1只自己场上表侧表示存在的「毛扎」解放发动。这张卡从手卡或者墓地特殊召唤。「毛兽之王」在场上只能有1只表侧表示存在。
function c67757079.initial_effect(c)
	c:SetUniqueOnField(1,1,67757079)
	-- 可以把1只自己场上表侧表示存在的「毛扎」解放发动。这张卡从手卡或者墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67757079,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCost(c67757079.spcost)
	e1:SetTarget(c67757079.sptg)
	e1:SetOperation(c67757079.spop)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示的「毛扎」，并判断解放该卡后是否能空出可用的怪兽区域
function c67757079.cfilter(c,ft,tp)
	return c:IsFaceup() and c:IsCode(94878265)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5))
end
-- 特殊召唤效果的发动代价：解放自己场上1只表侧表示的「毛扎」
function c67757079.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 在chk==0时，检查怪兽区域是否足够，以及是否存在可解放的「毛扎」
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c67757079.cfilter,1,nil,ft,tp) end
	-- 选择1只自己场上表侧表示的「毛扎」解放
	local g=Duel.SelectReleaseGroup(tp,c67757079.cfilter,1,1,nil,ft,tp)
	-- 解放选中的怪兽作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 特殊召唤效果的发动准备：检查自身是否能特殊召唤并设置操作信息
function c67757079.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理：将自身特殊召唤
function c67757079.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
