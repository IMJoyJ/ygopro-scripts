--ヴァイパー・リボーン
-- 效果：
-- ①：自己墓地的怪兽只有爬虫类族怪兽的场合，以调整以外的自己墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合的结束阶段破坏。
function c64973456.initial_effect(c)
	-- ①：自己墓地的怪兽只有爬虫类族怪兽的场合，以调整以外的自己墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合的结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c64973456.condition)
	e1:SetTarget(c64973456.target)
	e1:SetOperation(c64973456.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查卡片是否为非爬虫类族的怪兽
function c64973456.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:GetRace()~=RACE_REPTILE
end
-- 发动条件：自己墓地的怪兽只有爬虫类族怪兽
function c64973456.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否不存在非爬虫类族的怪兽
	return not Duel.IsExistingMatchingCard(c64973456.cfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 过滤函数：检查卡片是否为非调整怪兽且可以特殊召唤
function c64973456.filter(c,e,tp)
	return not c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果选择目标：检查怪兽区域空位，并选择自己墓地1只非调整怪兽作为对象
function c64973456.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c64973456.filter(chkc,e,tp) end
	-- 在发动时，检查自己场上是否有可以特殊召唤的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动时，检查自己墓地是否存在可以作为对象的非调整怪兽
		and Duel.IsExistingTarget(c64973456.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只非调整怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c64973456.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将选择的怪兽特殊召唤，并注册回合结束时将其破坏的效果
function c64973456.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域空位，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍符合条件，则将其以表侧表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(64973456,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		-- 这个效果特殊召唤的怪兽在这个回合的结束阶段破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c64973456.descon)
		e1:SetOperation(c64973456.desop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		-- 注册在回合结束时触发的全局效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 破坏效果的触发条件：检查该怪兽是否仍带有特殊召唤时的标记
function c64973456.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:GetFlagEffectLabel(64973456)==e:GetLabel()
end
-- 破坏效果的处理：破坏该怪兽
function c64973456.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果将该怪兽破坏
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
