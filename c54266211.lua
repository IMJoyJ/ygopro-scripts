--エヴォルダー・ウルカノドン
-- 效果：
-- 这张卡用名字带有「进化虫」的怪兽的效果特殊召唤成功时，可以选择自己墓地存在的1只名字带有「进化龙」的怪兽特殊召唤。这个效果特殊召唤的怪兽不能攻击宣言。
function c54266211.initial_effect(c)
	-- 这张卡用名字带有「进化虫」的怪兽的效果特殊召唤成功时，可以选择自己墓地存在的1只名字带有「进化龙」的怪兽特殊召唤。这个效果特殊召唤的怪兽不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54266211,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	-- 设置效果发动条件为：这张卡用名字带有「进化虫」的怪兽的效果特殊召唤成功时
	e1:SetCondition(aux.evospcon)
	e1:SetTarget(c54266211.sptg)
	e1:SetOperation(c54266211.spop)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中名字带有「进化龙」且可以特殊召唤的怪兽
function c54266211.filter(c,e,tp)
	return c:IsSetCard(0x604e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标选择与检测：检查自身主要怪兽区域是否有空位，以及自己墓地是否存在符合条件的「进化龙」怪兽
function c54266211.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查当前玩家的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只符合条件的「进化龙」怪兽可以作为效果对象
		and Duel.IsExistingTarget(c54266211.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的「进化龙」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c54266211.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为：特殊召唤所选择的1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将选择的墓地怪兽特殊召唤，并对其施加不能攻击宣言的限制
function c54266211.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的目标对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽不能攻击宣言。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
