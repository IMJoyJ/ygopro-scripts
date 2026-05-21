--TG ギア・ゾンビ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：以自己场上1只「科技属」怪兽为对象才能发动。这张卡从手卡特殊召唤。那之后，作为对象的怪兽的攻击力下降1000。
function c94350039.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：以自己场上1只「科技属」怪兽为对象才能发动。这张卡从手卡特殊召唤。那之后，作为对象的怪兽的攻击力下降1000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94350039,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,94350039)
	e1:SetTarget(c94350039.sptg)
	e1:SetOperation(c94350039.spop)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「科技属」怪兽
function c94350039.cfilter(c)
	return c:IsSetCard(0x27) and c:IsFaceup()
end
-- 效果发动的可行性检测，包括自身特殊召唤的检测以及场上是否存在合法的对象怪兽
function c94350039.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c94350039.cfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检测自己场上是否有空余的怪兽区域用于特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测自己场上是否存在可以作为效果对象的「科技属」怪兽
		and Duel.IsExistingTarget(c94350039.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示信息，要求选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的「科技属」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c94350039.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁的操作信息，表明此效果包含特殊召唤自身的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理的执行函数，处理特殊召唤以及后续的攻击力下降
function c94350039.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身从手卡表侧表示特殊召唤，并判断是否特殊召唤成功
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取在发动时选择的作为对象的怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsFaceup() and tc:IsRelateToEffect(e) then
			-- 中断当前效果处理，使后续的攻击力下降与特殊召唤不视为同时进行，以符合“那之后”的时点要求
			Duel.BreakEffect()
			-- 作为对象的怪兽的攻击力下降1000。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(-1000)
			tc:RegisterEffect(e1)
		end
	end
end
