--星因士 アルタイル
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡召唤·反转召唤·特殊召唤的场合，以「星因士 河鼓二」以外的自己墓地1只「星骑士」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时「星骑士」怪兽以外的自己怪兽不能攻击。
function c2273734.initial_effect(c)
	-- 创建一个诱发选发效果，用于处理召唤·反转召唤·特殊召唤成功时的处理
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2273734,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,2273734)
	e1:SetTarget(c2273734.sptg)
	e1:SetOperation(c2273734.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	c2273734.star_knight_summon_effect=e1
end
-- 筛选满足条件的「星骑士」怪兽（非河鼓二）
function c2273734.filter(c,e,tp)
	return c:IsSetCard(0x9c) and not c:IsCode(2273734) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置效果的发动条件，判断是否能选择目标怪兽
function c2273734.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c2273734.filter(chkc,e,tp) end
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己墓地是否存在符合条件的「星骑士」怪兽
		and Duel.IsExistingTarget(c2273734.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽并设置为效果对象
	local g=Duel.SelectTarget(tp,c2273734.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果操作信息，确定特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果的发动，将目标怪兽特殊召唤
function c2273734.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以守备表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	-- 创建一个场地方效果，使「星骑士」怪兽以外的自己怪兽不能攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c2273734.atktg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到场上
	Duel.RegisterEffect(e1,tp)
end
-- 设置不能攻击效果的目标范围，排除「星骑士」怪兽
function c2273734.atktg(e,c)
	return not c:IsSetCard(0x9c)
end
