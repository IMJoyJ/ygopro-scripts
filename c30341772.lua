--ホープ・バスター
-- 效果：
-- 自己场上有名字带有「希望皇 霍普」的怪兽存在的场合才能发动。对方场上1只攻击力最低的怪兽破坏，给与对方基本分破坏的怪兽的攻击力数值的伤害。
function c30341772.initial_effect(c)
	-- 自己场上有名字带有「希望皇 霍普」的怪兽存在的场合才能发动。对方场上1只攻击力最低的怪兽破坏，给与对方基本分破坏的怪兽的攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c30341772.condition)
	e1:SetTarget(c30341772.target)
	e1:SetOperation(c30341772.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选函数：用于筛选表侧表示且字段为「希望皇 霍普」的怪兽。
function c30341772.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x107f)
end
-- 发动条件判定：检查自己场上是否存在至少1只表侧表示且字段为「希望皇 霍普」的怪兽。
function c30341772.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 具体检查：从自己主要怪兽区检索是否存在至少1只满足c30341772.cfilter条件的卡。
	return Duel.IsExistingMatchingCard(c30341772.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义筛选函数：筛选表侧表示的怪兽。
function c30341772.filter(c)
	return c:IsFaceup()
end
-- 发动时目标处理：确认对方场上有表侧表示怪兽；取得对方场上全部表侧表示怪兽，选出攻击力最低的一组；登记破坏1只怪兽及给予其攻击力数值伤害的操作信息。
function c30341772.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：仅在对方场上有至少1只表侧表示怪兽时才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c30341772.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 取得对方场上全部表侧表示怪兽作为候选组。
	local g=Duel.GetMatchingGroup(c30341772.filter,tp,0,LOCATION_MZONE,nil)
	local tg=g:GetMinGroup(Card.GetAttack)
	-- 登记破坏操作信息：将攻击力最低的怪兽组作为将被破坏的对象，数量为1，破坏分类为CATEGORY_DESTROY。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
	-- 登记伤害操作信息：给予对方基本分攻击力最低怪兽的攻击力数值的伤害，分类为CATEGORY_DAMAGE。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,tg:GetFirst():GetAttack())
end
-- 效果处理：再次取得对方场上表侧表示怪兽；选出攻击力最低的怪兽，若有复数则操作者选择其中1只；将其破坏；若破坏成功，给予对方该怪兽攻击力数值的伤害。
function c30341772.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时取得对方场上当前所有表侧表示怪兽。
	local g=Duel.GetMatchingGroup(c30341772.filter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		local tc=nil
		local tg=g:GetMinGroup(Card.GetAttack)
		if tg:GetCount()>1 then
			-- 当攻击力最低的怪兽存在多只时，弹出选择提示，令发动者选择1只要破坏的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=tg:Select(tp,1,1,nil)
			-- 为选中的怪兽播放被选为对象的动画，并将其记录为这张卡效果的对象。
			Duel.HintSelection(sg)
			tc=sg:GetFirst()
		else
			tc=tg:GetFirst()
		end
		local atk=tc:GetAttack()
		-- 以效果原因将选择的怪兽破坏；只有实际破坏成功（返回值大于0）时才继续执行后续伤害。
		if Duel.Destroy(tc,REASON_EFFECT)>0 then
			-- 给予对方基本分等同于被破坏怪兽当前攻击力数值的效果伤害。
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end
