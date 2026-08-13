--次元同異体ヴァリス
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡不会被和与这张卡种族或者属性相同的怪兽的战斗破坏。
-- ②：宣言种族和属性各1个才能发动。这张卡直到对方回合结束时变成宣言的种族·属性。
function c52254878.initial_effect(c)
	-- ①：这张卡不会被和与这张卡种族或者属性相同的怪兽的战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(c52254878.batfilter)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：宣言种族和属性各1个才能发动。这张卡直到对方回合结束时变成宣言的种族·属性。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,52254878)
	e2:SetTarget(c52254878.artg)
	e2:SetOperation(c52254878.arop)
	c:RegisterEffect(e2)
end
-- 判定战斗对象（c）是否与这张卡当前的种族或属性相同，若相同则返回真，使这张卡不被该怪兽战斗破坏。
function c52254878.batfilter(e,c)
	local bc=e:GetHandler()
	return c:IsAttribute(bc:GetAttribute()) or c:IsRace(bc:GetRace())
end
-- 作为②效果的发动处理：确认可以发动后，让玩家宣言1个种族和1个属性，并将宣言结果存入效果标签，供效果处理时使用。
function c52254878.artg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向玩家tp显示“请选择要宣言的种族”的提示信息，用于种族宣言的选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	-- 让玩家tp从全部种族中宣言1个种族，返回所宣言的种族值。
	local rac=Duel.AnnounceRace(tp,1,RACE_ALL)
	-- 向玩家tp显示“请选择要宣言的属性”的提示信息，用于属性宣言的选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家tp从全部属性中宣言1个属性，返回所宣言的属性值。
	local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
	e:SetLabel(rac,att)
end
-- 效果处理：若这张卡仍与效果关联且表侧表示，则给它赋予改变属性和改变种族的持续效果，使其直到对方回合结束时变成宣言的种族·属性。
function c52254878.arop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rac,att=e:GetLabel()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 对应②：这张卡直到对方回合结束时变成宣言的种族·属性（此处实现改变属性的部分）。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(att)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		c:RegisterEffect(e1)
		-- 对应②：这张卡直到对方回合结束时变成宣言的种族·属性（此处实现改变种族的部分）。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_RACE)
		e2:SetValue(rac)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		c:RegisterEffect(e2)
	end
end
