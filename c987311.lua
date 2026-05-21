--DDD疾風王アレクサンダー
-- 效果：
-- 「DD」调整＋调整以外的怪兽1只以上
-- 「DDD 疾风王 亚历山大」的效果1回合只能使用1次。
-- ①：这张卡在怪兽区域存在，自己场上有这张卡以外的「DD」怪兽召唤·特殊召唤的场合，以自己墓地1只4星以下的「DD」怪兽为对象才能发动。那只怪兽特殊召唤。
function c987311.initial_effect(c)
	-- 添加同调召唤手续：以「DD」怪兽作为调整，调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xaf),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡在怪兽区域存在，自己场上有这张卡以外的「DD」怪兽召唤·特殊召唤的场合，以自己墓地1只4星以下的「DD」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(987311,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,987311)
	e1:SetCondition(c987311.spcon)
	e1:SetTarget(c987311.sptg)
	e1:SetOperation(c987311.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「DD」怪兽
function c987311.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xaf) and c:IsControler(tp)
end
-- 发动条件：自己场上有这张卡以外的「DD」怪兽召唤·特殊召唤的场合
function c987311.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c987311.cfilter,1,nil,tp)
end
-- 过滤条件：自己墓地4星以下且可以特殊召唤的「DD」怪兽
function c987311.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0xaf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动靶向处理：检查是否满足发动条件，并选择自己墓地1只4星以下的「DD」怪兽作为对象
function c987311.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c987311.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足条件的「DD」怪兽可以作为效果对象
		and Duel.IsExistingTarget(c987311.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的「DD」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c987311.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：包含特殊召唤分类，操作对象为选择的卡片，数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理阶段：将作为对象的怪兽特殊召唤
function c987311.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
