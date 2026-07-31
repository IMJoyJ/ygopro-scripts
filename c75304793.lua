--アンプリファイヤー
-- 效果：
-- ①：只要这张卡在场地区域存在，每次「音响战士」卡持有的效果发动给这张卡放置1个音响指示物。
-- ②：场上的「音响战士」怪兽的攻击力上升这张卡的音响指示物数量×100。
-- ③：1回合1次，可以把自己场上的音响指示物的以下数量取除，那个效果发动。
-- ●5个：给与对方为场上的「音响战士」卡数量×300伤害。
-- ●7个：选最多有场上的「音响战士」卡数量的对方的场上·墓地的卡除外。
function c75304793.initial_effect(c)
	c:EnableCounterPermit(0x35)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在场地区域存在，每次「音响战士」卡持有的效果发动给这张卡放置1个音响指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c75304793.ctcon)
	e2:SetOperation(c75304793.ctop)
	c:RegisterEffect(e2)
	-- ②：场上的「音响战士」怪兽的攻击力上升这张卡的音响指示物数量×100。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- Target过滤条件：场上的「音响战士」怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1066))
	e3:SetValue(c75304793.atkval)
	c:RegisterEffect(e3)
	-- ③：1回合1次，去除自己场上5个或7个音响指示物才能发动。5个：给予对方场上「音响战士」卡数量×300伤害；7个：选最多为场上「音响战士」卡数量的对方场地·墓地的卡除外。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c75304793.target)
	e4:SetOperation(c75304793.operation)
	c:RegisterEffect(e4)
end
c75304793.mentioned_counter={
	[0x35]=true,
}
-- ①效果触发条件：发动的卡的效果属于「音响战士」卡且非卡片发动的效果
function c75304793.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsSetCard(0x1066) and not re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- ①效果处理：给此卡放置1个音响指示物
function c75304793.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x35,1)
end
-- ②效果攻击力上升数值：此卡放置的音响指示物数量×100
function c75304793.atkval(e,c)
	return e:GetHandler():GetCounter(0x35)*100
end
-- 过滤条件：场上表侧表示的「音响战士」卡
function c75304793.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1066)
end
-- ③效果发动准备：检查去除指示物Cost及场上状况并由玩家选择发动的效果分支，设置对应的操作信息
function c75304793.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取双方场上表侧表示「音响战士」卡的数量
	local ct=Duel.GetMatchingGroupCount(c75304793.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 检查能否去除5个音响指示物
	local b1=Duel.IsCanRemoveCounter(tp,1,0,0x35,5,REASON_COST)
	-- 检查能否去除7个音响指示物
	local b2=Duel.IsCanRemoveCounter(tp,1,0,0x35,7,REASON_COST)
		-- 检查对方场地/墓地是否存在可除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil)
	if chk==0 then return ct>0 and (b1 or b2) end
	local op=0
	if b1 and b2 then
		-- 同时满足5个与7个指示物条件时，由玩家选择要发动的效果分支
		op=Duel.SelectOption(tp,aux.Stringid(75304793,0),aux.Stringid(75304793,1))  --"5个：给与对方伤害/7个：对方的卡除外"
	elseif b1 then
		-- 仅满足5个指示物条件时，选择5个伤害效果分支
		op=Duel.SelectOption(tp,aux.Stringid(75304793,0))  --"5个：给与对方伤害"
	else
		-- 仅满足7个指示物条件时，选择7个除外效果分支
		op=Duel.SelectOption(tp,aux.Stringid(75304793,1))+1  --"7个：对方的卡除外"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_DAMAGE)
		-- 去除5个音响指示物
		Duel.RemoveCounter(tp,1,0,0x35,5,REASON_COST)
		-- 设置效果目标玩家为对方
		Duel.SetTargetPlayer(1-tp)
		-- 设置连锁操作信息：给予对方伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*300)
	else
		e:SetCategory(CATEGORY_REMOVE)
		-- 去除7个音响指示物
		Duel.RemoveCounter(tp,1,0,0x35,7,REASON_COST)
		-- 设置连锁操作信息：从对方场地/墓地除外卡片
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_ONFIELD+LOCATION_GRAVE)
	end
end
-- ③效果处理：根据发动的效果分支，给予对方伤害或除外对方场地·墓地的卡
function c75304793.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取双方场上表侧表示「音响战士」卡的数量
	local ct=Duel.GetMatchingGroupCount(c75304793.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if ct==0 then return end
	if e:GetLabel()==0 then
		-- 获取目标玩家
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		-- 给予目标玩家「音响战士」卡数量×300的伤害
		Duel.Damage(p,ct*300,REASON_EFFECT)
	else
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 选择对方场地/墓地最多ct张可除外的卡
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,ct,nil)
		if g:GetCount()>0 then
			-- 将选中的卡表侧表示除外
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
