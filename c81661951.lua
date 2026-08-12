--ドラグニティ－ミリトゥム
-- 效果：
-- 选择自己的魔法与陷阱卡区域存在的1张名字带有「龙骑兵团」的卡发动。选择的卡在自己场上特殊召唤。这个效果1回合只能使用1次。
function c81661951.initial_effect(c)
	-- 选择自己的魔法与陷阱卡区域存在的1张名字带有「龙骑兵团」的卡发动。选择的卡在自己场上特殊召唤。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81661951,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c81661951.sptg)
	e1:SetOperation(c81661951.spop)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己魔陷区表侧表示的名字带有「龙骑兵团」且可以特殊召唤的卡
function c81661951.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x29) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的对象选择与可行性检查
function c81661951.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_SZONE) and c81661951.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己魔陷区是否存在至少1张满足过滤条件的卡作为对象
		and Duel.IsExistingTarget(c81661951.filter,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己魔陷区1张满足条件的「龙骑兵团」卡作为效果对象
	local g=Duel.SelectTarget(tp,c81661951.filter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤该选择的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将选择的对象卡特殊召唤
function c81661951.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
