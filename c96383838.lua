--トライワイトゾーン
-- 效果：
-- ①：以自己墓地3只2星以下的通常怪兽为对象才能发动。那些怪兽特殊召唤。
function c96383838.initial_effect(c)
	-- ①：以自己墓地3只2星以下的通常怪兽为对象才能发动。那些怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c96383838.target)
	e1:SetOperation(c96383838.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中等级2以下且可以特殊召唤的通常怪兽
function c96383838.filter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsLevelBelow(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的对象选择与可行性检测
function c96383838.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c96383838.filter(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上的怪兽区域空位数是否大于2个
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		-- 检查自己墓地是否存在至少3只满足条件的怪兽作为对象
		and Duel.IsExistingTarget(c96383838.filter,tp,LOCATION_GRAVE,0,3,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地3只满足条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c96383838.filter,tp,LOCATION_GRAVE,0,3,3,nil,e,tp)
	-- 设置效果处理信息为特殊召唤这3只对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,3,0,0)
end
-- 过滤效果处理时仍与效果相关且可以特殊召唤的卡片
function c96383838.rfilter(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理的执行函数
function c96383838.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	local sg=g:Filter(c96383838.rfilter,nil,e,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if sg:GetCount()==0 or (sg:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	if sg:GetCount()>ft then sg=sg:Select(tp,ft,ft,nil) end
	-- 将选中的怪兽以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end
