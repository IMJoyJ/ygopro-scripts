--再転
-- 效果：
-- ①：1回合1次，以场上1只持有和原本等级不同等级的怪兽为对象才能把这个效果发动。掷1次骰子。作为对象的怪兽的等级变成和出现的数目相同。
function c96015976.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，以场上1只持有和原本等级不同等级的怪兽为对象才能把这个效果发动。掷1次骰子。作为对象的怪兽的等级变成和出现的数目相同。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(96015976,0))  --"等级变化"
	e2:SetCategory(CATEGORY_DICE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetTarget(c96015976.target)
	e2:SetOperation(c96015976.operation)
	c:RegisterEffect(e2)
end
-- 过滤场上表侧表示、当前等级与原本等级不同且原本等级不为0的怪兽
function c96015976.filter(c)
	local lv=c:GetLevel()
	local olv=c:GetOriginalLevel()
	return c:IsFaceup() and lv~=0 and lv~=olv and olv~=0
end
-- 效果发动的对象选择与判定，确认并选择场上1只满足条件的怪兽作为对象
function c96015976.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c96015976.filter(chkc) end
	-- 在发动阶段检查场上是否存在至少1只满足条件的怪兽作为可选对象
	if chk==0 then return Duel.IsExistingTarget(c96015976.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向发动效果的玩家发送提示信息，要求选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只满足条件的怪兽作为效果的对象
	Duel.SelectTarget(tp,c96015976.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理，掷1次骰子，并将作为对象的怪兽的等级变成和出现的数目相同
function c96015976.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 让发动效果的玩家掷1次骰子，并获取骰子结果
		local dc=Duel.TossDice(tp,1)
		-- 作为对象的怪兽的等级变成和出现的数目相同。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(dc)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
