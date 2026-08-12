--錬金生物 ホムンクルス
-- 效果：
-- 这只怪兽的属性可以改变。这个效果1回合可以使用1次。
function c40410110.initial_effect(c)
	-- 这只怪兽的属性可以改变。这个效果1回合可以使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40410110,0))  --"改变属性"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetOperation(c40410110.attop)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组，将目标怪兽特殊召唤
function c40410110.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 向玩家提示“请选择要宣言的属性”
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
		local catt=c:GetAttribute()
		-- 让玩家从可选的属性中宣言1个属性
		local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~catt)
		-- 改变属性
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(att)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
