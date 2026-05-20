--ベアルクティ－ミクビリス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，从手卡把这张卡以外的1只7星以上的怪兽解放才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己若非持有等级的怪兽则不能特殊召唤。
-- ②：这张卡特殊召唤成功的场合才能发动。从手卡把「北极天熊-小灰熊」以外的1只「北极天熊」怪兽特殊召唤。
function c81321206.initial_effect(c)
	-- 注册北极天熊系列通用的手卡快速特殊召唤效果（①号效果）
	local e1=aux.AddUrsarcticSpSummonEffect(c)
	e1:SetDescription(aux.Stringid(81321206,0))
	e1:SetCountLimit(1,81321206)
	-- ②：这张卡特殊召唤成功的场合才能发动。从手卡把「北极天熊-小灰熊」以外的1只「北极天熊」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(81321206,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,81321207)
	e2:SetTarget(c81321206.sptg2)
	e2:SetOperation(c81321206.spop2)
	c:RegisterEffect(e2)
end
-- 过滤手卡中除「北极天熊-小灰熊」以外的「北极天熊」怪兽，且该怪兽可以被特殊召唤
function c81321206.spfilter2(c,e,tp)
	return c:IsSetCard(0x163) and not c:IsCode(81321206) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的启动检查与效果处理信息设置（Target函数）
function c81321206.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区域是否有空位，且手卡中是否存在满足特殊召唤条件的「北极天熊」怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c81321206.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁信息，表明该效果包含从手卡特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②的具体效果处理（Operation函数）
function c81321206.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，检查己方主要怪兽区域是否仍有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示信息，要求选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡中选择1张满足条件的「北极天熊」怪兽
	local g=Duel.SelectMatchingCard(tp,c81321206.spfilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到己方场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
