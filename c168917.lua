--ヴァイロン・ハプト
-- 效果：
-- 1回合1次，可以选择当作装备卡使用在自己场上存在的1张名字带有「大日」的怪兽卡表侧守备表示特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合从游戏中除外。
function c168917.initial_effect(c)
	-- 效果发动条件：1回合1次，选择自己场上表侧表示存在的1张名字带有「大日」的怪兽卡进行特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(168917,0))  --"特殊召唤"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c168917.sptg)
	e1:SetOperation(c168917.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数：用于筛选满足条件的装备怪兽（表侧表示、有装备对象、名字带有「大日」、可特殊召唤）
function c168917.filter(c,e,tp)
	return c:IsFaceup() and c:GetEquipTarget() and c:IsSetCard(0x30) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果处理的条件判断：检查是否有足够的怪兽区域，并且场上是否存在符合条件的装备怪兽
function c168917.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c168917.filter(chkc,e,tp) end
	-- 判断场上是否有足够的怪兽区域用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断场上是否存在符合条件的装备怪兽
		and Duel.IsExistingTarget(c168917.filter,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的装备怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择符合条件的装备怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c168917.filter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	-- 设置效果操作信息，确定特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数：将选中的装备怪兽特殊召唤到场上
function c168917.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认目标怪兽有效且成功特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 特殊召唤的怪兽从场上离开时从游戏中除外
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e1,true)
	end
end
