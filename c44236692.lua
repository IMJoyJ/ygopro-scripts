--ネクロ・リンカー
-- 效果：
-- 把这张卡解放，选择自己墓地存在的1只名字带有「同调士」的调整发动。选择的怪兽特殊召唤。这个效果特殊召唤的怪兽这个回合不能作为同调素材。
function c44236692.initial_effect(c)
	-- 创建一个起动效果，用于特殊召唤名字带有「同调士」的调整怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44236692,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c44236692.spcost)
	e1:SetTarget(c44236692.sptg)
	e1:SetOperation(c44236692.spop)
	c:RegisterEffect(e1)
end
-- 检查是否可以支付将此卡解放作为效果的代价
function c44236692.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将此卡解放作为效果的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤满足条件的墓地怪兽，即名字带有「同调士」且为调整的怪兽
function c44236692.filter(c,e,tp)
	return c:IsSetCard(0x1017) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的目标选择条件，即选择自己墓地满足条件的怪兽
function c44236692.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c44236692.filter(chkc,e,tp) end
	-- 检查场上是否有足够的怪兽区域来特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查自己墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c44236692.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为效果的目标
	local g=Duel.SelectTarget(tp,c44236692.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果的处理信息，表明将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果的发动，特殊召唤目标怪兽并使其不能作为同调素材
function c44236692.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认目标怪兽有效且成功特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 使该特殊召唤的怪兽在本回合不能作为同调素材
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
