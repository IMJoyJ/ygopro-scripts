--海晶乙女グレート・バブル・リーフ
-- 效果：
-- 水属性怪兽2只以上
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：双方的准备阶段，从自己墓地以及自己场上的表侧表示怪兽之中把1只水属性怪兽除外才能发动。自己从卡组抽1张。
-- ②：每次怪兽被除外发动。这张卡的攻击力直到回合结束时上升那些除外的怪兽数量×600。
-- ③：从手卡把1只水属性怪兽送去墓地才能发动。选除外的1只自己的「海晶少女」怪兽特殊召唤。
function c47910940.initial_effect(c)
	-- 为这张卡添加连接召唤手续：可以用2只以上水属性怪兽作为连接素材。
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
	-- 这个卡名的③的效果1回合只能使用1次。③：从手卡把1只水属性怪兽送去墓地才能发动。选除外的1只自己的「海晶少女」怪兽特殊召唤。
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
-- 定义①代价的过滤函数：被选中的卡必须是水属性、可作为代价除外，并且是表侧表示怪兽或在墓地中。
function c47910940.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToRemoveAsCost() and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
-- ①的代价处理：从自己场上表侧表示水属性怪兽和自己墓地的水属性怪兽中选择1只除外作为发动代价。
function c47910940.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：确认自己场上表侧表示或墓地中是否存在至少1只满足条件的水属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c47910940.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	-- 给玩家显示选择提示信息“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己场上表侧表示或自己墓地的水属性怪兽中选择1张作为代价。
	local g=Duel.SelectMatchingCard(tp,c47910940.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的卡以表侧表示除外，作为①的发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①的目标设定：确认自己可以抽1张卡，并把抽卡对象锁定为自己、抽卡数设为1。
function c47910940.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否可以进行1张卡的抽卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的对象玩家设置为抽卡玩家（自己）。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为1（抽卡数量）。
	Duel.SetTargetParam(1)
	-- 设置操作信息：本次效果包含抽卡分类，不指定具体卡片，预计处理1张，对象为自己，位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ①的效果处理：取出目标玩家和抽卡数，让该玩家执行抽卡。
function c47910940.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取设定的对象玩家（抽卡者）和对象参数（抽卡数）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因让对象玩家抽对应数量的卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 定义②的触发怪兽过滤器：被除外的卡必须是表侧表示的怪兽且不是衍生物。
function c47910940.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_TOKEN)
end
-- ②的发动条件：本次被除外的怪兽中有符合条件的怪兽，且不包含这张卡自身。
function c47910940.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c47910940.atkfilter,1,nil) and not eg:IsContains(e:GetHandler())
end
-- ②的效果处理：统计本次被除外的符合条件的怪兽数量，为这张卡赋予攻击力上升该数量×600直到回合结束的效果。
function c47910940.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=eg:FilterCount(c47910940.atkfilter,nil)
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到回合结束时上升那些除外的怪兽数量×600。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*600)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 定义③代价的过滤函数：从手卡选择1只水属性且可作为代价送去墓地的怪兽。
function c47910940.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToGraveAsCost()
end
-- ③的代价处理：从手卡将1只水属性怪兽送去墓地作为发动代价。
function c47910940.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：确认手卡中是否存在至少1只满足条件的水属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c47910940.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 给玩家显示选择提示信息“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡选择1只水属性怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,c47910940.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的卡送去墓地，作为③的发动代价。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义特殊召唤对象过滤函数：选择除外区中表侧表示、属于「海晶少女」系列且可以被特殊召唤的怪兽。
function c47910940.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x12b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③的发动条件与操作信息设定：确认自己主要怪兽区有空位，且除外区存在可特殊召唤的「海晶少女」怪兽；随后设置特殊召唤的操作信息。
function c47910940.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查除外区是否存在满足特殊召唤条件的「海晶少女」怪兽。
		and Duel.IsExistingMatchingCard(c47910940.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果包含特殊召唤分类，不指定具体卡片，预计处理1张，对象为自己，位置为除外区。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
-- ③的效果处理：若主要怪兽区仍有空位，则从除外区选择1只「海晶少女」怪兽，以表侧表示特殊召唤到自己场上。
function c47910940.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己主要怪兽区是否有空位，若没有则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家显示选择提示信息“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从除外区选择1只满足条件的「海晶少女」怪兽。
	local g=Duel.SelectMatchingCard(tp,c47910940.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
