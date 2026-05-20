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
-- 检查自身放置的坏兽指示物数量是否小于3个，作为效果①的发动条件
function c81057455.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x37)<3
end
-- 过滤场上表侧表示、属于「坏兽」字段且可以变成里侧表示的怪兽
function c81057455.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xd3) and c:IsCanTurnSet()
end
-- 效果①的发动准备（判定是否能成为对象以及是否能添加指示物）
function c81057455.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c81057455.filter(chkc) end
	-- 检查自身是否能放置1个坏兽指示物
	if chk==0 then return Duel.IsCanAddCounter(tp,0x37,1,e:GetHandler())
		-- 检查场上是否存在可以作为对象的「坏兽」怪兽
		and Duel.IsExistingTarget(c81057455.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择1只符合条件的「坏兽」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c81057455.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息，表示该效果包含改变表示形式的操作，操作对象为所选怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果①的执行函数，将对象怪兽变成里侧守备表示，并给自身放置指示物
function c81057455.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍适用于此效果，则将其变成里侧守备表示，并在变更成功时执行后续处理
	if tc:IsRelateToEffect(e) and Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)~=0 then
		e:GetHandler():AddCounter(0x37,1)
	end
end
-- 效果②的发动条件：此卡由对方的效果破坏并送去自己墓地
function c81057455.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and rp==1-tp and bit.band(r,0x41)==0x41
end
-- 效果②的发动准备（检查抽卡可行性并设置抽卡参数）
function c81057455.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以从卡组抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将效果的对象玩家设置为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 将效果的对象参数（抽卡张数）设置为2
	Duel.SetTargetParam(2)
	-- 设置连锁信息，表示该效果包含抽卡操作，数量为2张
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果②的执行函数，执行抽卡处理
function c81057455.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
