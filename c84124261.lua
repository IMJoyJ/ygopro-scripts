--No.39 希望皇ホープ・ルーツ
-- 效果：
-- 1星怪兽×2
-- ①：自己或者对方怪兽的攻击宣言时，把这张卡1个超量素材取除才能发动。那次攻击无效，那只怪兽是超量怪兽的场合，这张卡的攻击力上升那只怪兽的阶级×500。
function c84124261.initial_effect(c)
	-- 添加超量召唤手续：1星怪兽×2
	aux.AddXyzProcedure(c,nil,1,2)
	c:EnableReviveLimit()
	-- ①：自己或者对方怪兽的攻击宣言时，把这张卡1个超量素材取除才能发动。那次攻击无效，那只怪兽是超量怪兽的场合，这张卡的攻击力上升那只怪兽的阶级×500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84124261,0))  --"攻击无效"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCost(c84124261.atkcost)
	e1:SetTarget(c84124261.atktg)
	e1:SetOperation(c84124261.atkop)
	c:RegisterEffect(e1)
end
-- 设置该卡属于“No.”系列，编号为39
aux.xyz_number[84124261]=39
-- 效果①的发动代价：把这张卡1个超量素材取除
function c84124261.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果①的目标选择：将攻击怪兽作为效果对象
function c84124261.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前进行攻击宣言的怪兽作为效果处理的对象
	Duel.SetTargetCard(Duel.GetAttacker())
end
-- 效果①的效果处理：无效攻击，若攻击怪兽是超量怪兽，则这张卡攻击力上升该怪兽阶级×500
function c84124261.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的攻击怪兽
	local tc=Duel.GetFirstTarget()
	-- 若成功无效攻击，且该攻击怪兽是表侧表示的超量怪兽
	if Duel.NegateAttack() and tc:IsType(TYPE_XYZ) and tc:IsFaceup()
		and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力上升那只怪兽的阶级×500
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetRank()*500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
