--閃光のイリュージョン
-- 效果：
-- 从自己墓地选择1只名字带有有「光道」的怪兽，攻击表示特殊召唤。每次自己的结束阶段，从卡组上面把2张卡送去墓地。这张卡从场上离开时，那只怪兽破坏。那只怪兽从场上离开时这张卡破坏。
function c61962135.initial_effect(c)
	-- 从自己墓地选择1只名字带有有「光道」的怪兽，攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c61962135.target)
	e1:SetOperation(c61962135.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时，那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c61962135.desop)
	c:RegisterEffect(e2)
	-- 那只怪兽从场上离开时这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c61962135.descon2)
	e3:SetOperation(c61962135.desop2)
	c:RegisterEffect(e3)
	-- 每次自己的结束阶段，从卡组上面把2张卡送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCategory(CATEGORY_DECKDES)
	e4:SetDescription(aux.Stringid(61962135,0))  --"从卡组上面把2张卡送去墓地"
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c61962135.discon)
	e4:SetTarget(c61962135.distg)
	e4:SetOperation(c61962135.disop)
	c:RegisterEffect(e4)
end
-- 过滤自己墓地中名字带有「光道」且可以攻击表示特殊召唤的怪兽
function c61962135.filter(c,e,tp)
	return c:IsSetCard(0x38) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果发动时的对象选择与合法性检测
function c61962135.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c61962135.filter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在符合条件的「光道」怪兽
		and Duel.IsExistingTarget(c61962135.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的「光道」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c61962135.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将选择的怪兽攻击表示特殊召唤，并建立对象连接
function c61962135.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的效果对象
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)
		-- 将目标怪兽以表侧攻击表示特殊召唤
		and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
		c:SetCardTarget(tc)
	end
	-- 完成特殊召唤的处理
	Duel.SpecialSummonComplete()
end
-- 这张卡离场时，破坏特殊召唤的怪兽
function c61962135.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 因效果破坏目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 检查离场的怪兽中是否包含被特殊召唤的那只怪兽
function c61962135.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 目标怪兽离场时，破坏这张卡
function c61962135.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果破坏这张卡
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 检查当前是否为自己的回合
function c61962135.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为自己
	return tp==Duel.GetTurnPlayer()
end
-- 结束阶段送墓效果的靶向检测与操作信息设置
function c61962135.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置从卡组送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
end
-- 结束阶段送墓效果的具体处理
function c61962135.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 将自己卡组最上方的2张卡送去墓地
	Duel.DiscardDeck(tp,2,REASON_EFFECT)
end
