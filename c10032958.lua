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
-- 效果处理函数，用于处理召唤成功时的效果选择与注册
function c10032958.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 统计自己墓地里「神龙-艾克塞利翁」的数量
	local ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,10032958)
	if ct>3 then ct=3 end
	if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 让玩家从三个效果中选择一个作为第一个效果
		local opt1=Duel.SelectOption(tp,aux.Stringid(10032958,1),aux.Stringid(10032958,2),aux.Stringid(10032958,3))  --"攻击力上升1000"
		local opt2=0
		local opt3=0
		c10032958.reg(c,opt1)
		if ct<2 then return end
		-- 如果第一个选择的是效果1（攻击力上升1000），则从效果2和3中选择第二个效果
		if opt1==0 then opt2=Duel.SelectOption(tp,aux.Stringid(10032958,2),aux.Stringid(10032958,3))+1  --"战斗破坏对方怪兽的场合，只有1次可以再度攻击"
		-- 如果第一个选择的是效果3（战斗破坏怪兽送去墓地时给予伤害），则从效果1和2中选择第二个效果
		elseif opt1==2 then opt2=Duel.SelectOption(tp,aux.Stringid(10032958,1),aux.Stringid(10032958,2))  --"攻击力上升1000"
		else
			-- 如果第一个选择的是效果2（战斗破坏对方怪兽的场合，只有1次可以再度攻击），则从效果1和3中选择第二个效果
			opt2=Duel.SelectOption(tp,aux.Stringid(10032958,1),aux.Stringid(10032958,3))  --"攻击力上升1000"
			if opt2==1 then opt2=2 end
		end
		c10032958.reg(c,opt2)
		if ct<3 then return end
		-- 如果前两个效果都不是效果1，则从效果1中选择第三个效果
		if opt1~=0 and opt2~=0 then opt3=Duel.SelectOption(tp,aux.Stringid(10032958,1))  --"攻击力上升1000"
		-- 如果前两个效果都不是效果2，则从效果2中选择第三个效果
		elseif opt1~=1 and opt2~=1 then opt3=Duel.SelectOption(tp,aux.Stringid(10032958,2))+1  --"战斗破坏对方怪兽的场合，只有1次可以再度攻击"
		-- 否则从效果3中选择第三个效果
		else opt3=Duel.SelectOption(tp,aux.Stringid(10032958,3))+2 end  --"战斗破坏怪兽送去墓地时，给予对方基本分破坏怪兽的攻击力数值的伤害"
		c10032958.reg(c,opt3)
	end
end
-- 注册效果函数，根据选择的选项注册对应的效果
function c10032958.reg(c,opt)
	if opt==0 then
		-- 效果1：这张卡攻击力上升1000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	elseif opt==1 then
		-- 效果2：这张卡战斗破坏对方怪兽的场合，只有1次可以再度攻击
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(10032958,2))  --"战斗破坏对方怪兽的场合，只有1次可以再度攻击"
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_BATTLE_DESTROYING)
		e1:SetCondition(c10032958.atcon)
		e1:SetOperation(c10032958.atop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	else
		-- 效果3：这张卡战斗破坏怪兽送去墓地时，给与对方基本分破坏怪兽的攻击力数值的伤害
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(10032958,3))  --"战斗破坏怪兽送去墓地时，给予对方基本分破坏怪兽的攻击力数值的伤害"
		e1:SetCategory(CATEGORY_DAMAGE)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EVENT_BATTLE_DESTROYING)
		-- 设置效果3的触发条件为战斗破坏对方怪兽并送入墓地
		e1:SetCondition(aux.bdgcon)
		e1:SetTarget(c10032958.damtg)
		e1:SetOperation(c10032958.damop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 判断是否可以进行连锁攻击的条件函数
function c10032958.atcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否与对方怪兽战斗并且可以连锁攻击
	return aux.bdocon(e,tp,eg,ep,ev,re,r,rp) and e:GetHandler():IsChainAttackable()
end
-- 连锁攻击的效果处理函数
function c10032958.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 使攻击卡可以再进行1次攻击
	Duel.ChainAttack()
end
-- 伤害效果的目标设定函数
function c10032958.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local dam=bc:GetAttack()
	if dam<0 then dam=0 end
	-- 设置连锁效果的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁效果的目标参数为伤害值
	Duel.SetTargetParam(dam)
	-- 设置连锁效果的操作信息为造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 伤害效果的处理函数
function c10032958.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁效果的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定数值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
