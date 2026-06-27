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
-- 得到效果的处理操作：根据墓地中同名卡数量进行分支选择
function c10032958.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 统计我方墓地中存在的同名「神龙-艾克塞利翁」数量
	local ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,10032958)
	if ct>3 then ct=3 end
	if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 提示选择获得的第一个效果
		local opt1=Duel.SelectOption(tp,aux.Stringid(10032958,1),aux.Stringid(10032958,2),aux.Stringid(10032958,3))  --"攻击力上升1000/战斗破坏对方怪兽的场合，只有1次可以再度攻击/战斗破坏怪兽送去墓地时，给予对方基本分破坏怪兽的攻击力数值的伤害"
		local opt2=0
		local opt3=0
		c10032958.reg(c,opt1)
		if ct<2 then return end
		-- 若第一个效果选择攻击力上升，则选择获得的第二个效果
		if opt1==0 then opt2=Duel.SelectOption(tp,aux.Stringid(10032958,2),aux.Stringid(10032958,3))+1  --"战斗破坏对方怪兽的场合，只有1次可以再度攻击/战斗破坏怪兽送去墓地时，给予对方基本分破坏怪兽的攻击力数值的伤害"
		-- 若第一个效果选择战斗伤害效果，则选择获得的第二个效果
		elseif opt1==2 then opt2=Duel.SelectOption(tp,aux.Stringid(10032958,1),aux.Stringid(10032958,2))  --"攻击力上升1000/战斗破坏对方怪兽的场合，只有1次可以再度攻击"
		else
			-- 若第一个效果选择追击效果，则选择获得的第二个效果
			opt2=Duel.SelectOption(tp,aux.Stringid(10032958,1),aux.Stringid(10032958,3))  --"攻击力上升1000/战斗破坏怪兽送去墓地时，给予对方基本分破坏怪兽的攻击力数值的伤害"
			if opt2==1 then opt2=2 end
		end
		c10032958.reg(c,opt2)
		if ct<3 then return end
		-- 若前两个效果都不包含攻击力上升，则直接获得攻击力上升效果
		if opt1~=0 and opt2~=0 then opt3=Duel.SelectOption(tp,aux.Stringid(10032958,1))  --"攻击力上升1000"
		-- 若前两个效果都不包含追击效果，则直接获得追击效果
		elseif opt1~=1 and opt2~=1 then opt3=Duel.SelectOption(tp,aux.Stringid(10032958,2))+1  --"战斗破坏对方怪兽的场合，只有1次可以再度攻击"
		-- 若前两个效果都不包含战斗伤害效果，则直接获得战斗伤害效果
		else opt3=Duel.SelectOption(tp,aux.Stringid(10032958,3))+2 end  --"战斗破坏怪兽送去墓地时，给予对方基本分破坏怪兽的攻击力数值的伤害"
		c10032958.reg(c,opt3)
	end
end
-- 为本卡注册所选的效果属性
function c10032958.reg(c,opt)
	if opt==0 then
		-- 获得效果：攻击力上升1000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	elseif opt==1 then
		-- 获得效果：战斗破坏对方怪兽的场合，只有1次可以再度攻击
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(10032958,2))  --"战斗破坏对方怪兽的场合，只有1次可以再度攻击"
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_BATTLE_DESTROYING)
		e1:SetCondition(c10032958.atcon)
		e1:SetOperation(c10032958.atop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	else
		-- 获得效果：战斗破坏怪兽送去墓地时，给予对方等同于该怪兽攻击力数值的伤害
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(10032958,3))  --"战斗破坏怪兽送去墓地时，给予对方基本分破坏怪兽的攻击力数值的伤害"
		e1:SetCategory(CATEGORY_DAMAGE)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EVENT_BATTLE_DESTROYING)
		-- 条件限制：限制必须是战斗破坏怪兽送入墓地
		e1:SetCondition(aux.bdgcon)
		e1:SetTarget(c10032958.damtg)
		e1:SetOperation(c10032958.damop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 再度攻击效果触发条件检查：战斗破坏对方怪兽且本卡能再次攻击
function c10032958.atcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查战斗破坏对方怪兽状态以及追击可行性
	return aux.bdocon(e,tp,eg,ep,ev,re,r,rp) and e:GetHandler():IsChainAttackable()
end
-- 再度攻击效果实际执行
function c10032958.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 进行追击宣言
	Duel.ChainAttack()
end
-- 伤害效果目标锁定：锁定对方玩家并确定破坏怪兽的攻击力
function c10032958.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local dam=bc:GetAttack()
	if dam<0 then dam=0 end
	-- 设置效果目标为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果伤害数值为破坏怪兽的攻击力
	Duel.SetTargetParam(dam)
	-- 声明对玩家造成伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 伤害效果实际操作：造成生命值伤害
function c10032958.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取预设的目标玩家和伤害量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对对方玩家造成生命值伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
