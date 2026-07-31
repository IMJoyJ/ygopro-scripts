--EMレ・ベルマン
-- 效果：
-- ←1 【灵摆】 1→
-- ①：1回合1次，自己主要阶段才能发动。自己场上的灵摆召唤的全部怪兽的等级上升1星。
-- 【怪兽效果】
-- ①：1回合1次，宣言1～5的任意等级，以这张卡以外的自己场上1只「娱乐伙伴」怪兽为对象才能发动。直到回合结束时，这张卡的等级下降宣言的等级数值，作为对象的怪兽的等级上升宣言的等级数值。
function c3752422.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
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
-- 过滤函数，用于判断场上的灵摆召唤怪兽（正面表示且等级大于0）
function c3752422.lvfilter(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:GetLevel()>0
end
-- 检查是否满足条件：自己场上存在至少1只灵摆召唤的怪兽
function c3752422.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若未满足条件则返回false，表示无法发动效果
	if chk==0 then return Duel.IsExistingMatchingCard(c3752422.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 将所有符合条件的灵摆召唤怪兽的等级提升1星
function c3752422.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取所有符合条件的灵摆召唤怪兽组成的Group
	local tg=Duel.GetMatchingGroup(c3752422.lvfilter,tp,LOCATION_MZONE,0,nil)
	local tc=tg:GetFirst()
	while tc do
		-- 为该怪兽添加等级上升1的效果，并在回合结束时重置
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		tc:RegisterEffect(e1)
		tc=tg:GetNext()
	end
end
-- 过滤函数，用于判断场上的「娱乐伙伴」怪兽（正面表示且等级大于0）
function c3752422.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9f) and c:GetLevel()>0
end
-- 设置效果的目标选择逻辑：选择自己场上除自身外的任意一只「娱乐伙伴」怪兽
function c3752422.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc~=c and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c3752422.filter(chkc) end
	if chk==0 then return c:GetLevel()>1
		-- 检查是否满足条件：自己场上存在至少1只符合条件的怪兽作为目标
		and Duel.IsExistingTarget(c3752422.filter,tp,LOCATION_MZONE,0,1,c) end
	local p=c:GetLevel()-1
	p=math.min(p,5)
	-- 提示玩家选择宣言等级
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	-- 让玩家宣言一个1到p之间的等级数值并记录在效果标签中
	e:SetLabel(Duel.AnnounceLevel(tp,1,p))
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择一只符合条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c3752422.filter,tp,LOCATION_MZONE,0,1,1,c)
end
-- 执行效果操作：使自身等级下降宣言的等级数值，同时目标怪兽等级上升相同数值
function c3752422.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv=e:GetLabel()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 为自身添加等级下降的效果，并在回合结束时重置
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		-- 获取当前连锁中被选择的目标怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsFaceup() and tc:IsRelateToEffect(e) then
			-- 为目标怪兽添加等级上升的效果，并在回合结束时重置
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_LEVEL)
			e2:SetValue(lv)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
	end
end
