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
	-- ②：宣言种族和属性各1个才能发动。这张卡直到对方回合结束时变成宣言的种族·属性。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,52254878)
	e2:SetTarget(c52254878.artg)
	e2:SetOperation(c52254878.arop)
	c:RegisterEffect(e2)
end
-- 当攻击怪兽具有与自身相同属性或种族时，该怪兽无法破坏此卡。
function c52254878.batfilter(e,c)
	local bc=e:GetHandler()
	return c:IsAttribute(bc:GetAttribute()) or c:IsRace(bc:GetRace())
end
-- 选择并记录要宣言的种族和属性值。
function c52254878.artg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示玩家选择要宣言的种族。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	-- 让玩家从所有种族中选择1个种族进行宣言。
	local rac=Duel.AnnounceRace(tp,1,RACE_ALL)
	-- 提示玩家选择要宣言的属性。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家从所有属性中选择1个属性进行宣言。
	local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
	e:SetLabel(rac,att)
end
-- 将卡牌的属性和种族修改为宣言的值，直到对方回合结束。
function c52254878.arop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rac,att=e:GetLabel()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将卡牌的属性修改为宣言的属性值，直到对方回合结束。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(att)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		c:RegisterEffect(e1)
		-- 将卡牌的种族修改为宣言的种族值，直到对方回合结束。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_RACE)
		e2:SetValue(rac)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		c:RegisterEffect(e2)
	end
end
