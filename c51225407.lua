--魔妖壊劫
-- 效果：
-- 这个卡名的②③的效果1回合只能有1次使用其中任意1个。
-- ①：对方场上的怪兽的攻击力·守备力下降自己墓地的「魔妖」怪兽种类×100。
-- ②：把自己场上的表侧表示的1只「魔妖」怪兽和这张卡送去墓地才能发动。自己从卡组抽1张。
-- ③：从自己墓地把这张卡和1只不死族怪兽除外，以自己墓地1只「魔妖」怪兽为对象才能发动。那只怪兽特殊召唤。
function c51225407.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：对方场上的怪兽的攻击力·守备力下降自己墓地的「魔妖」怪兽种类×100。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(c51225407.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：把自己场上的表侧表示的1只「魔妖」怪兽和这张卡送去墓地才能发动。自己从卡组抽1张。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(51225407,0))
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,51225407)
	e4:SetCost(c51225407.drcost)
	e4:SetTarget(c51225407.drtg)
	e4:SetOperation(c51225407.drop)
	c:RegisterEffect(e4)
	-- ③：从自己墓地把这张卡和1只不死族怪兽除外，以自己墓地1只「魔妖」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(51225407,1))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCountLimit(1,51225407)
	e5:SetCost(c51225407.spcost)
	e5:SetTarget(c51225407.sptg)
	e5:SetOperation(c51225407.spop)
	c:RegisterEffect(e5)
end
-- 用于筛选墓地中的「魔妖」怪兽的过滤函数
function c51225407.atkfilter(c)
	return c:IsSetCard(0x121) and c:IsType(TYPE_MONSTER)
end
-- 计算攻击力下降值，根据墓地「魔妖」怪兽数量乘以100
function c51225407.atkval(e,c)
	-- 获取满足条件的墓地「魔妖」怪兽组
	local g=Duel.GetMatchingGroup(c51225407.atkfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)
	return g:GetClassCount(Card.GetCode)*-100
end
-- 用于筛选场上表侧表示的「魔妖」怪兽的过滤函数
function c51225407.drfilter(c)
	return c:IsSetCard(0x121) and c:IsFaceup() and c:IsAbleToGraveAsCost()
end
-- 检查是否满足②效果的发动条件
function c51225407.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost()
		-- 检查场上是否存在满足条件的「魔妖」怪兽
		and Duel.IsExistingMatchingCard(c51225407.drfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择场上表侧表示的「魔妖」怪兽
	local g=Duel.SelectMatchingCard(tp,c51225407.drfilter,tp,LOCATION_MZONE,0,1,1,nil)
	g:AddCard(c)
	-- 将选中的卡送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置②效果的目标和操作信息
function c51225407.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果的目标玩家为使用者
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为抽1张卡
	Duel.SetTargetParam(1)
	-- 设置效果的操作信息为抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行②效果的处理过程
function c51225407.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 用于筛选墓地中的不死族怪兽并检查是否有可特殊召唤的「魔妖」怪兽的过滤函数
function c51225407.cfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		-- 检查是否存在满足条件的「魔妖」怪兽作为特殊召唤对象
		and Duel.IsExistingTarget(c51225407.spfilter,tp,LOCATION_GRAVE,0,1,c,e,tp)
end
-- 用于筛选可特殊召唤的「魔妖」怪兽的过滤函数
function c51225407.spfilter(c,e,tp)
	return c:IsSetCard(0x121) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查是否满足③效果的发动条件
function c51225407.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查墓地是否存在满足条件的不死族怪兽
		and Duel.IsExistingMatchingCard(c51225407.cfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择墓地中的不死族怪兽
	local g=Duel.SelectMatchingCard(tp,c51225407.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	g:AddCard(e:GetHandler())
	-- 将选中的卡除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置③效果的目标和操作信息
function c51225407.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c51225407.spfilter(chkc,e,tp) end
	-- 检查是否有足够的特殊召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中的「魔妖」怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c51225407.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果的操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行③效果的处理过程
function c51225407.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
