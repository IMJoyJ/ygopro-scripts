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
	-- 初始化卡片效果：注册①「音响战士」卡效果处理时自动放置音响指示物效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c75304793.ctcon)
	e2:SetOperation(c75304793.ctop)
	c:RegisterEffect(e2)
	-- 初始化卡片效果：注册②场上「音响战士」怪兽攻击力根据指示物数量上升的永续效果
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 攻击力上升的目标对象过滤：场上的「音响战士」怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1066))
	e3:SetValue(c75304793.atkval)
	c:RegisterEffect(e3)
	-- 初始化卡片效果：注册③取除5个/7个指示物发动扣血或除外效果（启动效果）
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
-- 指示物放置条件检查：发动的卡为「音响战士」且非卡片发动的连锁处理中
function c75304793.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsSetCard(0x1066) and not re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 放置指示物处理：给此卡放置1个音响指示物
function c75304793.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x35,1)
end
-- 攻击力上升数值计算：音响指示物数量×100
function c75304793.atkval(e,c)
	return e:GetHandler():GetCounter(0x35)*100
end
-- 数量统计过滤条件：场上表侧表示的「音响战士」卡
function c75304793.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1066)
end
-- ③效果发动准备：检查指示物数量与分支条件，选择消耗5个（伤害）或7个（除外）并支付Cost
function c75304793.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 统计双方场上「音响战士」卡的数量
	local ct=Duel.GetMatchingGroupCount(c75304793.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 检查是否能取除5个音响指示物（分支1：伤害）
	local b1=Duel.IsCanRemoveCounter(tp,1,0,0x35,5,REASON_COST)
	-- 检查是否能取除7个音响指示物（分支2：除外）
	local b2=Duel.IsCanRemoveCounter(tp,1,0,0x35,7,REASON_COST)
		-- 检查对方场上·墓地是否存在可除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil)
	if chk==0 then return ct>0 and (b1 or b2) end
	local op=0
	if b1 and b2 then
		-- 分支均满足时由玩家选择发动效果：取除5个（伤害）或7个（除外）
		op=Duel.SelectOption(tp,aux.Stringid(75304793,0),aux.Stringid(75304793,1))  --"5个：给与对方伤害/7个：对方的卡除外"
	elseif b1 then
		-- 仅满足取除5个条件时选择分支1（伤害）
		op=Duel.SelectOption(tp,aux.Stringid(75304793,0))  --"5个：给与对方伤害"
	else
		-- 仅满足取除7个条件时选择分支2（除外）
		op=Duel.SelectOption(tp,aux.Stringid(75304793,1))+1  --"7个：对方的卡除外"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_DAMAGE)
		-- Cost支付：取除场上5个音响指示物
		Duel.RemoveCounter(tp,1,0,0x35,5,REASON_COST)
		-- 设置伤害承受玩家为对方
		Duel.SetTargetPlayer(1-tp)
		-- 设置连锁操作信息：给予对方指定伤害（音响战士数量×300）
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*300)
	else
		e:SetCategory(CATEGORY_REMOVE)
		-- Cost支付：取除场上7个音响指示物
		Duel.RemoveCounter(tp,1,0,0x35,7,REASON_COST)
		-- 设置连锁操作信息：从对方场上或墓地除外卡片
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_ONFIELD+LOCATION_GRAVE)
	end
end
-- ③效果处理：根据选择的分支执行效果伤害或选卡除外处理
function c75304793.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 重新统计场上「音响战士」卡的数量
	local ct=Duel.GetMatchingGroupCount(c75304793.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if ct==0 then return end
	if e:GetLabel()==0 then
		-- 获取指定的伤害目标玩家
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		-- 分支1处理：给予对方为「音响战士」数量×300的效果伤害
		Duel.Damage(p,ct*300,REASON_EFFECT)
	else
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 选择对方场上·墓地最多有「音响战士」数量的卡
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,ct,nil)
		if g:GetCount()>0 then
			-- 分支2处理：将选中的卡表侧表示除外
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
