--No.107 銀河眼の時空竜
-- 效果：
-- 8星怪兽×2
-- ①：自己战斗阶段开始时，把这张卡1个超量素材取除才能发动。这张卡以外的场上的全部表侧表示怪兽的效果无效化，那些攻击力·守备力变成原本数值。这个效果发动过的回合的战斗阶段中每次对方把魔法·陷阱·怪兽的效果发动，这张卡的攻击力直到战斗阶段结束时上升1000，这个回合，这张卡在同1次的战斗阶段中可以作2次攻击。
function c88177324.initial_effect(c)
	-- 添加XYZ召唤手续：需要2只8星怪兽
	aux.AddXyzProcedure(c,nil,8,2)
	c:EnableReviveLimit()
	-- ①：自己战斗阶段开始时，把这张卡1个超量素材取除才能发动。这张卡以外的场上的全部表侧表示怪兽的效果无效化，那些攻击力·守备力变成原本数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88177324,0))  --"效果无效化"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c88177324.negcon)
	e1:SetCost(c88177324.negcost)
	e1:SetTarget(c88177324.negtg)
	e1:SetOperation(c88177324.negop)
	c:RegisterEffect(e1)
	-- 这个效果发动过的回合的战斗阶段中每次对方把魔法·陷阱·怪兽的效果发动，这张卡的攻击力直到战斗阶段结束时上升1000，这个回合，这张卡在同1次的战斗阶段中可以作2次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetCondition(c88177324.regcon)
	e2:SetOperation(c88177324.regop)
	c:RegisterEffect(e2)
end
-- 设定该卡片的「No.」编号为107
aux.xyz_number[88177324]=107
-- 定义效果①的发动条件函数：检查是否为自己的回合
function c88177324.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 定义效果①的代价函数：取除这张卡的1个超量素材
function c88177324.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义过滤条件：场上表侧表示且当前攻击力或守备力不等于原本数值的怪兽
function c88177324.filter2(c)
	return c:IsFaceup() and (not c:IsAttack(c:GetBaseAttack()) or not c:IsDefense(c:GetBaseDefense()))
end
-- 定义过滤条件：场上表侧表示的效果怪兽
function c88177324.filter3(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 定义效果①的发动准备（Target）函数：检查场上是否存在除自身以外可以被无效化或攻守不等于原本数值的表侧表示怪兽
function c88177324.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return
		-- 检查场上是否存在至少1只除自身以外可以被无效效果的表侧表示效果怪兽
		Duel.IsExistingMatchingCard(aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler())
		-- 或者检查场上是否存在至少1只除自身以外攻守不等于原本数值的表侧表示怪兽
		or Duel.IsExistingMatchingCard(c88177324.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler())
	end
end
-- 定义效果①的效果处理（Operation）函数：将除自身以外的场上所有表侧表示怪兽效果无效，攻守变为原本数值，并为自身注册效果发动过的标记
function c88177324.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取除这张卡以外的卡片（若这张卡已离场则不排除）
	local exc=aux.ExceptThisCard(e)
	-- 获取场上除自身以外的所有表侧表示效果怪兽
	local g=Duel.GetMatchingGroup(c88177324.filter3,tp,LOCATION_MZONE,LOCATION_MZONE,exc)
	local tc=g:GetFirst()
	while tc do
		-- 这张卡以外的场上的全部表侧表示怪兽的效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这张卡以外的场上的全部表侧表示怪兽的效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
	-- 立即刷新场上怪兽的无效状态
	Duel.AdjustInstantly(c)
	-- 获取场上除自身以外的所有攻守不等于原本数值的表侧表示怪兽
	g=Duel.GetMatchingGroup(c88177324.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,exc)
	tc=g:GetFirst()
	while tc do
		if not tc:IsAttack(tc:GetBaseAttack()) then
			-- 那些攻击力·守备力变成原本数值
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(tc:GetBaseAttack())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
		if not tc:IsDefense(tc:GetBaseDefense()) then
			-- 那些攻击力·守备力变成原本数值
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
			e1:SetValue(tc:GetBaseDefense())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
		tc=g:GetNext()
	end
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		c:RegisterFlagEffect(88177324,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
	end
end
-- 定义效果②的发动条件函数：对方发动了卡片或效果，且本回合自身已成功发动过效果①
function c88177324.regcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():GetFlagEffect(88177324)>0
end
-- 定义效果②的效果处理（Operation）函数：提升自身1000点攻击力，并获得追加攻击1次的效果
function c88177324.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这张卡的攻击力直到战斗阶段结束时上升1000
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_BATTLE)
	c:RegisterEffect(e1)
	-- 这个回合，这张卡在同1次的战斗阶段中可以作2次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetValue(1)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	c:RegisterEffect(e2)
end
