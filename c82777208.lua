--氷水のアクティ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，从手卡把1只水属性怪兽送去墓地才能发动。自己抽1张。
-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的水属性怪兽被战斗·效果破坏的场合，把这张卡除外才能发动。从自己的手卡·墓地把「冰水之阳起石精」以外的1只「冰水」怪兽特殊召唤。
function c82777208.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合，从手卡把1只水属性怪兽送去墓地才能发动。自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82777208,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,82777208)
	e1:SetCost(c82777208.drcost)
	e1:SetTarget(c82777208.drtg)
	e1:SetOperation(c82777208.drop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的水属性怪兽被战斗·效果破坏的场合，把这张卡除外才能发动。从自己的手卡·墓地把「冰水之阳起石精」以外的1只「冰水」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(82777208,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCountLimit(1,82777209)
	-- 设置发动费用为把墓地的这张卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetCondition(c82777208.spcon)
	e3:SetTarget(c82777208.sptg)
	e3:SetOperation(c82777208.spop)
	c:RegisterEffect(e3)
end
-- 过滤手牌中可以送去墓地的水属性怪兽
function c82777208.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToGraveAsCost()
end
-- 抽卡效果的发动费用函数：从手卡把1只水属性怪兽送去墓地
function c82777208.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可以送去墓地的水属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c82777208.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手牌选择1只满足条件的水属性怪兽
	local g=Duel.SelectMatchingCard(tp,c82777208.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的怪兽作为发动费用送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 抽卡效果的靶向与发动检查函数
function c82777208.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果处理的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理的对象参数为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为抽卡，数量为1张
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的执行函数
function c82777208.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行效果，让目标玩家抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 过滤自己场上因战斗或效果被破坏的表侧表示水属性怪兽
function c82777208.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsAttribute(ATTRIBUTE_WATER) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 特殊召唤效果的发动条件：自己场上的表侧表示水属性怪兽被破坏，且不包含墓地中的这张卡本身
function c82777208.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c82777208.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 过滤手牌或墓地中「冰水之阳起石精」以外的「冰水」怪兽
function c82777208.spfilter(c,e,tp)
	return c:IsSetCard(0x16c) and not c:IsCode(82777208) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的靶向与发动检查函数
function c82777208.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌或墓地中是否存在除这张卡以外可特殊召唤的「冰水」怪兽
		and Duel.IsExistingMatchingCard(c82777208.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 设置当前连锁的操作信息为特殊召唤，数量为1，位置为手牌或墓地
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 特殊召唤效果的执行函数
function c82777208.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有空余的怪兽区域则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌或墓地选择1只满足条件的「冰水」怪兽（适用王家长眠之谷的过滤）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c82777208.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
