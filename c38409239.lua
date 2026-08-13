--ゴーティス・コスモス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：除外状态的鱼族怪兽数量的以下效果各适用。
-- ●1只以上：这个回合，自己的鱼族怪兽不会被战斗破坏。
-- ●4只以上：这个回合，自己场上的鱼族怪兽的效果的发动以及那些发动的效果不会被无效化。
-- ●8只以上：从额外卡组把1只鱼族同调怪兽当作同调召唤作特殊召唤。
local s,id,o=GetID()
-- 创建并注册该卡的发动效果：效果类别为特殊召唤，类型为魔法卡的发动，可在自由时点发动，并设置同名卡1回合1次的发动限制以及目标判定和处理函数。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：除外状态的鱼族怪兽数量的以下效果各适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤条件：统计除外区中的表侧表示鱼族怪兽，用于判断本卡效果适用的等级。
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH)
end
-- 发动判定：检查除外区是否存在表侧鱼族怪兽；若数量达到8只以上，还须额外确认不存在必须作为同调素材的限制，并且额外卡组存在可作为同调召唤的鱼族同调怪兽。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 统计当前玩家除外区的表侧鱼族怪兽数量，作为效果分级适用依据。
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if chk==0 then return ct>0
		-- 当除外区鱼族怪兽达到8只以上时，检查是否受到“必须作为同调素材”相关效果的限制。
		and (ct<8 or aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
			-- 当除外区鱼族怪兽达到8只以上时，检查额外卡组中是否存在满足条件的鱼族同调怪兽可供特殊召唤。
			and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp)) end
	if ct>=8 then
		-- 设置操作信息：若除外区鱼族怪兽为8只以上，则本次效果可能进行从额外卡组的特殊召唤，供相关效果（如星尘龙）进行发动检测。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	end
end
-- 定义可特殊召唤的额外卡组怪兽条件：必须是鱼族同调怪兽，可当作同调召唤特殊召唤，且额外怪兽区域有空位。
function s.filter(c,e,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_FISH)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		-- 额外确认该鱼族同调怪兽有可用的额外怪兽区域空格，即可以特殊召唤到场上。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果处理：根据除外区鱼族怪兽数量依次适用三个效果——1只以上付与己方鱼族怪兽不被战斗破坏；4只以上付与己方场上鱼族怪兽效果发动及效果不被无效化；8只以上从额外卡组选1只鱼族同调怪兽当作同调召唤特殊召唤。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 统计当前玩家除外区的表侧鱼族怪兽数量，用于决定适用的效果段。
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if ct>0 then
		-- ●1只以上：这个回合，自己的鱼族怪兽不会被战斗破坏。●4只以上：这个回合，自己场上的鱼族怪兽的效果的发动以及那些发动的效果不会被无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		-- 将该“不被战斗破坏”的效果对象限定为持有者为当前玩家的场上鱼族怪兽。
		e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_FISH))
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		-- 把“鱼族怪兽不会被战斗破坏”的场上永续效果注册到当前玩家，持续至回合结束。
		Duel.RegisterEffect(e1,tp)
		-- 中断当前效果处理，使后续效果视为不同时处理，避免因同一效果处理导致时点被错过。
		Duel.BreakEffect()
	end
	if ct>3 then
		-- ●4只以上：这个回合，自己场上的鱼族怪兽的效果的发动以及那些发动的效果不会被无效化。●8只以上：从额外卡组把1只鱼族同调怪兽当作同调召唤作特殊召唤。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_INACTIVATE)
		e2:SetTargetRange(LOCATION_MZONE,0)
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetValue(s.efilter)
		-- 注册效果：自己场上的鱼族怪兽的效果的发动不会被无效化。
		Duel.RegisterEffect(e2,tp)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_CANNOT_DISEFFECT)
		-- 注册效果：自己场上的鱼族怪兽的已经发动的效果不会被无效化。
		Duel.RegisterEffect(e3,tp)
		-- 中断当前效果，使后续的特殊召唤处理在时点上独立，正确触发召唤成功等时点。
		Duel.BreakEffect()
	end
	-- 判断除外区鱼族怪兽数量是否达到8只以上，并再次确认不存在必须作为同调素材的限制。
	if ct>7 and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 若数量达到8只以上，检查额外卡组是否存在满足条件的鱼族同调怪兽可供特殊召唤。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) then
		-- 弹出选择提示，提示玩家选择要特殊召唤的额外卡组鱼族同调怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只满足条件的鱼族同调怪兽，作为本次特殊召唤的对象。
		local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
		tc:SetMaterial(nil)
		-- 将选择的怪兽以同调召唤的方式特殊召唤到己方场上；若召唤成功，则执行同调召唤完成后的处理。
		if Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
			tc:CompleteProcedure()
		end
	end
end
-- 定义“自己场上鱼族怪兽的效果的发动以及那些发动的效果不会被无效化”的判定条件：连锁发动者为自身，发动效果为怪兽效果，且该效果发动的怪兽为鱼族、位于己方主要怪兽区。
function s.efilter(e,ct)
	local p=e:GetHandlerPlayer()
	-- 获取当前连锁的触发效果、触发玩家和触发位置，用于判断该效果是否属于自己场上的鱼族怪兽的效果。
	local te,tp,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	return p==tp and te:IsActiveType(TYPE_MONSTER) and te:GetHandler():IsRace(RACE_FISH) and loc&LOCATION_MZONE>0
end
