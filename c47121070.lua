--宝玉の双璧
-- 效果：
-- ①：自己的「宝玉兽」怪兽被战斗破坏送去墓地时才能发动。从卡组选1只「宝玉兽」怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置，这个回合自己受到的战斗伤害变成0。
function c47121070.initial_effect(c)
	-- ①：自己的「宝玉兽」怪兽被战斗破坏送去墓地时才能发动。从卡组选1只「宝玉兽」怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置，这个回合自己受到的战斗伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c47121070.tfcon)
	e1:SetTarget(c47121070.tftg)
	e1:SetOperation(c47121070.tfop)
	c:RegisterEffect(e1)
end
-- 筛选满足发动条件的怪兽：必须是「宝玉兽」怪兽、位于墓地、此前由我方控制且因战斗破坏被送去墓地。
function c47121070.filter(c,tp)
	return c:IsSetCard(0x1034) and c:IsLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp) and c:IsReason(REASON_BATTLE)
end
-- 发动条件判定：被战斗破坏送去墓地的怪兽组中存在至少1只满足filter条件的「宝玉兽」怪兽，即满足“自己的「宝玉兽」怪兽被战斗破坏送去墓地时”的发动时机。
function c47121070.tfcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c47121070.filter,1,nil,tp)
end
-- 筛选卡组中可选的「宝玉兽」怪兽：必须是「宝玉兽」怪兽、怪兽卡且未被禁止使用。
function c47121070.tffilter(c)
	return c:IsSetCard(0x1034) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 发动时合法性检查：自己魔法与陷阱区域有空位，且卡组中存在符合条件的「宝玉兽」怪兽，否则不能发动。
function c47121070.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 非处理时（chk==0）检查：我方魔法与陷阱区域必须有可用空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并且卡组中存在1张以上符合条件的「宝玉兽」怪兽，才能满足发动条件。
		and Duel.IsExistingMatchingCard(c47121070.tffilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果处理：从卡组选1只「宝玉兽」怪兽表侧表示放置到自己的魔法与陷阱区域（视为永续魔法），并给自己适用本回合战斗伤害变为0的效果。
function c47121070.tfop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时再次确认魔陷区仍有空位，若已无空位则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择一张要放置到场上的卡（HINTMSG_TOFIELD）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组选出1只符合条件的「宝玉兽」怪兽（处理时选择，不取对象）。
	local g=Duel.SelectMatchingCard(tp,c47121070.tffilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		-- 将选中的「宝玉兽」怪兽从卡组移动到己方魔法与陷阱区域，表侧表示放置，并使其效果立即适用。
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		-- 当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
		-- 这个回合自己受到的战斗伤害变成0。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(1,0)
		e2:SetValue(1)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 将“本回合自己受到的战斗伤害变成0”的效果注册给己方玩家，持续到结束阶段。
		Duel.RegisterEffect(e2,tp)
	end
end
