--原初の叫喚
-- 效果：
-- 「辉神鸟 贝努鸟」的降临必需。
-- ①：从自己的手卡·场上把等级合计直到8以上的怪兽解放，从手卡把「辉神鸟 贝努鸟」仪式召唤。
-- ②：自己结束阶段把墓地的这张卡除外，以这个回合从场上送去墓地的自己墓地1只仪式怪兽为对象才能发动。那只怪兽特殊召唤。
function c47435107.initial_effect(c)
	-- 为这张卡添加仪式召唤效果：解放手卡·场上等级合计直到8以上的怪兽，从手卡仪式召唤「辉神鸟 贝努鸟」（素材合计等级可超过其原本等级）。
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
	-- 设置②效果的发动代价：将墓地里的这张卡除外（aux.bfgcost 为除外自身作为COST的通用过滤与执行函数）。
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c47435107.sptg)
	e1:SetOperation(c47435107.spop)
	c:RegisterEffect(e1)
end
-- ②效果的发动条件函数：仅在己方回合的结束阶段且当前回合玩家为自己时满足。
function c47435107.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家是这张卡的操作者（己方）时条件成立。
	return Duel.GetTurnPlayer()==tp
end
-- 筛选可被②效果特殊召唤的仪式怪兽：必须是仪式怪兽、能被效果特殊召唤、且是在这个回合从场上送去墓地的卡（之前位置在场上且转到墓地时的回合为当前回合）。
function c47435107.spfilter(c,e,tp,turn)
	return c:IsType(TYPE_RITUAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:GetTurnID()==turn
end
-- ②效果发动时的目标选择函数：检索并选择自己墓地中符合 spfilter 条件的1只仪式怪兽作为对象，且自己场上需要有可用的主要怪兽区域。
function c47435107.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前回合数，用于判断对象是否是在这个回合从场上送入墓地。
	local turn=Duel.GetTurnCount()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c47435107.spfilter(chkc,e,tp,turn) end
	-- 发动合法性检查：玩家自己场上必须有至少1个可用主要怪兽区域，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己墓地存在至少1只能满足特殊召唤条件的仪式怪兽（且可作为效果对象）。
		and Duel.IsExistingTarget(c47435107.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,turn) end
	-- 向操作者显示选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的仪式怪兽作为效果对象，并将选中卡设置为当前连锁对象。
	local g=Duel.SelectTarget(tp,c47435107.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,turn)
	-- 设置操作信息：本次效果处理将进行特殊召唤，对象为选择的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理函数：将作为对象的仪式怪兽以表侧表示特殊召唤到自己场上。
function c47435107.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中作为对象的那张卡（即选择的仪式怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该仪式怪兽以正面表示特殊召唤到己方场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
