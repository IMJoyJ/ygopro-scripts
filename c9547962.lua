--オイラーサーキット
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：自己场上有「廷达魔三角」怪兽3只以上存在的场合，对方怪兽不能攻击。
-- ②：自己准备阶段，以自己场上1只「廷达魔三角」怪兽为对象才能发动。那只怪兽的控制权移给对方。
-- ③：把墓地的这张卡除外，从手卡丢弃1张「廷达魔三角」卡才能发动。从卡组把1张「欧拉回路」加入手卡。
function c9547962.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上有「廷达魔三角」怪兽3只以上存在的场合，对方怪兽不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c9547962.atkcon)
	c:RegisterEffect(e2)
	-- ②：自己准备阶段，以自己场上1只「廷达魔三角」怪兽为对象才能发动。那只怪兽的控制权移给对方。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c9547962.ctcon)
	e3:SetTarget(c9547962.cttg)
	e3:SetOperation(c9547962.ctop)
	c:RegisterEffect(e3)
	-- ③：把墓地的这张卡除外，从手卡丢弃1张「廷达魔三角」卡才能发动。从卡组把1张「欧拉回路」加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCountLimit(1,9547962)
	e5:SetCost(c9547962.thcost)
	e5:SetTarget(c9547962.thtg)
	e5:SetOperation(c9547962.thop)
	c:RegisterEffect(e5)
end
-- 过滤条件：表侧表示的「廷达魔三角」怪兽
function c9547962.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10b)
end
-- 攻击限制效果的发动条件：自己场上存在3只以上的「廷达魔三角」怪兽
function c9547962.atkcon(e)
	-- 检查自己场上是否存在至少3只表侧表示的「廷达魔三角」怪兽
	return Duel.IsExistingMatchingCard(c9547962.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,3,nil)
end
-- 控制权转移效果的发动条件：当前回合是自己的回合
function c9547962.ctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 过滤条件：表侧表示、属于「廷达魔三角」且可以转移控制权的怪兽
function c9547962.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10b) and c:IsControlerCanBeChanged()
end
-- 控制权转移效果的靶向与发动准备：选择自己场上1只「廷达魔三角」怪兽作为对象，并设置控制权转移的操作信息
function c9547962.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c9547962.ctfilter(chkc) end
	-- 检查场上是否存在可以作为效果对象的、可转移控制权的「廷达魔三角」怪兽
	if chk==0 then return Duel.IsExistingTarget(c9547962.ctfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要转移控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 玩家选择1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c9547962.ctfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息为：转移所选怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 控制权转移效果的实际处理：将作为对象的怪兽的控制权移给对方
function c9547962.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(tp) then
		-- 将目标怪兽的控制权转移给对方
		Duel.GetControl(tc,1-tp)
	end
end
-- 过滤条件：手卡中可以丢弃的「廷达魔三角」卡
function c9547962.cfilter(c)
	return c:IsSetCard(0x10b) and c:IsDiscardable()
end
-- 检索效果的消耗代价：检查并执行将墓地的这张卡除外，并从手卡丢弃1张「廷达魔三角」卡
function c9547962.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查手卡中是否存在至少1张可以丢弃的「廷达魔三角」卡
		and Duel.IsExistingMatchingCard(c9547962.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 将墓地的这张卡表侧表示除外作为发动代价
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
	-- 从手卡丢弃1张「廷达魔三角」卡作为发动代价
	Duel.DiscardHand(tp,c9547962.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：卡组中可以加入手卡的「欧拉回路」
function c9547962.filter(c)
	return c:IsCode(9547962) and c:IsAbleToHand()
end
-- 检索效果的靶向与发动准备：检查卡组中是否存在「欧拉回路」，并设置检索的操作信息
function c9547962.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手卡的「欧拉回路」
	if chk==0 then return Duel.IsExistingMatchingCard(c9547962.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息为：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的实际处理：从卡组把1张「欧拉回路」加入手卡并给对方确认
function c9547962.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中第一张符合条件的「欧拉回路」
	local tc=Duel.GetFirstMatchingCard(c9547962.filter,tp,LOCATION_DECK,0,nil)
	if tc then
		-- 将获取到的「欧拉回路」加入玩家手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 将加入手卡的卡片展示给对方玩家确认
		Duel.ConfirmCards(1-tp,tc)
	end
end
