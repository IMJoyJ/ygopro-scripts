--デストーイ・カスタム
-- 效果：
-- ①：以自己墓地1只「锋利小鬼」怪兽或者「毛绒动物」怪兽为对象才能发动。那只怪兽特殊召唤。把这个效果特殊召唤的怪兽作为融合素材的场合，可以当作「魔玩具」怪兽使用。
function c36693940.initial_effect(c)
	-- 效果原文内容：①：以自己墓地1只「锋利小鬼」怪兽或者「毛绒动物」怪兽为对象才能发动。那只怪兽特殊召唤。把这个效果特殊召唤的怪兽作为融合素材的场合，可以当作「魔玩具」怪兽使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c36693940.target)
	e1:SetOperation(c36693940.activate)
	c:RegisterEffect(e1)
end
-- 规则层面作用：筛选满足条件的墓地怪兽（锋利小鬼或毛绒动物），并判断其能否特殊召唤。
function c36693940.filter(c,e,tp)
	return c:IsSetCard(0xa9,0xc3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面作用：判断是否满足发动条件，包括是否有足够的怪兽区域和目标怪兽。
function c36693940.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c36693940.filter(chkc,e,tp) end
	-- 规则层面作用：检查玩家场上是否有足够的怪兽区域用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面作用：检查玩家墓地中是否存在符合条件的怪兽。
		and Duel.IsExistingTarget(c36693940.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 规则层面作用：向玩家发送提示信息，提示其选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面作用：选择符合条件的墓地怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,c36693940.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 规则层面作用：设置连锁操作信息，表明将要特殊召唤怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果原文内容：那只怪兽特殊召唤。把这个效果特殊召唤的怪兽作为融合素材的场合，可以当作「魔玩具」怪兽使用。
function c36693940.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 规则层面作用：判断目标怪兽是否仍然存在于场上，并尝试将其特殊召唤。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 规则层面作用：为特殊召唤的怪兽添加效果，使其在作为融合素材时可视为魔玩具怪兽。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(36693940,0))  --"「魔玩具改造」效果适用中"
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_FUSION_SETCODE)
		e1:SetValue(0xad)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
