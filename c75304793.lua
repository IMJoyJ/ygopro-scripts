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
	-- 设置攻击力上升效果的对象为「音响战士」怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1066))
	e3:SetValue(c75304793.atkval)
	c:RegisterEffect(e3)
	-- ③：1回合1次，可以把自己场上的音响指示物的以下数量取除，那个效果发动。 ●5个：给与对方为场上的「音响战士」卡数量×300伤害。 ●7个：选最多有场上的「音响战士」卡数量的对方的场上·墓地的卡除外。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c75304793.target)
	e4:SetOperation(c75304793.operation)
	c:RegisterEffect(e4)
end
-- 检查发动的效果是否为「音响战士」卡的效果（且不是魔法·陷阱卡的发动）
function c75304793.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsSetCard(0x1066) and not re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 给这张卡放置1个音响指示物
function c75304793.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x35,1)
end
-- 计算攻击力上升值，为这张卡的音响指示物数量×100
function c75304793.atkval(e,c)
	return e:GetHandler():GetCounter(0x35)*100
end
-- 过滤场上表侧表示的「音响战士」卡
function c75304793.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1066)
end
-- 效果③的发动准备，检查是否能去除对应数量的指示物并让玩家选择发动的效果
function c75304793.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上表侧表示的「音响战士」卡数量
	local ct=Duel.GetMatchingGroupCount(c75304793.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 检查是否能从己方场上移除5个音响指示物作为代价
	local b1=Duel.IsCanRemoveCounter(tp,1,0,0x35,5,REASON_COST)
	-- 检查是否能从己方场上移除7个音响指示物作为代价
	local b2=Duel.IsCanRemoveCounter(tp,1,0,0x35,7,REASON_COST)
		-- 且对方场上或墓地存在可以除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil)
	if chk==0 then return ct>0 and (b1 or b2) end
	local op=0
	if b1 and b2 then
		-- 同时满足两个效果的发动条件时，让玩家选择发动其中一个效果
		op=Duel.SelectOption(tp,aux.Stringid(75304793,0),aux.Stringid(75304793,1))  --"5个：给与对方伤害/7个：对方的卡除外"
	elseif b1 then
		-- 仅满足5个指示物的效果时，强制选择该效果
		op=Duel.SelectOption(tp,aux.Stringid(75304793,0))  --"5个：给与对方伤害"
	else
		-- 仅满足7个指示物的效果时，强制选择该效果
		op=Duel.SelectOption(tp,aux.Stringid(75304793,1))+1  --"7个：对方的卡除外"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_DAMAGE)
		-- 从己方场上移除5个音响指示物作为发动代价
		Duel.RemoveCounter(tp,1,0,0x35,5,REASON_COST)
		-- 设置伤害效果的对象玩家为对方
		Duel.SetTargetPlayer(1-tp)
		-- 设置连锁的操作信息为给与对方「音响战士」卡数量×300的伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*300)
	else
		e:SetCategory(CATEGORY_REMOVE)
		-- 从己方场上移除7个音响指示物作为发动代价
		Duel.RemoveCounter(tp,1,0,0x35,7,REASON_COST)
		-- 设置连锁的操作信息为除外对方场上或墓地的卡
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_ONFIELD+LOCATION_GRAVE)
	end
end
-- 效果③的效果处理，根据选择的效果分别处理伤害或除外
function c75304793.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 在效果处理时重新获取场上表侧表示的「音响战士」卡数量
	local ct=Duel.GetMatchingGroupCount(c75304793.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if ct==0 then return end
	if e:GetLabel()==0 then
		-- 获取伤害效果的对象玩家
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		-- 给与对方为场上的「音响战士」卡数量×300的伤害
		Duel.Damage(p,ct*300,REASON_EFFECT)
	else
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 让玩家选择最多有场上「音响战士」卡数量的对方场上或墓地的卡
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,ct,nil)
		if g:GetCount()>0 then
			-- 将选择的卡表侧表示除外
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
