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
	-- 指定攻击力上升效果的对象为「音响战士」怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1066))
	e3:SetValue(c75304793.atkval)
	c:RegisterEffect(e3)
	-- ③：1回合1次，可以把自己场上的音响指示物的以下数量取除，那个效果发动。●5个：给与对方为场上的「音响战士」卡数量×300伤害。●7个：选最多有场上的「音响战士」卡数量的对方的场上·墓地的卡除外。
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
-- 检查是否有「音响战士」卡的效果发动
function c75304793.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsSetCard(0x1066) and not re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 给这张卡放置1个音响指示物
function c75304793.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x35,1)
end
-- 攻击力上升这张卡的音响指示物数量×100
function c75304793.atkval(e,c)
	return e:GetHandler():GetCounter(0x35)*100
end
-- 检查卡片是否是表侧表示的「音响战士」卡
function c75304793.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1066)
end
-- 根据场上「音响战士」卡的数量，选择取除的指示物并设置对应的效果操作
function c75304793.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 统计场上表侧表示的「音响战士」卡的数量
	local ct=Duel.GetMatchingGroupCount(c75304793.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 检查是否可以取除5个音响指示物
	local b1=Duel.IsCanRemoveCounter(tp,1,0,0x35,5,REASON_COST)
	-- 检查是否可以取除7个音响指示物
	local b2=Duel.IsCanRemoveCounter(tp,1,0,0x35,7,REASON_COST)
		-- 检查对方场上或墓地是否存在可以被除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil)
	if chk==0 then return ct>0 and (b1 or b2) end
	local op=0
	if b1 and b2 then
		-- 让玩家在“伤害”和“除外”中选择要发动的效果选项
		op=Duel.SelectOption(tp,aux.Stringid(75304793,0),aux.Stringid(75304793,1))  --"5个：给与对方伤害/7个：对方的卡除外"
	elseif b1 then
		-- 只能选择取除5个音响指示物的效果
		op=Duel.SelectOption(tp,aux.Stringid(75304793,0))  --"5个：给与对方伤害"
	else
		-- 只能选择取除7个音响指示物的效果
		op=Duel.SelectOption(tp,aux.Stringid(75304793,1))+1  --"7个：对方的卡除外"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_DAMAGE)
		-- 取除5个音响指示物
		Duel.RemoveCounter(tp,1,0,0x35,5,REASON_COST)
		-- 设置预计受到伤害的目标玩家为对方
		Duel.SetTargetPlayer(1-tp)
		-- 设置操作信息：预计给与对方伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*300)
	else
		e:SetCategory(CATEGORY_REMOVE)
		-- 取除7个音响指示物
		Duel.RemoveCounter(tp,1,0,0x35,7,REASON_COST)
		-- 设置操作信息：预计除外场上或墓地的卡
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_ONFIELD+LOCATION_GRAVE)
	end
end
-- 执行伤害对方或除外对方卡片的效果操作
function c75304793.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 再次统计场上表侧表示的「音响战士」卡的数量
	local ct=Duel.GetMatchingGroupCount(c75304793.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if ct==0 then return end
	if e:GetLabel()==0 then
		-- 获取预计受到伤害的目标玩家
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		-- 给与对方场上的「音响战士」卡数量×300伤害
		Duel.Damage(p,ct*300,REASON_EFFECT)
	else
		-- 发送选择要除外的卡的提示消息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 选对方的场上·墓地的卡作为除外对象
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,ct,nil)
		if g:GetCount()>0 then
			-- 将选定的卡除外
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
