--レッド・リゾネーター
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤时才能发动。从手卡把1只4星以下的怪兽特殊召唤。
-- ②：这张卡特殊召唤时，以场上1只表侧表示怪兽为对象才能发动。自己基本分回复那只怪兽的攻击力的数值。
function c40975574.initial_effect(c)
	-- ①：这张卡召唤时才能发动。从手卡把1只4星以下的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40975574,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c40975574.sptg)
	e1:SetOperation(c40975574.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡特殊召唤时，以场上1只表侧表示怪兽为对象才能发动。自己基本分回复那只怪兽的攻击力的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40975574,1))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,40975574)
	e2:SetTarget(c40975574.rectg)
	e2:SetOperation(c40975574.recop)
	c:RegisterEffect(e2)
end
-- 定义①效果可特殊召唤的怪兽的筛选条件：必须是4星以下，并且可以被当前效果特殊召唤。
function c40975574.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件判定：检查自己场上是否有可用的主要怪兽区，且手卡中是否存在满足筛选条件的怪兽。
function c40975574.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定自己场上是否还有空余的主要怪兽区格子。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定手卡中是否存在至少1只满足spfilter条件的怪兽。
		and Duel.IsExistingMatchingCard(c40975574.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置本次连锁的操作信息，声明本效果涉及从手卡特殊召唤1只怪兽，供相关效果/时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 执行①效果的特殊召唤处理：若场上仍有空位，则从手卡选择1只符合条件的怪兽，以表侧表示特殊召唤到自己的场上。
function c40975574.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己场上是否有空位，若无空位则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给出“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手卡中选择1只满足spfilter条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c40975574.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上（不检查召唤条件、不检查苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义②效果对象可选的怪兽条件：场上表侧表示且当前攻击力大于0。
function c40975574.filter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
-- ②效果的发动条件判定与对象选择：确认场上存在可选的攻击力大于0的表侧表示怪兽，选择1只作为对象，并记录其攻击力作为回复数值。
function c40975574.rectg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c40975574.filter(chkc) end
	-- 发动条件判定：场上是否存在至少1只符合条件的表侧表示怪兽可以被选择为对象。
	if chk==0 then return Duel.IsExistingTarget(c40975574.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给出“请选择效果的对象”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从场上选择1只符合条件的表侧表示怪兽作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c40975574.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本效果将回复基本分，回复数值为对象怪兽的当前攻击力。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetFirst():GetAttack())
end
-- 执行②效果的回复处理：取回对象怪兽，若其仍然与效果关联且为表侧表示、攻击力大于0，则回复相应数值的基本分。
function c40975574.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetAttack()>0 then
		-- 以效果原因回复自己等于对象怪兽当前攻击力数值的基本分。
		Duel.Recover(tp,tc:GetAttack(),REASON_EFFECT)
	end
end
