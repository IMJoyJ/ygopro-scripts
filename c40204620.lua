--メガリス・プロモーション
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：以自己场上1只4星以下的怪兽为对象才能发动。那只怪兽的等级直到回合结束时变成原本等级的2倍。
function c40204620.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- 效果原文内容：①：以自己场上1只4星以下的怪兽为对象才能发动。那只怪兽的等级直到回合结束时变成原本等级的2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40204620,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,40204620)
	e1:SetTarget(c40204620.lvtg)
	e1:SetOperation(c40204620.lvop)
	c:RegisterEffect(e1)
end
-- 检索满足条件的怪兽（表侧表示且等级为1~4星）
function c40204620.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(1) and c:IsLevelBelow(4)
end
-- 效果作用：选择对象怪兽（必须是自己场上的表侧表示的4星以下怪兽）
function c40204620.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c40204620.filter(chkc) end
	-- 判断是否满足发动条件（场上是否存在符合条件的怪兽）
	if chk==0 then return Duel.IsExistingTarget(c40204620.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择符合条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c40204620.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果作用：将选定怪兽的等级变为原本等级的2倍
function c40204620.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsLevelAbove(1) and tc:IsRelateToEffect(e) then
		local lv=tc:GetOriginalLevel()
		-- 效果原文内容：①：以自己场上1只4星以下的怪兽为对象才能发动。那只怪兽的等级直到回合结束时变成原本等级的2倍。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(lv*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
