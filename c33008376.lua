--マテリアクトル・ギガドラ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己不是超量怪兽不能从额外卡组特殊召唤。
-- ②：丢弃1张手卡才能发动。从手卡·卡组把1只3星通常怪兽特殊召唤。把通常怪兽丢弃发动的场合，可以把特殊召唤的怪兽改成1只「原质炉」怪兽。
function c33008376.initial_effect(c)
	-- 效果原文内容：自己不是超量怪兽不能从额外卡组特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33008376,0))  --"自己不是超量怪兽不能从额外卡组特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,33008376)
	e1:SetCost(c33008376.spcost)
	e1:SetTarget(c33008376.sptg)
	e1:SetOperation(c33008376.spop)
	c:RegisterEffect(e1)
	-- 效果原文内容：只要这张卡在怪兽区域存在，自己不是超量怪兽不能从额外卡组特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c33008376.splimit)
	c:RegisterEffect(e2)
end
-- 检查手牌中是否存在可丢弃且满足特殊召唤条件的卡片
function c33008376.costfilter(c,e,tp)
	-- 检查手牌中是否存在可丢弃且满足特殊召唤条件的卡片
	return c:IsDiscardable() and Duel.IsExistingMatchingCard(c33008376.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,c,e,tp,c:IsType(TYPE_NORMAL))
end
-- 筛选可以特殊召唤的3星通常怪兽或「原质炉」怪兽
function c33008376.spfilter(c,e,tp,normal)
	return (normal and c:IsSetCard(0x160) or c:IsLevel(3) and c:IsType(TYPE_NORMAL)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 丢弃1张手卡作为发动代价
function c33008376.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100,0)
	-- 检查是否满足丢弃手卡的发动条件
	if chk==0 then return Duel.IsExistingMatchingCard(c33008376.costfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 选择1张满足条件的手牌进行丢弃
	local sg=Duel.SelectMatchingCard(tp,c33008376.costfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if sg:GetFirst():IsType(TYPE_NORMAL) then
		e:SetLabel(100,1)
	else
		e:SetLabel(100,0)
	end
	-- 将选中的手牌送入墓地作为发动代价
	Duel.SendtoGrave(sg,REASON_COST+REASON_DISCARD)
end
-- 设置特殊召唤效果的发动条件
function c33008376.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local check,label=e:GetLabel()
	if chk==0 then
		e:SetLabel(0,0)
		-- 检查是否满足特殊召唤的发动条件
		return check==100 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
	e:SetLabel(0,label)
	-- 设置连锁操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 执行特殊召唤效果
function c33008376.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的特殊召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local check,label=e:GetLabel()
	local normal=label==1
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1张满足条件的怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,c33008376.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,normal)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 限制非超量怪兽从额外卡组特殊召唤
function c33008376.splimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_XYZ)
end
