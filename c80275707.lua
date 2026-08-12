--道化鳥ラフィンパフィン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：场上有表侧表示的魔法·陷阱卡存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：把自己场上1只鸟兽族怪兽解放，以场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张表侧表示的卡回到持有者手卡。这个回合，自己不能把这个效果回到手卡的卡以及那些同名卡的效果发动。自己场上的怪兽只有鸟兽族怪兽的场合，这个效果在对方回合也能发动。
local s,id,o=GetID()
-- 注册卡片效果：①手卡特殊召唤的起动效果，②解放鸟兽族怪兽使场上表侧魔陷回手的起动效果，以及在自己场上仅有鸟兽族怪兽时可在对方回合发动的诱发即时效果。
function s.initial_effect(c)
	-- ①：场上有表侧表示的魔法·陷阱卡存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：把自己场上1只鸟兽族怪兽解放，以场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张表侧表示的卡回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(s.tohcon1)
	e2:SetCost(s.tohcost)
	e2:SetTarget(s.tohtg)
	e2:SetOperation(s.tohop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMING_END_PHASE+TIMING_EQUIP)
	e3:SetCondition(s.tohcon2)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示的魔法·陷阱卡。
function s.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsFaceup()
end
-- 效果①的发动条件：场上有表侧表示的魔法·陷阱卡存在。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方场上是否存在至少1张表侧表示的魔法·陷阱卡。
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 效果①的发动准备：检查自身是否能特殊召唤以及怪兽区域是否有空位。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用于特殊召唤的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁中的操作信息为“特殊召唤自身”。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：将这张卡从手卡特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤条件：非表侧表示的怪兽，或者表侧表示但不是鸟兽族的怪兽。
function s.confilter(c)
	return not (c:IsFaceup() and c:IsRace(RACE_WINDBEAST)) or c:IsFacedown()
end
-- 效果②作为起动效果发动的条件：自己场上有非鸟兽族怪兽存在（或没有怪兽）。
function s.tohcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上的所有怪兽。
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return g:FilterCount(s.confilter,nil)>0
end
-- 效果②作为诱发即时效果发动的条件：自己场上的怪兽只有鸟兽族怪兽。
function s.tohcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上的所有怪兽。
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return #g>0 and g:FilterCount(s.confilter,nil)==0
end
-- 过滤条件：可解放的鸟兽族怪兽，且场上存在除该怪兽以外的表侧表示魔陷作为回手对象。
function s.costfilter(c,tp)
	return c:IsRace(RACE_WINDBEAST) and (c:IsControler(tp) or c:IsFaceup())
		-- 检查场上是否存在除被解放怪兽以外的、可作为效果对象的表侧表示魔法·陷阱卡。
		and Duel.IsExistingTarget(s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
-- 效果②的发动代价：解放自己场上1只鸟兽族怪兽。
function s.tohcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可作为解放代价的鸟兽族怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.costfilter,1,nil,tp) end
	-- 玩家选择自己场上1只鸟兽族怪兽作为解放对象。
	local g=Duel.SelectReleaseGroup(tp,s.costfilter,1,1,nil,tp)
	-- 将选中的怪兽解放。
	Duel.Release(g,REASON_COST)
end
-- 过滤条件：场上表侧表示且能回到手牌的魔法·陷阱卡。
function s.cfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsFaceup() and c:IsAbleToHand()
end
-- 效果②的发动准备：选择场上1张表侧表示的魔法·陷阱卡为对象。
function s.tohtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.cfilter(chkc) end
	local c=e:GetHandler()
	-- 检查场上是否存在符合条件的表侧表示魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上1张表侧表示的魔法·陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁中的操作信息为“将选中的卡送回手牌”。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的效果处理：使作为对象的卡回到持有者手卡，并限制本回合该卡及同名卡的效果发动。
function s.tohop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup()
		-- 将对象卡送回持有者的手牌并判断是否成功。
		and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_HAND) then
		-- 这个回合，自己不能把这个效果回到手卡的卡以及那些同名卡的效果发动。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.aclimit)
		e1:SetLabel(tc:GetCode())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册全局效果，限制玩家在本回合内发动该同名卡的效果。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制条件：禁止发动与回到手牌的卡同名的卡片效果。
function s.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end
