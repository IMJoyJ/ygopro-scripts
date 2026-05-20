--宝玉の契約
-- 效果：
-- ①：以自己的魔法与陷阱区域1张「宝玉兽」怪兽卡为对象才能发动。那张卡特殊召唤。
function c8275702.initial_effect(c)
	-- ①：以自己的魔法与陷阱区域1张「宝玉兽」怪兽卡为对象才能发动。那张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c8275702.sptg)
	e1:SetOperation(c8275702.spop)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己魔陷区表侧表示且可以特殊召唤的「宝玉兽」怪兽卡
function c8275702.filter(c,e,sp)
	return c:IsFaceup() and c:IsSetCard(0x1034) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 效果发动的对象检测与可行性判断
function c8275702.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c8275702.filter(chkc,e,tp) end
	-- 判断自己魔陷区是否存在符合条件的「宝玉兽」怪兽卡
	if chk==0 then return Duel.IsExistingTarget(c8275702.filter,tp,LOCATION_SZONE,0,1,nil,e,tp)
		-- 判断自己场上的主要怪兽区域是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己魔陷区1张表侧表示的「宝玉兽」怪兽卡作为对象
	local g=Duel.SelectTarget(tp,c8275702.filter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：特殊召唤作为对象的怪兽
function c8275702.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
