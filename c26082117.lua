--ガガガマジシャン
-- 效果：
-- 这张卡不能作为同调素材。
-- ①：「我我我魔术师」在自己场上只能有1只表侧表示存在。
-- ②：1回合1次，宣言1～8的任意等级才能发动。这张卡的等级直到回合结束时变成宣言的等级。
function c26082117.initial_effect(c)
	c:SetUniqueOnField(1,0,26082117)
	-- ②：1回合1次，宣言1～8的任意等级才能发动。这张卡的等级直到回合结束时变成宣言的等级。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26082117,0))  --"等级变化"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c26082117.tg)
	e1:SetOperation(c26082117.op)
	c:RegisterEffect(e1)
	-- 这张卡不能作为同调素材。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 设置效果目标函数，用于处理等级宣言的逻辑
function c26082117.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local lv=e:GetHandler():GetLevel()
	-- 向玩家提示“请宣言一个等级”的选择消息
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(26082117,1))  --"请宣言一个等级"
	-- 让玩家从1到8中宣言一个等级并记录在效果标签中
	e:SetLabel(Duel.AnnounceLevel(tp,1,8,lv))
end
-- 设置效果发动时的处理函数，用于改变卡片等级
function c26082117.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 将卡片等级修改为宣言的等级，并在回合结束时重置
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
