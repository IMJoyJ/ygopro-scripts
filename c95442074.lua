--No.31 アベルズ・デビル
-- 效果：
-- 1星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。对方场上的全部怪兽变成表侧攻击表示，并在这个回合可以攻击的场合必须向这张卡作出攻击。这个效果在对方回合也能发动。
-- ②：只要自己场上有「No.13 该隐恶魔」存在，这张卡得到以下效果。
-- ●持有超量素材的这张卡不会被战斗·效果破坏。
-- ●向这张卡的攻击发生的对自己的战斗伤害由对方代受。
function c95442074.initial_effect(c)
	-- 设置XYZ召唤手续：1星怪兽×2。
	aux.AddXyzProcedure(c,nil,1,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。对方场上的全部怪兽变成表侧攻击表示，并在这个回合可以攻击的场合必须向这张卡作出攻击。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95442074,0))  --"变成表侧攻击"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c95442074.cost)
	e1:SetTarget(c95442074.target)
	e1:SetOperation(c95442074.operation)
	c:RegisterEffect(e1)
	-- ②：只要自己场上有「No.13 该隐恶魔」存在，这张卡得到以下效果。●持有超量素材的这张卡不会被战斗·效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetCondition(c95442074.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	-- ②：只要自己场上有「No.13 该隐恶魔」存在，这张卡得到以下效果。●向这张卡的攻击发生的对自己的战斗伤害由对方代受。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e4:SetCondition(c95442074.refcon)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
-- 设置该卡片的No.编号为31。
aux.xyz_number[95442074]=31
-- 效果①的Cost：把这张卡1个超量素材取除。
function c95442074.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果①的Target：确认对方场上是否存在怪兽。
function c95442074.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在怪兽。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 end
end
-- 效果①的Operation：将对方场上的全部怪兽变成表侧攻击表示，并在这个回合可以攻击的场合必须向这张卡作出攻击。
function c95442074.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上的全部怪兽。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	if g:GetCount()>0 then
		-- 将对方场上的全部怪兽变成表侧攻击表示。
		Duel.ChangePosition(g,POS_FACEUP_ATTACK)
		local fid=c:GetRealFieldID()
		local tc=g:GetFirst()
		while tc do
			-- 并在这个回合可以攻击的场合必须向这张卡作出攻击。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_MUST_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_MUST_ATTACK_MONSTER)
			e2:SetValue(c95442074.atklimit)
			e2:SetLabel(fid)
			tc:RegisterEffect(e2)
			tc=g:GetNext()
		end
	end
end
-- 限制攻击目标为这张卡。
function c95442074.atklimit(e,c)
	return c:GetRealFieldID()==e:GetLabel()
end
-- 过滤条件：自己场上表侧表示的「No.13 该隐恶魔」。
function c95442074.filter(c)
	return c:IsFaceup() and c:IsCode(69058960)
end
-- 破坏抗性效果的启用条件：自己场上有「No.13 该隐恶魔」存在，且这张卡持有超量素材。
function c95442074.indcon(e)
	-- 检查自己场上是否存在表侧表示的「No.13 该隐恶魔」。
	return Duel.IsExistingMatchingCard(c95442074.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
		and e:GetHandler():GetOverlayCount()~=0
end
-- 伤害反射效果的启用条件：自己场上有「No.13 该隐恶魔」存在，且这张卡被选为攻击对象。
function c95442074.refcon(e)
	-- 检查自己场上是否存在表侧表示的「No.13 该隐恶魔」。
	return Duel.IsExistingMatchingCard(c95442074.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
		-- 检查这张卡是否被选为攻击对象。
		and Duel.GetAttackTarget()==e:GetHandler()
end
