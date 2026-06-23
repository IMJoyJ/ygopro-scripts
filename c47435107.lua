--原初の叫喚
-- 效果：
-- 「辉神鸟 贝努鸟」的降临必需。
-- ①：从自己的手卡·场上把等级合计直到8以上的怪兽解放，从手卡把「辉神鸟 贝努鸟」仪式召唤。
-- ②：自己结束阶段把墓地的这张卡除外，以这个回合从场上送去墓地的自己墓地1只仪式怪兽为对象才能发动。那只怪兽特殊召唤。
function c47435107.initial_effect(c)
	-- 为卡片添加等级合计超过8的仪式召唤效果，仪式怪兽为辉神鸟 贝努鸟
	aux.AddRitualProcGreaterCode(c,10441498)
	-- ②：自己结束阶段把墓地的这张卡除外，以这个回合从场上送去墓地的自己墓地1只仪式怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47435107,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1)
	e1:SetCondition(c47435107.spcon)
	-- 设置效果的费用为将此卡除外
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c47435107.sptg)
	e1:SetOperation(c47435107.spop)
	c:RegisterEffect(e1)
end
-- 效果发动时的条件判断函数
function c47435107.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果发动者
	return Duel.GetTurnPlayer()==tp
end
-- 筛选满足条件的墓地仪式怪兽，包括：是仪式怪兽、可以特殊召唤、之前在场上、且是本回合被送去墓地的
function c47435107.spfilter(c,e,tp,turn)
	return c:IsType(TYPE_RITUAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:GetTurnID()==turn
end
-- 设置效果的目标选择函数，用于选择符合条件的墓地仪式怪兽
function c47435107.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前回合数，用于判断怪兽是否为本回合被送去墓地
	local turn=Duel.GetTurnCount()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c47435107.spfilter(chkc,e,tp,turn) end
	-- 检查是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否存在满足条件的墓地仪式怪兽作为目标
		and Duel.IsExistingTarget(c47435107.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,turn) end
	-- 向玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 根据筛选条件选择一个目标怪兽
	local g=Duel.SelectTarget(tp,c47435107.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,turn)
	-- 设置效果处理时的操作信息，指定将要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果的处理函数，执行特殊召唤操作
function c47435107.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以正面表示的形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
