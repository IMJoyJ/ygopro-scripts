--壊獣捕獲大作戦
-- 效果：
-- 「坏兽捕获大作战」的②的效果1回合只能使用1次。
-- ①：1回合1次，以场上1只「坏兽」怪兽为对象才能发动。那只怪兽变成里侧守备表示。那之后，给这张卡放置1个坏兽指示物（最多3个）。
-- ②：这张卡被对方的效果破坏送去墓地的场合才能发动。自己从卡组抽2张。
function c81057455.initial_effect(c)
	c:EnableCounterPermit(0x37)
	c:SetCounterLimit(0x37,3)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，以场上1只「坏兽」怪兽为对象才能发动。那只怪兽变成里侧守备表示。那之后，给这张卡放置1个坏兽指示物（最多3个）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(81057455,0))
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetCondition(c81057455.poscon)
	e2:SetTarget(c81057455.postg)
	e2:SetOperation(c81057455.posop)
	c:RegisterEffect(e2)
	-- ②：这张卡被对方的效果破坏送去墓地的场合才能发动。自己从卡组抽2张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(81057455,1))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,81057455)
	e3:SetCondition(c81057455.drcon)
	e3:SetTarget(c81057455.drtg)
	e3:SetOperation(c81057455.drop)
	c:RegisterEffect(e3)
end
c81057455.mentioned_counter={
	[0x37]=true,
}
-- ①效果的发动条件
function c81057455.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x37)<3
end
-- 过滤条件：表侧表示的「坏兽」怪兽且可以变成里侧表示
function c81057455.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xd3) and c:IsCanTurnSet()
end
-- ①效果的目标设置
function c81057455.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c81057455.filter(chkc) end
	-- 检查能否给这张卡放置1个坏兽指示物
	if chk==0 then return Duel.IsCanAddCounter(tp,0x37,1,e:GetHandler())
		-- 检查场上是否有满足条件的「坏兽」怪兽
		and Duel.IsExistingTarget(c81057455.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示的「坏兽」怪兽作为对象
	local g=Duel.SelectTarget(tp,c81057455.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ①效果的处理逻辑
function c81057455.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 如果对象怪兽成功变成里侧守备表示
	if tc:IsRelateToEffect(e) and Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)~=0 then
		e:GetHandler():AddCounter(0x37,1)
	end
end
-- ②效果的发动条件
function c81057455.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and rp==1-tp and bit.band(r,0x41)==0x41
end
-- ②效果的目标设置
function c81057455.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将目标玩家设置为自己
	Duel.SetTargetPlayer(tp)
	-- 将目标参数设置为2张
	Duel.SetTargetParam(2)
	-- 设置操作信息：抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- ②效果的处理逻辑
function c81057455.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标玩家和目标抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作
	Duel.Draw(p,d,REASON_EFFECT)
end
