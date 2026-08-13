--霊獣使い ウェン
-- 效果：
-- 自己对「灵兽使 文」1回合只能有1次特殊召唤。
-- ①：这张卡召唤的场合，以自己的除外状态的1只「灵兽」怪兽为对象才能发动。那只怪兽特殊召唤。
function c40907115.initial_effect(c)
	c:SetSPSummonOnce(40907115)
	-- ①：这张卡召唤的场合，以自己的除外状态的1只「灵兽」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40907115,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c40907115.sptg)
	e1:SetOperation(c40907115.spop)
	c:RegisterEffect(e1)
end
-- 定义本效果可选择的「灵兽」怪兽需要满足的条件：表侧表示、属于「灵兽」系列、且可以被当前效果特殊召唤（满足特殊召唤限制）。
function c40907115.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0xb5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标指定与条件判定：若在连锁处理中确认对象，则验证对象是自己除外的表侧「灵兽」且可特殊召唤；若在发动判定时，则需要己方主要怪兽区有空位且存在至少1只符合条件的除外「灵兽」怪兽。
function c40907115.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c40907115.filter(chkc,e,tp) end
	-- 发动条件之一：己方的主要怪兽区存在可用的空格，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之二：除外区存在至少1只满足filter条件（表侧「灵兽」且可特殊召唤）并能成为当前效果对象的怪兽。
		and Duel.IsExistingTarget(c40907115.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向操作玩家弹出“请选择要特殊召唤的卡”的提示信息，用于目标选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己除外区选择1只满足条件且可特殊召唤的「灵兽」怪兽，并将其登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c40907115.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 登记本次效果处理的操作信息：将选择的对象怪兽特殊召唤，供后续处理及相关卡片判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理阶段的实际操作：获取对象怪兽，若对象仍与效果保持关联，则将其特殊召唤到己方场上。
function c40907115.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中被指定为对象的第一张卡，即之前选择的除外区「灵兽」怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该对象怪兽以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
