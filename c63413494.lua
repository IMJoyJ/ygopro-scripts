--廃車復活
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己或者对方的手卡有怪兽被送去墓地的场合，以那1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
function c63413494.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己或者对方的手卡有怪兽被送去墓地的场合，以那1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,63413494+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c63413494.target)
	e1:SetOperation(c63413494.activate)
	c:RegisterEffect(e1)
end
-- 过滤满足“可以特殊召唤”、“原本在手卡”且“属于本次送去墓地的卡（在eg中）”的墓地怪兽
function c63413494.filter(c,e,tp,g)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsPreviousLocation(LOCATION_HAND) and (not g or g:IsContains(c))
end
-- 效果发动的可行性检查与对象选择
function c63413494.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c63413494.filter(chkc,e,tp) end
	-- 检查发动玩家场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查双方墓地中是否存在满足条件的、可作为效果对象的怪兽
		and Duel.IsExistingTarget(c63413494.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp,eg) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择双方墓地中1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c63413494.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp,eg)
	-- 设置效果处理信息为特殊召唤该对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将作为对象的怪兽在自己场上特殊召唤
function c63413494.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到发动效果的玩家场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
