--ホープ・バスター
-- 效果：
-- 自己场上有名字带有「希望皇 霍普」的怪兽存在的场合才能发动。对方场上1只攻击力最低的怪兽破坏，给与对方基本分破坏的怪兽的攻击力数值的伤害。
function c30341772.initial_effect(c)
	-- 效果定义：发动时需满足条件，破坏对方场上攻击力最低的怪兽并造成等量伤害
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c30341772.condition)
	e1:SetTarget(c30341772.target)
	e1:SetOperation(c30341772.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查场上是否存在表侧表示且名字带有「希望皇 霍普」的怪兽
function c30341772.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x107f)
end
-- 发动条件：自己场上有名字带有「希望皇 霍普」的怪兽存在
function c30341772.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张名字带有「希望皇 霍普」的表侧表示怪兽
	return Duel.IsExistingMatchingCard(c30341772.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：检查场上是否存在表侧表示的怪兽
function c30341772.filter(c)
	return c:IsFaceup()
end
-- 效果处理：设置连锁处理信息，确定破坏和造成伤害的目标
function c30341772.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1张表侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c30341772.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有表侧表示怪兽的集合
	local g=Duel.GetMatchingGroup(c30341772.filter,tp,0,LOCATION_MZONE,nil)
	local tg=g:GetMinGroup(Card.GetAttack)
	-- 设置破坏效果的操作信息，目标为攻击力最低的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
	-- 设置伤害效果的操作信息，目标为对方玩家，伤害值为破坏怪兽的攻击力
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,tg:GetFirst():GetAttack())
end
-- 效果发动：处理破坏和伤害的具体逻辑
function c30341772.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示怪兽的集合
	local g=Duel.GetMatchingGroup(c30341772.filter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		local tc=nil
		local tg=g:GetMinGroup(Card.GetAttack)
		if tg:GetCount()>1 then
			-- 提示玩家选择要破坏的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=tg:Select(tp,1,1,nil)
			-- 显示所选怪兽被选为破坏对象的动画效果
			Duel.HintSelection(sg)
			tc=sg:GetFirst()
		else
			tc=tg:GetFirst()
		end
		local atk=tc:GetAttack()
		-- 执行破坏操作，若成功则继续造成伤害
		if Duel.Destroy(tc,REASON_EFFECT)>0 then
			-- 给与对方基本分等同于被破坏怪兽攻击力的伤害
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end
