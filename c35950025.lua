--銀河騎士
-- 效果：
-- ①：自己场上有「光子」怪兽或者「银河」怪兽存在的场合，这张卡可以不用解放作召唤。
-- ②：这张卡的①的方法召唤成功的场合，以自己墓地1只「银河眼光子龙」为对象发动。这张卡的攻击力直到回合结束时下降1000，作为对象的怪兽守备表示特殊召唤。
function c35950025.initial_effect(c)
	-- 效果原文内容：①：自己场上有「光子」怪兽或者「银河」怪兽存在的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35950025,0))  --"不用解放作召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c35950025.ntcon)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：这张卡的①的方法召唤成功的场合，以自己墓地1只「银河眼光子龙」为对象发动。这张卡的攻击力直到回合结束时下降1000，作为对象的怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35950025,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c35950025.spcon)
	e2:SetTarget(c35950025.sptg)
	e2:SetOperation(c35950025.spop)
	c:RegisterEffect(e2)
end
-- 规则层面作用：过滤场上满足条件的「光子」或「银河」怪兽
function c35950025.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x55,0x7b)
end
-- 规则层面作用：判断是否满足不用解放召唤的条件
function c35950025.ntcon(e,c,minc)
	if c==nil then return true end
	-- 规则层面作用：判断召唤怪兽的等级是否大于等于5且场上存在可用区域
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 规则层面作用：判断场上是否存在至少1只「光子」或「银河」怪兽
		and Duel.IsExistingMatchingCard(c35950025.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 规则层面作用：判断该怪兽是否通过①的方法召唤成功
function c35950025.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_NORMAL+SUMMON_VALUE_SELF
end
-- 规则层面作用：过滤墓地中的「银河眼光子龙」卡片
function c35950025.spfilter(c,e,tp)
	return c:IsCode(93717133) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 规则层面作用：设置选择目标时的提示信息并选择墓地中的「银河眼光子龙」
function c35950025.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c35950025.spfilter(chkc,e,tp) end
	if chk==0 then return true end
	-- 规则层面作用：向玩家发送提示信息“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面作用：选择墓地中的「银河眼光子龙」作为特殊召唤的目标
	local g=Duel.SelectTarget(tp,c35950025.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 规则层面作用：设置连锁操作信息，表明将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 规则层面作用：处理效果发动后的操作，包括降低攻击力和特殊召唤怪兽
function c35950025.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 效果原文内容：这张卡的攻击力直到回合结束时下降1000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		-- 规则层面作用：获取当前连锁中选择的目标卡片
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) then
			-- 规则层面作用：将目标怪兽以守备表示特殊召唤到场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
