--裁きを下す者－ボルテニス
-- 效果：
-- 自己的反击陷阱发动成功的场合，把自己场上全部怪兽作祭品可以特殊召唤。这个方法特殊召唤成功的场合，可以把最多有作祭品的天使族怪兽的数量的对方场上的卡破坏。
function c20951752.initial_effect(c)
	-- 对应效果原文“自己的反击陷阱发动成功的场合”：注册全场连续效果，在每次连锁发动时先将特殊召唤效果标记清零，准备判定本次连锁是否有自己的反击陷阱发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetOperation(c20951752.chop1)
	c:RegisterEffect(e1)
	-- 对应效果原文“自己的反击陷阱发动成功的场合”：在连锁处理结束时，若确认本次连锁中存在自己发动的反击陷阱的发动，则将特殊召唤效果标记置1，表示满足发动成功的条件。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_HAND)
	e2:SetOperation(c20951752.chop2)
	c:RegisterEffect(e2)
	-- 对应效果原文“把自己场上全部怪兽作祭品可以特殊召唤”：此处实现该特殊召唤效果，包含发动条件、解放全部怪兽的代价、特殊召唤目标检查以及实际特殊召唤处理。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20951752,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CHAIN_END)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(c20951752.sumcon)
	e3:SetCost(c20951752.sumcost)
	e3:SetTarget(c20951752.sumtg)
	e3:SetOperation(c20951752.sumop)
	c:RegisterEffect(e3)
	e1:SetLabelObject(e3)
	e2:SetLabelObject(e3)
	-- 对应效果原文“这个方法特殊召唤成功的场合，可以把最多有作祭品的天使族怪兽的数量的对方场上的卡破坏”：此处实现该破坏效果，包含发动条件、目标选择及破坏处理。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(20951752,1))  --"破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(c20951752.descon)
	e4:SetTarget(c20951752.destg)
	e4:SetOperation(c20951752.desop)
	c:RegisterEffect(e4)
	e3:SetLabelObject(e4)
end
-- 当连锁中任意效果发动时，先将特殊召唤效果的标记重置为0，表示尚未确认‘自己的反击陷阱发动成功’。此操作不进入连锁，仅为后续条件判定做准备。
function c20951752.chop1(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(0)
end
-- 在连锁处理结束时，若当前连锁中存在由自己发动的、类型为反击陷阱的卡的效果发动（即‘自己的反击陷阱发动成功’），则将特殊召唤效果的标记设为1，允许后续特殊召唤效果发动。
function c20951752.chop2(e,tp,eg,ep,ev,re,r,rp)
	if rp==1-tp or not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not re:IsActiveType(TYPE_COUNTER) then return end
	e:GetLabelObject():SetLabel(1)
end
-- 作为特殊召唤效果的发动条件，检查特殊召唤效果自身的标记是否为1；只有标记为1（本连锁中有自己的反击陷阱发动成功）时才允许发动。
function c20951752.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabel()==1
end
-- 作为特殊召唤的代价处理：取得自己场上全部可解放怪兽，统计其中天使族怪兽的数量并保存到标记中，然后将这些怪兽全部解放。
function c20951752.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检测阶段，确认自己场上是否存在至少1只可解放的怪兽；若不存在则不能发动特殊召唤效果。
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 获取自己场上所有可解放的怪兽集合，用于作为代价解放。
	local g=Duel.GetReleaseGroup(tp)
	local ct=g:FilterCount(Card.IsRace,nil,RACE_FAIRY)
	-- 处理可能存在的代替解放效果（如暗影敌托邦）的使用次数，确保这些代替解放效果的次数限制被正确扣除。
	aux.UseExtraReleaseCount(g,tp)
	-- 将自己场上全部可解放的怪兽作为代价解放（REASON_COST），并触发相应的离场事件。
	Duel.Release(g,REASON_COST)
	e:GetLabelObject():SetLabel(ct)
end
-- 特殊召唤效果的目标处理：检测此卡自身是否能够被特殊召唤，并设置特殊召唤的操作信息。
function c20951752.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，向系统声明本连锁将执行‘特殊召唤1张卡（此卡自身）’的操作，以便其他卡进行连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果处理：若此卡仍然与效果关联，则以自身效果将其特殊召唤。
function c20951752.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以表侧表示特殊召唤到场，召唤类型标记为SUMMON_VALUE_SELF，以便后续通过GetSummonType判定是否通过该方法特殊召唤成功。
		Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
	end
end
-- 破坏效果的发动条件：判定此卡的召唤类型是否等于SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF，即是否是通过上述方法特殊召唤成功的场合；是才能发动破坏效果。
function c20951752.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 破坏效果的目标设置：确认对方场上有卡可以破坏且保存的祭品天使族数量>0，然后获取对方场上所有卡作为候选，并设置破坏的操作信息。
function c20951752.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在目标检测阶段，检查对方场上是否存在至少1张卡，并且记录的解放的天使族怪兽数量大于0；两者都满足才能发动破坏效果。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) and e:GetLabel()>0 end
	-- 取得对方场上的所有卡片（怪兽和魔陷），作为可能被破坏的对象集合。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息，声明本连锁将进行‘破坏对方场上的卡’的操作，targets为对方场上全部卡，数量为1；实际数量在效果处理时决定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果处理：从对方场上的卡中由玩家选择1到记录的天使族数量张卡，然后将其破坏。
function c20951752.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 在破坏效果处理阶段重新获取对方场上的全部卡，作为实际选择破坏的候选集合（处理时在场才可选）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 给选择者显示‘请选择要破坏的卡’的选择提示，并缓存选择消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local dg=g:Select(tp,1,e:GetLabel(),nil)
	-- 为选中的卡播放被选为对象的动画，并记录这些卡被选为对象（广义），以便触发相关效果。
	Duel.HintSelection(dg)
	-- 将选中的卡片以效果（REASON_EFFECT）破坏并送入墓地。
	Duel.Destroy(dg,REASON_EFFECT)
end
