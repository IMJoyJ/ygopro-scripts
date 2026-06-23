--宝玉の双璧
-- 效果：
-- ①：自己的「宝玉兽」怪兽被战斗破坏送去墓地时才能发动。从卡组选1只「宝玉兽」怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置，这个回合自己受到的战斗伤害变成0。
function c47121070.initial_effect(c)
	-- 效果发动条件为自己的「宝玉兽」怪兽被战斗破坏送去墓地时，将此卡当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置，并使自己在该回合受到的战斗伤害变为0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c47121070.tfcon)
	e1:SetTarget(c47121070.tftg)
	e1:SetOperation(c47121070.tfop)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查是否为「宝玉兽」怪兽且处于墓地、之前控制者为自己、破坏原因为战斗。
function c47121070.filter(c,tp)
	return c:IsSetCard(0x1034) and c:IsLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp) and c:IsReason(REASON_BATTLE)
end
-- 条件判断函数：检查是否有满足过滤条件的卡片被战斗破坏送入墓地。
function c47121070.tfcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c47121070.filter,1,nil,tp)
end
-- 选择目标函数：从卡组中选择一只「宝玉兽」怪兽，且该怪兽未被禁止使用。
function c47121070.tffilter(c)
	return c:IsSetCard(0x1034) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 效果发动时的处理函数：检查场上是否还有空位以及卡组中是否存在符合条件的怪兽。
function c47121070.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的魔法与陷阱区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断卡组中是否存在符合条件的「宝玉兽」怪兽。
		and Duel.IsExistingMatchingCard(c47121070.tffilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果处理函数：选择一张符合条件的怪兽卡从卡组特殊召唤至魔法与陷阱区域，并将其变为永续魔法卡，同时使自己在本回合内不会受到战斗伤害。
function c47121070.tfop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断场上是否还有空位以放置卡片。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置到场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组中选择一张符合条件的「宝玉兽」怪兽。
	local g=Duel.SelectMatchingCard(tp,c47121070.tffilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		-- 将选中的怪兽特殊召唤至魔法与陷阱区域并表侧表示放置。
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		-- 将选中的怪兽变为永续魔法卡类型。
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
		-- 使自己在本回合内不会受到战斗伤害。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(1,0)
		e2:SetValue(1)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 注册效果，使自己在本回合内不会受到战斗伤害。
		Duel.RegisterEffect(e2,tp)
	end
end
