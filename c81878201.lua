--アビスティング－トリアイナ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的③的效果1回合只能使用1次。
-- ①：从自己的手卡·墓地把1只「海皇」怪兽或「水精鳞」怪兽特殊召唤，把这张卡装备。
-- ②：装备怪兽被战斗·效果破坏的场合，可以作为代替把这张卡送去墓地。
-- ③：把墓地的这张卡除外，以自己的墓地·除外状态的最多3只鱼族·海龙族·水族怪兽为对象才能发动。那些怪兽回到卡组。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：从自己的手卡·墓地把1只「海皇」怪兽或「水精鳞」怪兽特殊召唤，把这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：装备怪兽被战斗·效果破坏的场合，可以作为代替把这张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	-- ③：把墓地的这张卡除外，以自己的墓地·除外状态的最多3只鱼族·海龙族·水族怪兽为对象才能发动。那些怪兽回到卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	-- 把墓地的这张卡除外作为发动的Cost
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
-- 过滤手卡·墓地中可以特殊召唤的「海皇」或「水精鳞」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x74,0x77) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动检测与效果分类注册
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡或墓地是否存在至少1只满足条件的「海皇」或「水精鳞」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，预计从手卡或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
	-- 设置装备的操作信息，预计将这张卡装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备限制函数，限制只能装备给这张卡的效果所特殊召唤的怪兽
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
-- ①效果的处理函数，特殊召唤怪兽并装备此卡
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或墓地选择1只满足条件的怪兽（受王家之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 成功特殊召唤选择的怪兽并成功将此卡装备给该怪兽
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.Equip(tp,c,tc) then
		-- 把这张卡装备。
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		c:RegisterEffect(e1)
	end
end
-- ②效果（代破）的发动检测，检查装备怪兽是否因战斗或效果被破坏，且此卡是否能送去墓地
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tg=c:GetEquipTarget()
	if chk==0 then return c:IsAbleToGrave() and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
		and tg and tg:IsReason(REASON_BATTLE+REASON_EFFECT) end
	-- 询问玩家是否使用此卡的代替破坏效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- ②效果（代破）的处理函数，将此卡送去墓地代替破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将此卡作为代替送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
-- 过滤墓地或除外状态的鱼族、海龙族、水族怪兽
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsRace(RACE_AQUA+RACE_FISH+RACE_SEASERPENT) and c:IsAbleToDeck()
end
-- ③效果的发动检测与取对象处理
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	-- 检查自己的墓地或除外状态是否存在至少1只满足条件的鱼族、海龙族、水族怪兽
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,e:GetHandler()) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择最多3只墓地或除外状态的鱼族、海龙族、水族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,3,nil)
	-- 设置回到卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- ③效果的处理函数，将作为对象的怪兽回到卡组
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与该连锁相关的对象怪兽
	local g=Duel.GetTargetsRelateToChain()
	if g:GetCount()>0 then
		-- 将对象怪兽送回持有者卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
