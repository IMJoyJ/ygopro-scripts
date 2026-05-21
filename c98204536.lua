--先史遺産驚神殿－トリリトン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的怪兽不存在的场合或者只有「先史遗产」怪兽的场合，支付500基本分才能发动。从手卡把1只「先史遗产」怪兽召唤。
-- ②：自己的「先史遗产」超量怪兽或者自己的「No.」超量怪兽把超量素材取除来让效果发动的场合，可以作为取除的1个超量素材的代替而把这张卡送去墓地。
function c98204536.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的怪兽不存在的场合或者只有「先史遗产」怪兽的场合，支付500基本分才能发动。从手卡把1只「先史遗产」怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(98204536,0))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,98204536)
	e2:SetCost(c98204536.sumcost)
	e2:SetCondition(c98204536.sumcon)
	e2:SetTarget(c98204536.sumtg)
	e2:SetOperation(c98204536.sumop)
	c:RegisterEffect(e2)
	-- ②：自己的「先史遗产」超量怪兽或者自己的「No.」超量怪兽把超量素材取除来让效果发动的场合，可以作为取除的1个超量素材的代替而把这张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,98204537)
	e3:SetCondition(c98204536.rcon)
	e3:SetOperation(c98204536.rop)
	c:RegisterEffect(e3)
end
-- 效果①的代价处理函数：检查并支付500基本分。
function c98204536.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果时，检查玩家是否能够支付500基本分。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 扣除玩家500基本分作为发动代价。
	Duel.PayLPCost(tp,500)
end
-- 过滤函数：筛选出里侧表示怪兽或者非「先史遗产」怪兽。
function c98204536.cfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0x70)
end
-- 效果①的发动条件检查函数：检查自己场上是否没有怪兽，或者只有「先史遗产」怪兽。
function c98204536.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否不存在里侧表示怪兽以及非「先史遗产」怪兽。
	return not Duel.IsExistingMatchingCard(c98204536.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：筛选出自己手卡中可以进行通常召唤的「先史遗产」怪兽。
function c98204536.sumfilter(c)
	return c:IsSetCard(0x70) and c:IsSummonable(true,nil)
end
-- 效果①的发动准备函数：检查手卡中是否存在可召唤的「先史遗产」怪兽，并设置召唤的操作信息。
function c98204536.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果时，检查手卡中是否存在至少1只可以进行通常召唤的「先史遗产」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c98204536.sumfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置当前连锁的操作信息，表示该效果包含从手卡召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,LOCATION_HAND)
end
-- 效果①的效果处理函数：让玩家从手卡选择1只「先史遗产」怪兽进行通常召唤。
function c98204536.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，要求选择要召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 让玩家从手卡选择1只满足条件的「先史遗产」怪兽。
	local g=Duel.SelectMatchingCard(tp,c98204536.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 忽略每回合的通常召唤次数限制，将选中的怪兽进行通常召唤。
		Duel.Summon(tp,tc,true,nil)
	end
end
-- 效果②的代替条件检查函数：检查是否为自己的「先史遗产」或「No.」超量怪兽发动效果而去除素材，且这张卡可以作为代价送去墓地。
function c98204536.rcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return bit.band(r,REASON_COST)~=0 and re:IsActivated() and re:IsActiveType(TYPE_XYZ)
		and rc:GetOverlayCount()>=ev-1 and (rc:IsSetCard(0x70) or rc:IsSetCard(0x48)) and e:GetHandler():IsAbleToGraveAsCost() and ep==e:GetOwnerPlayer()
end
-- 效果②的代替处理函数：将这张卡送去墓地以代替去除超量素材。
function c98204536.rop(e,tp,eg,ep,ev,re,r,rp)
	-- 将这张卡作为代价送去墓地。
	return Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
