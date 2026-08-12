--ウィッチクラフト・バイストリート
-- 效果：
-- 这个卡名的②③的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上的「魔女术」怪兽在1回合各有1次不会被战斗·效果破坏。
-- ②：自己场上的「魔女术」怪兽为让效果发动而把手卡丢弃的场合，可以作为代替把这张卡送去墓地。
-- ③：这张卡在墓地存在，自己场上有「魔女术」怪兽存在的场合，自己结束阶段才能发动。这张卡在自己的魔法与陷阱区域表侧表示放置。
function c83289866.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：自己场上的「魔女术」怪兽在1回合各有1次不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c83289866.target)
	e1:SetValue(c83289866.indct)
	c:RegisterEffect(e1)
	-- ③：这张卡在墓地存在，自己场上有「魔女术」怪兽存在的场合，自己结束阶段才能发动。这张卡在自己的魔法与陷阱区域表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(83289866,0))  --"返回场上"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,83289866)
	e2:SetCondition(c83289866.setcon)
	e2:SetTarget(c83289866.settg)
	e2:SetOperation(c83289866.setop)
	c:RegisterEffect(e2)
	-- ②：自己场上的「魔女术」怪兽为让效果发动而把手卡丢弃的场合，可以作为代替把这张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(83289866)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,83289866)
	c:RegisterEffect(e3)
end
-- 过滤属于「魔女术」字段的怪兽
function c83289866.target(e,c)
	return c:IsSetCard(0x128)
end
-- 设置因战斗或效果破坏的次数为1次
function c83289866.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0 then
		return 1
	else return 0 end
end
-- 过滤自己场上表侧表示的「魔女术」怪兽
function c83289866.rccfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x128)
end
-- 效果③的发动条件：自己回合的结束阶段，且自己场上有表侧表示的「魔女术」怪兽存在
function c83289866.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
		-- 检查自己场上是否存在表侧表示的「魔女术」怪兽
		and Duel.IsExistingMatchingCard(c83289866.rccfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果③的发动准备：检查魔法与陷阱区域是否有空位，并设置操作信息
function c83289866.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	-- 设置操作信息为将此卡移出墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果③的效果处理：将此卡在自己的魔法与陷阱区域表侧表示放置
function c83289866.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查魔法与陷阱区域是否有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡移动到自己的魔法与陷阱区域表侧表示放置，并立刻适用其效果
		Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
