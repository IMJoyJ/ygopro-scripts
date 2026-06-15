--神竜－エクセリオン
-- 效果：
-- 这张卡召唤时自己墓地存在的「神龙-艾克塞利翁」每有1只，得到以下的其中1个效果。但是相同的效果不能重复得到。
-- ●这张卡攻击力上升1000。
-- ●这张卡战斗破坏对方怪兽的场合，只有1次可以再度攻击。
-- ●这张卡战斗破坏怪兽送去墓地时，给与对方基本分破坏怪兽的攻击力数值的伤害。
function c10032958.initial_effect(c)
	-- 这张卡召唤时自己墓地存在的「神龙-艾克塞利翁」每有1只，得到以下的其中1个效果。但是相同的效果不能重复得到。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10032958,0))  --"得到效果"
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c10032958.effop)
	c:RegisterEffect(e1)
end
-- 召唤成功时获得效果的执行操作：统计墓地中同名卡的数量（最多3只），并根据数量依次选择并获得对应效果（相同的效果不可重复选择）
function c10032958.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 统计自己墓地中卡名为「神龙-艾克塞利翁」的卡片数量
	local ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,10032958)
	if ct>3 then ct=3 end
	if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 让玩家从尚未获得的效果中选择一个得到
		local opt1=Duel.SelectOption(tp,aux.Stringid(10032958,1),aux.Stringid(10032958,2),aux.Stringid(10032958,3))  --"攻击力上升1000/战斗破坏对方怪兽的场合，只有1次可以再度攻击/战斗破坏怪兽送去墓地时，给予对方基本分破坏怪兽的攻击力数值的伤害"
		local opt2=0
		local opt3=0
		c10032958.reg(c,opt1)
		if ct<2 then return end
		-- 如果第一个选择的是「攻击力上升1000」，则在剩下的两个效果中进行选择
		if opt1==0 then opt2=Duel.SelectOption(tp,aux.Stringid(10032958,2),aux.Stringid(10032958,3))+1  --"战斗破坏对方怪兽的场合，只有1次可以再度攻击/战斗破坏怪兽送去墓地时，给予对方基本分破坏怪兽的攻击力数值的伤害"
		-- 如果第一个选择的是「战斗破坏怪兽送去墓地时给予伤害」，则在「攻击力上升1000」和「再度攻击」中选择
		elseif opt1==2 then opt2=Duel.SelectOption(tp,aux.Stringid(10032958,1),aux.Stringid(10032958,2))  --"攻击力上升1000/战斗破坏对方怪兽的场合，只有1次可以再度攻击"
		else
			-- 如果第一个选择的是「再度攻击」，则在「攻击力上升1000」和「战斗破坏怪兽送去墓地时给予伤害」中选择
			opt2=Duel.SelectOption(tp,aux.Stringid(10032958,1),aux.Stringid(10032958,3))  --"攻击力上升1000/战斗破坏怪兽送去墓地时，给予对方基本分破坏怪兽的攻击力数值的伤害"
			if opt2==1 then opt2=2 end
		end
		c10032958.reg(c,opt2)
		if ct<3 then return end
		-- 如果前两次选择了非「攻击力上升1000」的效果，则最后只能获得「攻击力上升1000」
		if opt1~=0 and opt2~=0 then opt3=Duel.SelectOption(tp,aux.Stringid(10032958,1))  --"攻击力上升1000"
		-- 如果前两次选择了非「再度攻击」的效果，则最后只能获得「再度攻击」
		elseif opt1~=1 and opt2~=1 then opt3=Duel.SelectOption(tp,aux.Stringid(10032958,2))+1  --"战斗破坏对方怪兽的场合，只有1次可以再度攻击"
		-- 如果前两次选择了非「战斗破坏怪兽送去墓地时给予伤害」的效果，则最后只能获得「战斗破坏怪兽送去墓地时给予伤害」
		else opt3=Duel.SelectOption(tp,aux.Stringid(10032958,3))+2 end  --"战斗破坏怪兽送去墓地时，给予对方基本分破坏怪兽的攻击力数值的伤害"
		c10032958.reg(c,opt3)
	end
end
-- 注册获得的效果：根据玩家的选择，为这张卡注册攻击力上升、再度攻击或伤害效果
function c10032958.reg(c,opt)
	if opt==0 then
		-- ●这张卡攻击力上升1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	elseif opt==1 then
		-- ●这张卡战斗破坏对方怪兽的场合，只有1次可以再度攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(10032958,2))  --"战斗破坏对方怪兽的场合，只有1次可以再度攻击"
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_BATTLE_DESTROYING)
		e1:SetCondition(c10032958.atcon)
		e1:SetOperation(c10032958.atop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	else
		-- ●这张卡战斗破坏怪兽送去墓地时，给与对方基本分破坏怪兽的攻击力数值的伤害。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(10032958,3))  --"战斗破坏怪兽送去墓地时，给予对方基本分破坏怪兽的攻击力数值的伤害"
		e1:SetCategory(CATEGORY_DAMAGE)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EVENT_BATTLE_DESTROYING)
		-- 过滤/发动条件：检测是否将对方的怪兽战斗破坏并送去墓地
		e1:SetCondition(aux.bdgcon)
		e1:SetTarget(c10032958.damtg)
		e1:SetOperation(c10032958.damop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 追击效果的发动条件：检测是否进行了战斗且符合可以再度攻击的条件
function c10032958.atcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为与对方怪兽战斗，且这张卡在当前战斗步骤中允许进行连续攻击
	return aux.bdocon(e,tp,eg,ep,ev,re,r,rp) and e:GetHandler():IsChainAttackable()
end
-- 追击效果的执行操作：使这张卡可以再进行1次攻击
function c10032958.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 使攻击卡可以再进行1次攻击
	Duel.ChainAttack()
end
-- 伤害效果的目标检测：计算被破坏怪兽的攻击力，并注册伤害操作的目标与数值
function c10032958.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local dam=bc:GetAttack()
	if dam<0 then dam=0 end
	-- 设置效果的攻击目标玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将本次效果要扣除的生命值参数设置成被破坏怪兽的攻击力
	Duel.SetTargetParam(dam)
	-- 设置操作信息：在连锁中注册伤害操作，目标为对方玩家，数值为被破坏怪兽的攻击力
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 伤害效果的执行操作：给与对方玩家被破坏怪兽攻击力数值的伤害
function c10032958.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中登记的伤害目标玩家和伤害参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因给予指定玩家伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
