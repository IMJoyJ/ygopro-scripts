--No.96 ブラック・ミスト
-- 效果：
-- 2星怪兽×3
-- ①：这张卡和对方的表侧表示怪兽进行战斗的攻击宣言时1次，把这张卡1个超量素材取除才能发动。那只对方怪兽的攻击力变成一半，这张卡的攻击力上升那个数值。
function c55727845.initial_effect(c)
	-- 设置XYZ召唤手续：2星怪兽×3
	aux.AddXyzProcedure(c,nil,2,3)
	c:EnableReviveLimit()
	-- ①：这张卡和对方的表侧表示怪兽进行战斗的攻击宣言时1次，把这张卡1个超量素材取除才能发动。那只对方怪兽的攻击力变成一半，这张卡的攻击力上升那个数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55727845,0))  --"攻击上升"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c55727845.atkcost)
	e1:SetTarget(c55727845.atktg)
	e1:SetOperation(c55727845.atkop)
	c:RegisterEffect(e1)
end
-- 设置该卡片的No.编号为96
aux.xyz_number[55727845]=96
-- 发动的代价：移除这张卡的1个超量素材
function c55727845.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果发动的目标检查与选择：确认此卡是否在与对方表侧表示怪兽进行战斗，并选择该战斗对象
function c55727845.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前的攻击对象
	local at=Duel.GetAttackTarget()
	-- 在第1步（chk==0）检查此卡是否作为攻击方与对方表侧表示怪兽战斗，或作为被攻击方进行战斗
	if chk==0 then return ((at and at:IsFaceup() and Duel.GetAttacker()==e:GetHandler()) or at==e:GetHandler())
		and not e:GetHandler():IsStatus(STATUS_CHAINING) end
	-- 将与这张卡进行战斗的对方怪兽设为效果处理的对象
	Duel.SetTargetCard(e:GetHandler():GetBattleTarget())
end
-- 效果处理：使目标对方怪兽的攻击力变成一半，并使这张卡的攻击力上升该数值
function c55727845.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被设为对象的对方怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
		local atk=math.ceil(tc:GetAttack()/2)
		-- 那只对方怪兽的攻击力变成一半
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这张卡的攻击力上升那个数值
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(atk)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
