--SR赤目のダイス
-- 效果：
-- ①：这张卡召唤·特殊召唤成功时，以「疾行机人 赤目骰子」以外的自己场上1只「疾行机人」怪兽为对象，宣言1～6的任意等级才能发动。那只怪兽的等级直到回合结束时变成宣言的等级。
function c16725505.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功时，以「疾行机人 赤目骰子」以外的自己场上1只「疾行机人」怪兽为对象，宣言1～6的任意等级才能发动。
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
-- 筛选函数：表侧表示、卡名含有「疾行机人」、不是「疾行机人 赤目骰子」本身且等级大于0的怪兽。
function c16725505.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x2016) and not c:IsCode(16725505) and c:GetLevel()>0
end
-- Target 处理函数：确认对象位置，检查场上是否存在可选择的合法目标，选取1只「疾行机人」怪兽为对象并宣言1～6的任意等级。
function c16725505.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c16725505.filter(chkc) end
	-- 发动条件检查：确认自己主要怪兽区存在至少1只可作为对象的满足条件的「疾行机人」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c16725505.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示消息「请选择表侧表示的卡」，用于引导选择效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从自己主要怪兽区选择1只满足条件的「疾行机人」怪兽，并将其设置为本连锁效果的对象。
	local g=Duel.SelectTarget(tp,c16725505.filter,tp,LOCATION_MZONE,0,1,1,nil)
	local lv=g:GetFirst():GetLevel()
	-- 向玩家发送提示消息，提示接下来需要宣言等级。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	-- 让玩家宣言1～6中的任意等级（对象怪兽当前的等级除外），并将宣言的等级存入效果标签。
	e:SetLabel(Duel.AnnounceLevel(tp,1,6,lv))
end
-- Operation 处理函数：取得效果对象，若其仍表侧表示且与本效果关联，则赋予其等级变成宣言等级的效果，直到回合结束。
function c16725505.op(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁效果的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的等级直到回合结束时变成宣言的等级。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
