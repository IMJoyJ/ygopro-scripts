--EMレ・ベルマン
-- 效果：
-- ←1 【灵摆】 1→
-- ①：1回合1次，自己主要阶段才能发动。自己场上的灵摆召唤的全部怪兽的等级上升1星。
-- 【怪兽效果】
-- ①：1回合1次，宣言1～5的任意等级，以这张卡以外的自己场上1只「娱乐伙伴」怪兽为对象才能发动。直到回合结束时，这张卡的等级下降宣言的等级数值，作为对象的怪兽的等级上升宣言的等级数值。
function c3752422.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性，使其可以进行灵摆卡的发动和灵摆召唤
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，自己主要阶段才能发动。自己场上的灵摆召唤的全部怪兽的等级上升1星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3752422,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c3752422.lvtg)
	e1:SetOperation(c3752422.lvop)
	c:RegisterEffect(e1)
	-- ①：1回合1次，宣言1～5的任意等级，以这张卡以外的自己场上1只「娱乐伙伴」怪兽为对象才能发动。直到回合结束时，这张卡的等级下降宣言的等级数值，作为对象的怪兽的等级上升宣言的等级数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3752422,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c3752422.target)
	e2:SetOperation(c3752422.operation)
	c:RegisterEffect(e2)
end
-- 定义过滤器：表侧表示的、用灵摆召唤方式召唤的、等级大于0的怪兽
function c3752422.lvfilter(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:GetLevel()>0
end
-- 灵摆区起动效果的发动条件检测：检查自己怪兽区是否存在符合条件的怪兽
function c3752422.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己怪兽区是否存在至少1只表侧表示的灵摆召唤的等级大于0的怪兽，存在才能发动
	if chk==0 then return Duel.IsExistingMatchingCard(c3752422.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 灵摆区效果的处理：遍历自己场上全部灵摆召唤的怪兽，令它们的等级各上升1星
function c3752422.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 检索自己怪兽区全部满足条件的怪兽（表侧表示的灵摆召唤的等级大于0的怪兽）
	local tg=Duel.GetMatchingGroup(c3752422.lvfilter,tp,LOCATION_MZONE,0,nil)
	local tc=tg:GetFirst()
	while tc do
		-- 给该怪兽注册永续效果：等级上升1星（离开场上等情况重置）
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		tc:RegisterEffect(e1)
		tc=tg:GetNext()
	end
end
-- 定义过滤器：表侧表示的「娱乐伙伴」怪兽且等级大于0
function c3752422.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9f) and c:GetLevel()>0
end
-- 怪兽效果的发动条件及取对象检测：自身等级须大于1，且自己怪兽区存在这张卡以外可作为对象的符合条件的「娱乐伙伴」怪兽
function c3752422.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc~=c and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c3752422.filter(chkc) end
	if chk==0 then return c:GetLevel()>1
		-- 检查自己怪兽区是否存在至少1只这张卡以外的、可作为效果对象的表侧表示「娱乐伙伴」怪兽
		and Duel.IsExistingTarget(c3752422.filter,tp,LOCATION_MZONE,0,1,c) end
	local p=c:GetLevel()-1
	p=math.min(p,5)
	-- 向玩家发送提示消息：请选择要宣言的等级
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	-- 让玩家宣言1至p（自身等级减1，最多5）之间的任意等级，并将宣言的数值记录到效果标签中
	e:SetLabel(Duel.AnnounceLevel(tp,1,p))
	-- 向玩家发送提示消息：请选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让自己选择这张卡以外的自己怪兽区1只符合条件的「娱乐伙伴」怪兽作为效果对象
	Duel.SelectTarget(tp,c3752422.filter,tp,LOCATION_MZONE,0,1,1,c)
end
-- 怪兽效果的处理：直到回合结束时，这张卡的等级下降宣言的数值，对象怪兽的等级上升宣言的数值
function c3752422.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv=e:GetLabel()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 直到回合结束时，这张卡的等级下降宣言的等级数值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		-- 取得当前连锁所选择的对象怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsFaceup() and tc:IsRelateToEffect(e) then
			-- 作为对象的怪兽的等级上升宣言的等级数值（直到回合结束时）
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_LEVEL)
			e2:SetValue(lv)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
	end
end
