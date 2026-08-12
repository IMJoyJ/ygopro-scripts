--黒魔導戦士 ブレイカー
-- 效果：
-- 「黑魔导战士 破坏者」的④的效果1回合只能使用1次。
-- ①：这张卡召唤成功的场合发动。给这张卡放置2个魔力指示物。
-- ②：这张卡灵摆召唤成功的场合发动。给这张卡放置3个魔力指示物。
-- ③：这张卡的攻击力上升这张卡的魔力指示物数量×400。
-- ④：把这张卡1个魔力指示物取除，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
function c22923081.initial_effect(c)
	c:EnableCounterPermit(0x1)
	-- ①：这张卡召唤成功的场合发动。给这张卡放置2个魔力指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22923081,0))  --"放置魔力指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c22923081.addtg)
	e1:SetOperation(c22923081.addop)
	e1:SetLabel(2)
	c:RegisterEffect(e1)
	-- ②：这张卡灵摆召唤成功的场合发动。给这张卡放置3个魔力指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22923081,1))  --"放置魔力指示物"
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c22923081.addcon)
	e2:SetTarget(c22923081.addtg)
	e2:SetOperation(c22923081.addop)
	e2:SetLabel(3)
	c:RegisterEffect(e2)
	-- ③：这张卡的攻击力上升这张卡的魔力指示物数量×400。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(c22923081.atkval)
	c:RegisterEffect(e3)
	-- 「黑魔导战士 破坏者」的④的效果1回合只能使用1次。④：把这张卡1个魔力指示物取除，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(22923081,2))  --"破坏一张魔法陷阱卡"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,22923081)
	e4:SetCost(c22923081.descost)
	e4:SetTarget(c22923081.destg)
	e4:SetOperation(c22923081.desop)
	c:RegisterEffect(e4)
end
c22923081.mentioned_counter={
	[0x1]=true,
}
-- 效果发动条件永远满足（必发效果），并设置操作信息：本次处理将放置魔力指示物，数量为效果标签中记录的值（2或3个）
function c22923081.addtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息：将处理放置魔力指示物效果，放置数量为效果标签值（2或3个）
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,e:GetLabel(),0,0x1)
end
-- 效果处理：这张卡仍与效果相关联（仍在场上）时，给这张卡放置指定数量（2或3个）的魔力指示物
function c22923081.addop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1,e:GetLabel())
	end
end
-- 发动条件判定：这张卡是灵摆召唤成功的场合才能发动（对应②效果放置3个指示物）
function c22923081.addcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 计算攻击力上升值：这张卡放置的魔力指示物数量×400
function c22923081.atkval(e,c)
	return c:GetCounter(0x1)*400
end
-- 代价处理：支付条件为这张卡能取除1个魔力指示物，支付时把这张卡1个魔力指示物取除作为发动代价
function c22923081.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,1,REASON_COST)
end
-- 筛选函数：卡片是魔法·陷阱卡
function c22923081.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 取对象目标选择：对象必须在场上且是魔法·陷阱卡；发动条件为场上存在可成为对象的魔法·陷阱卡；提示选择要破坏的卡，以场上1张魔法·陷阱卡为对象，并设置破坏的操作信息
function c22923081.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c22923081.filter(chkc) end
	-- 发动条件判定：双方场上存在至少1张可成为此效果对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c22923081.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 以场上1张魔法·陷阱卡为对象（同时将该卡设置为当前连锁的对象）
	local g=Duel.SelectTarget(tp,c22923081.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息：将以效果破坏成为对象的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：取得成为对象的卡，若该卡仍与此效果相关联（仍在场上），则以效果将其破坏
function c22923081.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁成为对象的那张卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的卡以效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
