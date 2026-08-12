--攻撃誘導アーマー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己或者对方的怪兽的攻击宣言时，可以从以下效果选择1个发动。
-- ●那只攻击怪兽破坏。
-- ●以那只攻击怪兽以外的自己或者对方场上1只怪兽为对象才能发动。攻击对象转移为那只怪兽进行伤害计算。
function c3103067.initial_effect(c)
	-- 效果发动时的初始化设置，包括类型、触发时点、发动次数限制、目标函数和处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,3103067+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c3103067.target)
	e1:SetOperation(c3103067.operation)
	c:RegisterEffect(e1)
end
-- 效果处理的目标函数，用于选择发动效果的选项
function c3103067.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取当前正在战斗中的攻击怪兽和防守怪兽
	local a,d=Duel.GetBattleMonster(0)
	local ad=Group.FromCards(a,d)
	local s=0
	-- 判断是否存在可以成为效果对象的怪兽
	local b=Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,ad)
	if b then
		-- 让玩家选择发动效果的选项（破坏攻击怪兽或转移攻击对象）
		s=Duel.SelectOption(tp,aux.Stringid(3103067,0),aux.Stringid(3103067,1))  --"攻击怪兽破坏/攻击对象转移"
	end
	e:SetLabel(s)
	if s==0 then
		-- 设置连锁操作信息，表示将要破坏攻击怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,a,1,0,0)
	end
	if s==1 then
		-- 提示玩家选择效果的对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 选择一个怪兽作为效果的对象
		Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,ad)
	end
end
-- 效果处理的执行函数，根据选择的选项执行不同的效果
function c3103067.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击的怪兽
	local a=Duel.GetAttacker()
	if e:GetLabel()==0 then
		if a and a:IsRelateToBattle() then
			-- 将攻击怪兽破坏
			Duel.Destroy(a,REASON_EFFECT)
		end
	end
	if e:GetLabel()==1 then
		-- 获取当前连锁中指定的目标怪兽
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) and a:IsAttackable() and not a:IsImmuneToEffect(e) then
			-- 进行攻击伤害计算，将攻击对象转移给指定怪兽
			Duel.CalculateDamage(a,tc)
		end
	end
end
