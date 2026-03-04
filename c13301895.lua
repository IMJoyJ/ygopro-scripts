--失楽園
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在场地区域存在，自己的怪兽区域的「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」「混沌幻魔 阿米泰尔」不会成为对方的效果的对象，不会被对方的效果破坏。
-- ②：自己的怪兽区域有「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」「混沌幻魔 阿米泰尔」的其中任意种存在的场合才能发动。自己从卡组抽2张。
function c13301895.initial_effect(c)
	-- 为卡片注册关联卡片代码列表，用于标记该卡效果中提及的特定卡片
	aux.AddCodeList(c,6007213,32491822,69890967)
	-- ①：只要这张卡在场地区域存在，自己的怪兽区域的「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」「混沌幻魔 阿米泰尔」不会成为对方的效果的对象，不会被对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ②：自己的怪兽区域有「神炎皇 乌利亚」「降雷皇 哈蒙」「幻魔皇 拉比艾尔」「混沌幻魔 阿米泰尔」的其中任意种存在的场合才能发动。自己从卡组抽2张。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c13301895.immtg)
	-- 设置效果值为过滤函数，用于判断目标怪兽是否不会成为对方的效果对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置效果值为过滤函数，用于判断目标怪兽是否不会被对方的效果破坏
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	-- 创建抽卡效果，用于发动②效果
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCountLimit(1,13301895)
	e4:SetCondition(c13301895.drcon)
	e4:SetTarget(c13301895.drtg)
	e4:SetOperation(c13301895.drop)
	c:RegisterEffect(e4)
end
-- 过滤函数，判断目标怪兽是否为指定的特定卡片之一
function c13301895.immtg(e,c)
	return c:IsCode(6007213,32491822,69890967,43378048)
end
-- 过滤函数，判断目标怪兽是否为指定的特定卡片之一且处于表侧表示
function c13301895.drcfilter(c)
	return c:IsFaceup() and c:IsCode(6007213,32491822,69890967,43378048)
end
-- 条件函数，判断是否满足发动②效果的条件
function c13301895.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在满足条件的特定卡片
	return Duel.IsExistingMatchingCard(c13301895.drcfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 目标函数，设置抽卡效果的目标玩家和抽卡数量
function c13301895.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置连锁的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁的目标参数为抽卡数量2
	Duel.SetTargetParam(2)
	-- 设置操作信息，表示将要进行抽卡操作
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 操作函数，执行抽卡效果
function c13301895.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作，从卡组抽2张卡
	Duel.Draw(p,d,REASON_EFFECT)
end
