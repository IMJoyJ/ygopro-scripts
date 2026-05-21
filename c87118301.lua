--霊獣使い レラ
-- 效果：
-- 自己对「灵兽使 蕾拉」1回合只能有1次特殊召唤。
-- ①：这张卡召唤的场合，以自己墓地1只「灵兽」怪兽为对象才能发动。那只怪兽特殊召唤。
function c87118301.initial_effect(c)
	c:SetSPSummonOnce(87118301)
	-- ①：这张卡召唤的场合，以自己墓地1只「灵兽」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87118301,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c87118301.sptg)
	e1:SetOperation(c87118301.spop)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己墓地中可以特殊召唤的「灵兽」怪兽
function c87118301.filter(c,e,tp)
	return c:IsSetCard(0xb5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与目标选择（检查场上空格及墓地是否存在合法的「灵兽」怪兽）
function c87118301.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c87118301.filter(chkc,e,tp) end
	-- 在发动效果时，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己墓地是否存在至少1只满足过滤条件的「灵兽」怪兽
		and Duel.IsExistingTarget(c87118301.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足过滤条件的「灵兽」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c87118301.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表示该连锁包含特殊召唤选定怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理（特殊召唤作为对象的怪兽）
function c87118301.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
