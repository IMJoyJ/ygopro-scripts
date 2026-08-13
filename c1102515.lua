--暗黒のミミック LV3
-- 效果：
-- 这张卡因为战斗送去墓地的场合，这张卡的控制者从卡组抽1张卡。这张卡因为「暗黑之宝箱怪 LV1」的效果特殊召唤的场合改成抽2张卡。
function c1102515.initial_effect(c)
	-- 这张卡因为战斗送去墓地的场合，这张卡的控制者从卡组抽1张卡。这张卡因为「暗黑之宝箱怪 LV1」的效果特殊召唤的场合改成抽2张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1102515,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c1102515.condition)
	e1:SetTarget(c1102515.target)
	e1:SetOperation(c1102515.operation)
	c:RegisterEffect(e1)
end
c1102515.lvup={74713516}
c1102515.lvdn={74713516}
-- 根据这张卡当前是否是以「暗黑之宝箱怪 LV1」的效果进行的特殊召唤（召唤类型为SUMMON_TYPE_SPECIAL+SUMMON_VALUE_LV），设置效果标记Label为2或1，用于后续决定抽卡数量。
function c1102515.condition(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_LV then e:SetLabel(2)
	else e:SetLabel(1) end
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 效果发动时的目标处理：检查发动合法性后，将抽卡玩家设为这张卡的控制者tp，将抽卡数量设为之前标记的Label值，并登记本次操作为抽卡效果、目标玩家为tp、抽卡数为Label。
function c1102515.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的处理对象玩家设置为这张卡的控制者tp，即由控制者执行抽卡。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的处理参数设置为效果标记Label，即本次应抽取的卡片数量（1或2）。
	Duel.SetTargetParam(e:GetLabel())
	-- 登记操作信息：本次为抽卡效果（CATEGORY_DRAW），不取对象（nil），预计抽卡数量为Label，目标玩家为tp，用于给其他卡牌效果（如星尘龙等）进行连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,e:GetLabel())
end
-- 效果处理时的实际操作：从当前连锁信息中取出之前保存的目标玩家和抽卡数量，然后调用Duel.Draw让该玩家抽对应数量的卡，抽卡原因为效果（REASON_EFFECT）。
function c1102515.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中保存的对象玩家和对象参数，分别赋给局部变量p（抽卡玩家）和d（抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以REASON_EFFECT为原因抽取d张卡，从而完成实际抽卡动作。
	Duel.Draw(p,d,REASON_EFFECT)
end
