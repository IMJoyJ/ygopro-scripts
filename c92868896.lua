--ドラグニティ－セナート
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：从手卡丢弃1张「龙骑兵团」卡才能发动。从卡组选1只「龙骑兵团」调整当作装备卡使用给这张卡装备。这个效果的发动后，直到回合结束时自己不是龙族怪兽不能从额外卡组特殊召唤。
-- ②：自己场上的「龙骑兵团」卡被战斗·效果破坏的场合，可以作为代替把给这张卡装备的1张「龙骑兵团」卡破坏。
function c92868896.initial_effect(c)
	-- ①：从手卡丢弃1张「龙骑兵团」卡才能发动。从卡组选1只「龙骑兵团」调整当作装备卡使用给这张卡装备。这个效果的发动后，直到回合结束时自己不是龙族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92868896,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,92868896)
	e1:SetCost(c92868896.eqcost)
	e1:SetTarget(c92868896.eqtg)
	e1:SetOperation(c92868896.eqop)
	c:RegisterEffect(e1)
	-- ②：自己场上的「龙骑兵团」卡被战斗·效果破坏的场合，可以作为代替把给这张卡装备的1张「龙骑兵团」卡破坏。
	local e2=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92868896,1))
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c92868896.reptg)
	e2:SetValue(c92868896.repval)
	e2:SetOperation(c92868896.repop)
	c:RegisterEffect(e2)
end
-- 过滤函数：手卡中可以丢弃的「龙骑兵团」卡
function c92868896.cfilter(c)
	return c:IsSetCard(0x29) and c:IsDiscardable()
end
-- ①效果的发动代价：从手卡丢弃1张「龙骑兵团」卡
function c92868896.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在除自身以外的「龙骑兵团」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c92868896.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 玩家选择并丢弃1张手卡中的「龙骑兵团」卡
	Duel.DiscardHand(tp,c92868896.cfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- 过滤函数：卡组中未被禁止且可以装备的「龙骑兵团」调整怪兽
function c92868896.eqfilter(c,ec)
	return c:IsSetCard(0x29) and c:IsType(TYPE_TUNER) and not c:IsForbidden()
end
-- ①效果的靶向/发动准备：检查魔法与陷阱区域是否有空位，以及卡组中是否存在可装备的「龙骑兵团」调整怪兽
function c92868896.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组中是否存在满足条件的「龙骑兵团」调整怪兽
		and Duel.IsExistingMatchingCard(c92868896.eqfilter,tp,LOCATION_DECK,0,1,nil,e:GetHandler()) end
end
-- ①效果的实际处理：将卡组中的「龙骑兵团」调整怪兽装备给这张卡，并适用额外卡组特殊召唤限制
function c92868896.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查魔法与陷阱区域是否有空位，且自身在场上表侧表示存在并与效果关联
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 提示玩家选择要装备的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 从卡组选择1只满足条件的「龙骑兵团」调整怪兽
		local g=Duel.SelectMatchingCard(tp,c92868896.eqfilter,tp,LOCATION_DECK,0,1,1,nil,c)
		if g:GetCount()>0 then
			-- 将选择的怪兽作为装备卡装备给这张卡
			Duel.Equip(tp,g:GetFirst(),c)
			-- 当作装备卡使用给这张卡装备
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c92868896.eqlimit)
			e1:SetLabelObject(c)
			g:GetFirst():RegisterEffect(e1)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是龙族怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c92868896.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 向玩家注册不能从额外卡组特殊召唤龙族以外怪兽的限制效果
	Duel.RegisterEffect(e2,tp)
end
-- 装备限制：只能装备给作为效果发动源的这张卡
function c92868896.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 特殊召唤限制：不能从额外卡组特殊召唤龙族以外的怪兽
function c92868896.splimit(e,c)
	return not c:IsRace(RACE_DRAGON) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤函数：自己场上因战斗或效果而被破坏的「龙骑兵团」卡
function c92868896.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsOnField() and c:IsSetCard(0x29)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT)) and not c:IsReason(REASON_REPLACE)
end
-- 过滤函数：给这张卡装备的、可被破坏的「龙骑兵团」卡
function c92868896.desfilter(c,e)
	return c:IsLocation(LOCATION_SZONE) and c:IsSetCard(0x29)
		and e:GetHandler():GetEquipGroup():IsContains(c)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
-- ②效果的代替破坏处理：检查是否有自己场上的「龙骑兵团」卡被破坏，以及是否有可代替破坏的装备卡
function c92868896.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c92868896.repfilter,1,nil,tp)
		-- 检查自己场上是否有给这张卡装备的「龙骑兵团」卡可以作为代替破坏
		and Duel.IsExistingMatchingCard(c92868896.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,e) end
	-- 询问玩家是否发动代替破坏的效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 提示玩家选择要代替破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 选择1张给这张卡装备的「龙骑兵团」卡作为代替破坏的对象
		local g=Duel.SelectMatchingCard(tp,c92868896.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,e)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	end
	return false
end
-- 代替破坏的价值函数：确定被代替破坏的卡是否符合条件
function c92868896.repval(e,c)
	return c92868896.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏的实际操作：将选中的装备卡破坏以代替原本的破坏
function c92868896.repop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 破坏作为代替的装备卡
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
