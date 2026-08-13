--氷結界の虎将 ガンターラ
-- 效果：
-- ①：自己结束阶段，以「冰结界的虎将 健陀罗」以外的自己墓地1只「冰结界」怪兽为对象才能发动。那只怪兽特殊召唤。
function c53921056.initial_effect(c)
	-- ①：自己结束阶段，以「冰结界的虎将 健陀罗」以外的自己墓地1只「冰结界」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53921056,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetCondition(c53921056.spcon)
	e1:SetTarget(c53921056.sptg)
	e1:SetOperation(c53921056.spop)
	c:RegisterEffect(e1)
end
-- 定义可特殊召唤的“冰结界”怪兽筛选函数：需满足是“冰结界”字段怪兽、不是本卡（健陀罗），且可以被效果特殊召唤。
function c53921056.filter(c,e,tp)
	return c:IsSetCard(0x2f) and not c:IsCode(53921056) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动条件的判定函数，判断是否满足“自己结束阶段”这一发动时机。
function c53921056.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为己方，确保效果只在自己的结束阶段发动。
	return Duel.GetTurnPlayer()==tp
end
-- 目标选择函数：若在连锁确认对象，则验证对象是自己墓地的符合条件的“冰结界”怪兽；若在发动时检查合法性，则确认主要怪兽区有空位且墓地存在符合条件的对象。
function c53921056.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c53921056.filter(chkc,e,tp) end
	-- 发动合法性检查的第一部分：确认己方主要怪兽区域有空位，可以特殊召唤怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动合法性检查的第二部分：确认墓地存在至少1只符合条件的“冰结界”怪兽可以作为对象。
		and Duel.IsExistingTarget(c53921056.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向己方玩家显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地的符合条件的怪兽中选择1只作为效果对象，并登记为当前连锁的对象（取对象）。
	local g=Duel.SelectTarget(tp,c53921056.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设定本次效果处理的操作信息为特殊召唤，对象为已选择的怪兽，数量为1，供连锁判定及后续处理使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数：取得之前选择的对象，若该卡仍与效果关联则将其特殊召唤。
function c53921056.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的唯一对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
