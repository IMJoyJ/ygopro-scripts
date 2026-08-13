--超重武者ドウC－N
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从自己的额外卡组（表侧）把1只机械族灵摆怪兽加入手卡。
-- ②：自己墓地没有魔法·陷阱卡存在的场合，把这张卡解放才能发动。除「超重武者 同心C-N」外的1只攻击力1500以下的机械族·地属性怪兽从自己的手卡·墓地特殊召唤。
function c5182107.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡召唤·特殊召唤的场合才能发动。从自己的额外卡组（表侧）把1只机械族灵摆怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5182107,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,5182107)
	e1:SetTarget(c5182107.thtg)
	e1:SetOperation(c5182107.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合各能使用1次。②：自己墓地没有魔法·陷阱卡存在的场合，把这张卡解放才能发动。除「超重武者 同心C-N」外的1只攻击力1500以下的机械族·地属性怪兽从自己的手卡·墓地特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(5182107,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,5182108)
	e3:SetCondition(c5182107.spcon)
	e3:SetCost(c5182107.spcost)
	e3:SetTarget(c5182107.sptg)
	e3:SetOperation(c5182107.spop)
	c:RegisterEffect(e3)
end
-- ①效果的检索过滤函数：选择额外卡组表侧表示、机械族、灵摆怪兽且能被加入手卡的卡作为对象。
function c5182107.thfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- ①效果的发动时点：确认自己的额外卡组存在满足过滤条件的表侧机械族灵摆怪兽；并设置将1张该类卡加入手卡的操作信息。
function c5182107.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己的额外卡组（表侧）中是否存在至少1张符合条件的机械族灵摆怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c5182107.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 登记处理信息：该效果将把1张额外卡组的卡加入手卡（数量1，所属玩家tp，位置额外卡组），用于连锁判定等。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果处理：提示玩家选择1张符合条件的表侧机械族灵摆怪兽，将其加入手卡。
function c5182107.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家进行选择操作，消息类型为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己额外卡组的表侧卡中，选择1张满足过滤条件的机械族灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,c5182107.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡，原因是效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- ②效果的发动条件：确认自己的墓地不存在任何魔法·陷阱卡。
function c5182107.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否没有魔法·陷阱卡（存在任意魔陷则返回false）。
	return not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL+TYPE_TRAP)
end
-- ②效果发动代价：判断此卡可以解放且解放后有可用怪兽区，然后将此卡解放作为代价。
function c5182107.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 代价合法性检查：此卡可以被解放，且解放后自己场上有可用的怪兽区域（用于特殊召唤）。
	if chk==0 then return c:IsReleasable() and Duel.GetMZoneCount(tp,c)>0 end
	-- 将此卡解放作为发动代价（REASON_COST）。
	Duel.Release(c,REASON_COST)
end
-- ②效果的特召过滤函数：选择攻击力1500以下、机械族、地属性、卡名不是「超重武者 同心C-N」，且能被效果特殊召唤的怪兽。
function c5182107.spfilter(c,e,tp)
	return c:IsAttackBelow(1500) and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH)
		and not c:IsCode(5182107) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动时点：确认自己的手卡·墓地存在满足过滤条件的怪兽，并登记将1只该怪兽特殊召唤的操作信息。
function c5182107.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己的手卡·墓地中是否存在至少1只满足条件的可特殊召唤的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c5182107.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 登记处理信息：该效果将把1只来自手卡或墓地的怪兽特殊召唤，用于连锁判定等。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ②效果处理：确认有可用怪兽区后，提示玩家选择1只符合条件的怪兽（并考虑王家长眠之谷的影响），以表侧表示特殊召唤到自己场上。
function c5182107.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己场上有可用的怪兽区域，避免因连锁导致格子不足。
	if Duel.GetMZoneCount(tp)>0 then
		-- 提示玩家进行选择操作，消息类型为“请选择要特殊召唤的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从自己手卡·墓地选择1只满足过滤条件且不受王家长眠之谷影响的怪兽（若墓地效果被无效则不能选择）。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c5182107.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽以表侧表示特殊召唤到自己的场上，不附加特殊召唤方式，并正常检查召唤条件与苏生限制。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
