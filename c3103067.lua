--攻撃誘導アーマー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己或者对方的怪兽的攻击宣言时，可以从以下效果选择1个发动。
-- ●那只攻击怪兽破坏。
-- ●以那只攻击怪兽以外的自己或者对方场上1只怪兽为对象才能发动。攻击对象转移为那只怪兽进行伤害计算。
function c3103067.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己或者对方的怪兽的攻击宣言时，可以从以下效果选择1个发动。●那只攻击怪兽破坏。●以那只攻击怪兽以外的自己或者对方场上1只怪兽为对象才能发动。攻击对象转移为那只怪兽进行伤害计算。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,3103067+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c3103067.target)
	e1:SetOperation(c3103067.operation)
	c:RegisterEffect(e1)
end
-- 发动时目标处理：获取攻击怪兽与攻击对象，检查是否存在可转移的攻击对象以外的怪兽；若存在则让玩家选择“破坏攻击怪兽”或“转移攻击对象”，将选择记录到效果标签；选择破坏时登记破坏操作信息，选择转移时选择攻击对象以外的怪兽作为效果对象。
function c3103067.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取当前战斗中的攻击怪兽和攻击对象怪兽，分别存入 a 和 d（d 可能为 nil）。
	local a,d=Duel.GetBattleMonster(0)
	local ad=Group.FromCards(a,d)
	local s=0
	-- 检查双方主要怪兽区是否存在除攻击怪兽和当前攻击对象以外的怪兽，可作为“攻击对象转移”的候选目标。
	local b=Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,ad)
	if b then
		-- 让玩家从两个选项中选择：选项0为“那只攻击怪兽破坏”，选项1为“以攻击怪兽以外的怪兽为对象转移攻击”，返回选中编号存入 s。
		s=Duel.SelectOption(tp,aux.Stringid(3103067,0),aux.Stringid(3103067,1))  --"攻击怪兽破坏/攻击对象转移"
	end
	e:SetLabel(s)
	if s==0 then
		-- 将本连锁的操作信息登记为：破坏攻击怪兽 a，数量为1，分类为破坏效果。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,a,1,0,0)
	end
	if s==1 then
		-- 向玩家发出选择对象的提示消息，内容为“请选择效果的对象”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 让玩家从双方主要怪兽区选择1只除 ad 以外（即攻击怪兽和当前攻击对象以外）的怪兽，并将其设置为效果对象。
		Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,ad)
	end
end
-- 效果处理时按照效果标签执行：若标签为0则破坏攻击怪兽（若其仍与本次战斗关联）；若标签为1则取得对象怪兽，在对象仍关联、攻击怪兽可攻击且不免疫此效果时，令攻击怪兽与对象怪兽进行伤害计算。
function c3103067.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	if e:GetLabel()==0 then
		if a and a:IsRelateToBattle() then
			-- 以效果原因将攻击怪兽破坏。
			Duel.Destroy(a,REASON_EFFECT)
		end
	end
	if e:GetLabel()==1 then
		-- 获取效果发动时选择的对象怪兽。
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) and a:IsAttackable() and not a:IsImmuneToEffect(e) then
			-- 令攻击怪兽 a 与对象怪兽 tc 进行战斗伤害计算，即把攻击对象转移为 tc 并进行伤害计算。
			Duel.CalculateDamage(a,tc)
		end
	end
end
