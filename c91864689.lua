--S－Force エッジ・レイザー
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从手卡把「治安战警队 拔刃者」以外的1只「治安战警队」怪兽攻击表示特殊召唤。
-- ②：只要这张卡在怪兽区域存在，自己的「治安战警队」怪兽的正对面的对方怪兽不能作为连接3以上的怪兽的连接素材。
function c91864689.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从手卡把「治安战警队 拔刃者」以外的1只「治安战警队」怪兽攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91864689,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,91864689)
	e1:SetTarget(c91864689.sptg)
	e1:SetOperation(c91864689.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，自己的「治安战警队」怪兽的正对面的对方怪兽不能作为连接3以上的怪兽的连接素材。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetValue(c91864689.linklimit)
	e3:SetTarget(c91864689.matlimit)
	c:RegisterEffect(e3)
end
-- 过滤手牌中除「治安战警队 拔刃者」以外且能以表侧攻击表示特殊召唤的「治安战警队」怪兽
function c91864689.spfilter(c,e,tp)
	return c:IsSetCard(0x156) and not c:IsCode(91864689)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- ①效果的发动准备（检查怪兽区域空位以及手牌中是否存在可特殊召唤的「治安战警队」怪兽）
function c91864689.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只满足特殊召唤条件的「治安战警队」怪兽
		and Duel.IsExistingMatchingCard(c91864689.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示该效果会从手牌特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果的执行（从手牌选择1只「治安战警队」怪兽以表侧攻击表示特殊召唤）
function c91864689.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上没有可用的怪兽区域空位，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌选择1只满足条件的「治安战警队」怪兽
	local g=Duel.SelectMatchingCard(tp,c91864689.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧攻击表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
-- 限制不能作为连接3以上的怪兽的连接素材
function c91864689.linklimit(e,c)
	return c:IsLinkAbove(3)
end
-- 过滤自己场上表侧表示的「治安战警队」怪兽
function c91864689.matfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x156) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- 检查对方怪兽的同纵列（正对面）是否存在自己的「治安战警队」怪兽
function c91864689.matlimit(e,c)
	local face=c:GetColumnGroup()
	return face:IsExists(c91864689.matfilter,1,nil,e:GetHandlerPlayer())
end
