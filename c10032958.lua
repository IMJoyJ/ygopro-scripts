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
-- 通常召唤成功时的效果处理：计算墓地同名卡数量，并根据数量选择获得不同的效果（最多3个，不能重复）
function c10032958.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 计算自己墓地存在的「神龙-艾克塞利翁」的数量
	local ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,10032958)
	if ct>3 then ct=3 end
	if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 让玩家从所有可选效果中选择第1个要获得的效果
		local opt1=Duel.SelectOption(tp,aux.Stringid(10032958,1),aux.Stringid(10032958,2),aux.Stringid(10032958,3))  --"攻击力上升1000/战斗破坏对方怪兽的场合，只有1次可以再度攻击/战斗破坏怪兽送去墓地时，给予对方基本分破坏怪兽的攻击力数值的伤害"
		local opt2=0
		local opt3=0
		c10032958.reg(c,opt1)
		if ct<2 then return end
		-- 若第1个效果选了“攻击力上升1000”，则在剩余的“再攻击”和“战斗破坏伤害”中选择第2个效果
		if opt1==0 then opt2=Duel.SelectOption(tp,aux.Stringid(10032958,2),aux.Stringid(10032958,3))+1  --"战斗破坏对方怪兽的场合，只有1次可以再度攻击/战斗破坏怪兽送去墓地时，给予对方基本分破坏怪兽的攻击力数值的伤害"
		-- 若第1个效果选了“战斗破坏伤害”，则在剩余的“攻击力上升1000”和“再攻击”中选择第2个效果
		elseif opt1==2 then opt2=Duel.SelectOption(tp,aux.Stringid(10032958,1),aux.Stringid(10032958,2))  --"攻击力上升1000/战斗破坏对方怪兽的场合，只有1次可以再度攻击"
		else
			-- 若第1个效果选了“再攻击”，则在剩余的“攻击力上升1000”和“战斗破坏伤害”中选择第2个效果
			opt2=Duel.SelectOption(tp,aux.Stringid(10032958,1),aux.Stringid(10032958,3))  --"攻击力上升1000/战斗破坏怪兽送去墓地时，给予对方基本分破坏怪兽的攻击力数值的伤害"
			if opt2==1 then opt2=2 end
		end
		c10032958.reg(c,opt2)
		if ct<3 then return end
		-- 若前两个效果都不是“攻击力上升1000”，则第3个效果必定选择“攻击力上升1000”
		if opt1~=0 and opt2~=0 then opt3=Duel.SelectOption(tp,aux.Stringid(10032958,1))  --"攻击力上升1000"
		-- 若前两个效果都不是“可以再度攻击”，则第3个效果必定选择“可以再度攻击”
		elseif opt1~=1 and opt2~=1 then opt3=Duel.SelectOption(tp,aux.Stringid(10032958,2))+1  --"战斗破坏对方怪兽的场合，只有1次可以再度攻击"
		-- 若前两个效果都不是“战斗破坏伤害”，则第3个效果必定选择“战斗破坏伤害”
		else opt3=Duel.SelectOption(tp,aux.Stringid(10032958,3))+2 end  --"战斗破坏怪兽送去墓地时，给予对方基本分破坏怪兽的攻击力数值的伤害"
		c10032958.reg(c,opt3)
	end
end
-- 根据玩家的选择，为这张卡注册并赋予对应的效果
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
		-- 设置效果触发条件：这张卡战斗破坏对方怪兽并送去墓地
		e1:SetCondition(aux.bdgcon)
		e1:SetTarget(c10032958.damtg)
		e1:SetOperation(c10032958.damop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 再度攻击效果的Condition条件函数：检查是否战斗破坏对方怪兽，且自身能进行连击
function c10032958.atcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否战斗破坏对方怪兽且自身可以进行连击
	return aux.bdocon(e,tp,eg,ep,ev,re,r,rp) and e:GetHandler():IsChainAttackable()
end
-- 再度攻击效果的Operation处理函数：允许进行连击
function c10032958.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 使攻击怪兽可以再进行一次攻击
	Duel.ChainAttack()
end
-- 给与对方战斗破坏怪兽攻击力伤害效果的Target目标函数：设置目标玩家为对方，伤害数值为被破坏怪兽的攻击力，并注册伤害操作信息
function c10032958.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local dam=bc:GetAttack()
	if dam<0 then dam=0 end
	-- 设置当前连锁的对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的对象参数为伤害数值
	Duel.SetTargetParam(dam)
	-- 设置效果分类为伤害，目标为对方，伤害量为被破坏怪兽的攻击力
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 给与对方战斗破坏怪兽攻击力伤害效果的Operation处理函数：获取连锁的伤害目标与伤害数值，并给与对方伤害
function c10032958.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的对象玩家与伤害数值参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与对方基本分相应的效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
