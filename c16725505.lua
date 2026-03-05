--SR赤目のダイス
-- 效果：
-- ①：这张卡召唤·特殊召唤成功时，以「疾行机人 赤目骰子」以外的自己场上1只「疾行机人」怪兽为对象，宣言1～6的任意等级才能发动。那只怪兽的等级直到回合结束时变成宣言的等级。
function c16725505.initial_effect(c)
	-- 诱发效果，通常召唤成功时发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16725505,0))  --"等级变化"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c16725505.tg)
	e1:SetOperation(c16725505.op)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 筛选条件：表侧表示、疾行机人卡组、非赤目骰子、等级大于0
function c16725505.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x2016) and not c:IsCode(16725505) and c:GetLevel()>0
end
-- 选择目标：自己场上1只符合条件的怪兽
function c16725505.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c16725505.filter(chkc) end
	-- 检查是否有符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c16725505.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只符合条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,c16725505.filter,tp,LOCATION_MZONE,0,1,1,nil)
	local lv=g:GetFirst():GetLevel()
	-- 提示选择等级
	Duel.Hint(HINT_SELECTMSG,tp,HINGMSG_LVRANK)
	-- 宣言1～6的任意等级并记录
	e:SetLabel(Duel.AnnounceLevel(tp,1,6,lv))
end
-- 将目标怪兽的等级变为宣言的等级直到回合结束
function c16725505.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 设置目标怪兽的等级变化效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
