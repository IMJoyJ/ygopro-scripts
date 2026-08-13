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
-- 发动条件判定：无特殊限制即可发动；发动时提示玩家宣言等级，并将宣言的等级保存到效果标签，供处理时改变这张卡的等级。
function c26082117.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local lv=e:GetHandler():GetLevel()
	-- 向发动玩家发送选择提示消息，提示其宣言一个1～8的等级。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(26082117,1))  --"请宣言一个等级"
	-- 让玩家宣言1～8的任意等级，并将宣言数值存入效果的Label，作为后续改变等级时使用的数值。
	e:SetLabel(Duel.AnnounceLevel(tp,1,8,lv))
end
-- 效果处理时，若这张卡仍表侧表示且与发动效果关联，则给它注册一个等级变更效果，使其等级变为宣言的等级，持续到回合结束，并在标准重置条件下失效。
function c26082117.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的等级直到回合结束时变成宣言的等级。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
