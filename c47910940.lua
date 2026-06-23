--海晶乙女グレート・バブル・リーフ
-- 效果：
-- 水属性怪兽2只以上
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：双方的准备阶段，从自己墓地以及自己场上的表侧表示怪兽之中把1只水属性怪兽除外才能发动。自己从卡组抽1张。
-- ②：每次怪兽被除外发动。这张卡的攻击力直到回合结束时上升那些除外的怪兽数量×600。
-- ③：从手卡把1只水属性怪兽送去墓地才能发动。选除外的1只自己的「海晶少女」怪兽特殊召唤。
function c47910940.initial_effect(c)
	-- 为卡片添加连接召唤手续，要求使用至少2个水属性的连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_WATER),2)
	c:EnableReviveLimit()
	-- ①：双方的准备阶段，从自己墓地以及自己场上的表侧表示怪兽之中把1只水属性怪兽除外才能发动。自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47910940,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c47910940.drcost)
	e1:SetTarget(c47910940.drtg)
	e1:SetOperation(c47910940.drop)
	c:RegisterEffect(e1)
	-- ②：每次怪兽被除外发动。这张卡的攻击力直到回合结束时上升那些除外的怪兽数量×600。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47910940,1))  --"攻击力上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c47910940.atkcon)
	e2:SetOperation(c47910940.atkop)
	c:RegisterEffect(e2)
	-- ③：从手卡把1只水属性怪兽送去墓地才能发动。选除外的1只自己的「海晶少女」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(47910940,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,47910940)
	e3:SetCost(c47910940.spcost)
	e3:SetTarget(c47910940.sptg)
	e3:SetOperation(c47910940.spop)
	c:RegisterEffect(e3)
end
-- 过滤满足条件的水属性怪兽，可以除外或在墓地中的怪兽
function c47910940.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToRemoveAsCost() and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
-- 检查是否有满足条件的水属性怪兽可作为除外费用，并选择一张进行除外操作
function c47910940.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的水属性怪兽可作为除外费用
	if chk==0 then return Duel.IsExistingMatchingCard(c47910940.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1只水属性怪兽进行除外
	local g=Duel.SelectMatchingCard(tp,c47910940.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡以除外形式移出游戏
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 检查玩家是否可以抽卡，并设置抽卡效果的目标参数
function c47910940.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置抽卡效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡效果的抽卡数量为1张
	Duel.SetTargetParam(1)
	-- 设置抽卡效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡效果，从卡组抽取指定数量的卡
function c47910940.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 过滤满足条件的场上表侧表示怪兽（非TOKEN）
function c47910940.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_TOKEN)
end
-- 判断除外的怪兽数量是否大于等于1且不包含自身
function c47910940.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c47910940.atkfilter,1,nil) and not eg:IsContains(e:GetHandler())
end
-- 为自身添加攻击力提升效果，提升值为除外怪兽数量乘以600
function c47910940.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=eg:FilterCount(c47910940.atkfilter,nil)
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 设置攻击力提升效果的数值和重置条件
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*600)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 过滤满足条件的水属性怪兽，可以送去墓地作为费用
function c47910940.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToGraveAsCost()
end
-- 检查是否有满足条件的水属性怪兽可作为送去墓地的费用，并选择一张进行送去墓地操作
function c47910940.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的水属性怪兽可作为送去墓地的费用
	if chk==0 then return Duel.IsExistingMatchingCard(c47910940.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的1只水属性怪兽送去墓地
	local g=Duel.SelectMatchingCard(tp,c47910940.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的卡以送去墓地形式移出游戏
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤满足条件的「海晶少女」怪兽，可以特殊召唤
function c47910940.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x12b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查是否有满足条件的「海晶少女」怪兽可特殊召唤，并设置特殊召唤效果的目标参数
function c47910940.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前玩家场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否有满足条件的「海晶少女」怪兽可特殊召唤
		and Duel.IsExistingMatchingCard(c47910940.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
-- 执行特殊召唤效果，从除外区选择一只「海晶少女」怪兽进行特殊召唤
function c47910940.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前玩家场上是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只「海晶少女」怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,c47910940.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡以特殊召唤形式移出游戏
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
