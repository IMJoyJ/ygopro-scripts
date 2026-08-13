--武神隠
-- 效果：
-- 选择自己场上1只名字带有「武神」的超量怪兽才能发动。选择的怪兽除外，场上的怪兽全部回到手卡。直到发动后第2次的自己的结束阶段时，双方不能召唤·反转召唤·特殊召唤，双方受到的全部伤害变成0。此外，发动后第2次的自己的结束阶段时发动。这张卡的效果除外的怪兽特殊召唤，选择自己墓地1只名字带有「武神」的怪兽在那只特殊召唤的怪兽下面重叠作为超量素材。
function c11221418.initial_effect(c)
	-- 选择自己场上1只名字带有「武神」的超量怪兽才能发动。选择的怪兽除外，场上的怪兽全部回到手卡。直到发动后第2次的自己的结束阶段时，双方不能召唤·反转召唤·特殊召唤，双方受到的全部伤害变成0。此外，发动后第2次的自己的结束阶段时发动。这张卡的效果除外的怪兽特殊召唤，选择自己墓地1只名字带有「武神」的怪兽在那只特殊召唤的怪兽下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c11221418.target)
	e1:SetOperation(c11221418.activate)
	c:RegisterEffect(e1)
end
-- 定义发动对象过滤器：对象必须是自己场上表侧表示、名字带有「武神」的超量怪兽且可被除外，并且场上（除对象外）至少存在1张能被送回手卡的怪兽，以保证回手效果有可处理的对象。
function c11221418.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x88) and c:IsType(TYPE_XYZ) and c:IsAbleToRemove()
		-- 检查以玩家0视角的双方怪兽区中，除对象外是否存在至少1张可回手的怪兽（即发动时场上还有其他可回手的怪兽，满足‘场上的怪兽全部回到手卡’的处理前提）。
		and Duel.IsExistingMatchingCard(Card.IsAbleToHand,0,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
-- 发动时的目标选择与操作信息设置：从自己怪兽区选择1只符合条件的「武神」超量怪兽作为取对象目标，并预判场上其余可回手怪兽作为回手效果的对象集合，随后写入除外和回手的操作信息。
function c11221418.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c11221418.filter(chkc) end
	-- 发动条件判定：确认自己场上是否存在至少1只满足filter条件的「武神」超量怪兽可供选择，若不满足则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c11221418.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示选择提示，提示文字为“请选择要除外的卡”，用于选择要除外的武神超量怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己场上选择1只满足filter的怪兽作为效果对象，并自动登记为当前连锁的取对象目标。
	local g=Duel.SelectTarget(tp,c11221418.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 获取场上（双方怪兽区）除对象外所有可以回手的怪兽，构成回手效果的目标集合。
	local tg=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,g:GetFirst())
	-- 设置操作信息：本次效果确定会将选择的1只对象怪兽除外（CATEGORY_REMOVE）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 设置操作信息：本次效果确定会将上述集合中的所有怪兽返回持有者手牌（CATEGORY_TOHAND），数量为集合数量。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,tg:GetCount(),0,0)
end
-- 效果处理：先除外所选武神超量怪兽并记录标记；再将场上所有可回手怪兽返回手牌；随后设置直到第2次自己的结束阶段为止双方不能召唤/反转召唤/特殊召唤、伤害全为0的效果，并注册到结束阶段时解除限制和特殊召唤除外怪兽的辅助效果。
function c11221418.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的那只「武神」超量怪兽（作为要被除外的对象）。
	local tc=Duel.GetFirstTarget()
	-- 若对象仍与当前效果相关联，则将其表侧表示除外；只有除外成功后才继续执行后续回手、限制和特殊召唤处理。
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
		tc:RegisterFlagEffect(11221418,RESET_EVENT+RESETS_STANDARD,0,0)
		-- 获取当前场上（双方怪兽区）所有能够返回手牌的怪兽，准备全部回手（此处不排除已除外的对象）。
		local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		if g:GetCount()==0 then return end
		-- 以效果原因将上述所有怪兽返回其持有者手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 计算预定的解除/特殊召唤时点：初始设为当前自己回合数加1，用于定位“发动后第2次的自己的结束阶段”。
		local rct=Duel.GetTurnCount(tp)+1
		-- 如果当前不是自己的回合，则目标结束阶段会顺延一个对手回合，因此将rct再+1，确保对应第2次自己的结束阶段。
		if Duel.GetTurnPlayer()~=tp then rct=rct+1 end
		-- 对应效果原文：“直到发动后第2次的自己的结束阶段时，双方不能召唤·反转召唤·特殊召唤，双方受到的全部伤害变成0。”这里实现禁止通常召唤、反转召唤、特殊召唤。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_SUMMON)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(1,1)
		e2:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		-- 将禁止通常召唤（EFFECT_CANNOT_SUMMON）的永续效果注册到场上，对双方玩家生效，持续到第2次自己的结束阶段。
		Duel.RegisterEffect(e2,tp)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
		e3:SetLabelObject(e2)
		-- 将禁止反转召唤（EFFECT_CANNOT_FLIP_SUMMON）的永续效果注册到场上，对双方玩家生效。
		Duel.RegisterEffect(e3,tp)
		local e4=e3:Clone()
		e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e4:SetLabelObject(e3)
		-- 将禁止特殊召唤（EFFECT_CANNOT_SPECIAL_SUMMON）的永续效果注册到场上，对双方玩家生效。
		Duel.RegisterEffect(e4,tp)
		-- 对应效果原文：“双方受到的全部伤害变成0。”这里通过EFFECT_CHANGE_DAMAGE和EFFECT_NO_EFFECT_DAMAGE实现所有对玩家的伤害数值变为0，并准备结束阶段重置辅助效果。
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_FIELD)
		e5:SetCode(EFFECT_CHANGE_DAMAGE)
		e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e5:SetTargetRange(1,1)
		e5:SetValue(0)
		e5:SetLabelObject(e4)
		e5:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		-- 注册伤害变更效果：将双方玩家受到的全部战斗伤害与效果伤害数值改为0。
		Duel.RegisterEffect(e5,tp)
		local e6=e5:Clone()
		e6:SetCode(EFFECT_NO_EFFECT_DAMAGE)
		e6:SetLabelObject(e5)
		e6:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		-- 注册“效果伤害无效”的标记效果（EFFECT_NO_EFFECT_DAMAGE），用于标识伤害已变为0，防止重复计算/叠加。
		Duel.RegisterEffect(e6,tp)
		-- 对应效果原文：“直到发动后第2次的自己的结束阶段时，双方不能召唤·反转召唤·特殊召唤，双方受到的全部伤害变成0。”此处的连续效果在到达指定结束阶段时统一解除上述限制和伤害无效效果。
		local e7=Effect.CreateEffect(c)
		e7:SetDescription(aux.Stringid(11221418,0))  --"结束召唤限制"
		e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e7:SetCode(EVENT_PHASE+PHASE_END)
		e7:SetCountLimit(1)
		e7:SetCondition(c11221418.resetcon)
		e7:SetOperation(c11221418.resetop)
		e7:SetLabel(rct)
		e7:SetLabelObject(e6)
		e7:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		-- 注册结束阶段触发效果，在预定的第2次自己的结束阶段时执行resetop，解除e2-e6的限制与伤害无效效果。
		Duel.RegisterEffect(e7,tp)
		-- 对应效果原文：“此外，发动后第2次的自己的结束阶段时发动。这张卡的效果除外的怪兽特殊召唤，选择自己墓地1只名字带有「武神」的怪兽在那只特殊召唤的怪兽下面重叠作为超量素材。”
		local e8=Effect.CreateEffect(c)
		e8:SetDescription(aux.Stringid(11221418,1))  --"这张卡的效果除外的怪兽特殊召唤"
		e8:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e8:SetCode(EVENT_PHASE+PHASE_END)
		e8:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e8:SetCountLimit(1)
		e8:SetCondition(c11221418.spcon)
		e8:SetTarget(c11221418.sptg)
		e8:SetOperation(c11221418.spop)
		e8:SetLabel(rct)
		e8:SetLabelObject(tc)
		e8:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		-- 注册第2次自己的结束阶段时发动特殊召唤效果的触发效果，处理除外怪兽的特殊召唤及墓地武神怪兽叠放。
		Duel.RegisterEffect(e8,tp)
	end
end
-- 解除限制效果的发动条件：必须是自己的结束阶段，且当前回合数等于预设的rct（即第2次自己的结束阶段）。
function c11221418.resetcon(e,tp,eg,ep,ev,re,r,rp)
	-- 条件判断：当前回合玩家为自己且当前回合数等于e:GetLabel()预设的结束阶段回合数，满足时才执行重置。
	return Duel.GetTurnPlayer()==tp and e:GetLabel()==Duel.GetTurnCount(tp)
end
-- 重置处理：依据LabelObject链依次重置e2、e3、e4、e5、e6以及e7自身，从而解除召唤限制、反转召唤限制、特殊召唤限制和伤害变为0的效果。
function c11221418.resetop(e,tp,eg,ep,ev,re,r,rp)
	local e6=e:GetLabelObject()
	local e5=e6:GetLabelObject()
	local e4=e5:GetLabelObject()
	local e3=e4:GetLabelObject()
	local e2=e3:GetLabelObject()
	e2:Reset()
	e3:Reset()
	e4:Reset()
	e5:Reset()
	e6:Reset()
	e:Reset()
end
-- 特殊召唤效果的发动条件：同样要求当前是自己的结束阶段且回合数等于预设的rct，即第2次自己的结束阶段。
function c11221418.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 条件判断：当前回合玩家为自己且当前回合数等于预设的第2次自己结束阶段回合数，满足时特殊召唤效果才发动。
	return Duel.GetTurnPlayer()==tp and e:GetLabel()==Duel.GetTurnCount(tp)
end
-- 墓地素材过滤器：选择自己墓地中名字带有「武神」的怪兽（且可成为超量素材）作为叠放素材。
function c11221418.mfilter(c)
	return c:IsSetCard(0x88) and c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
-- 特殊召唤效果发动时的目标选择：从自己墓地选1只「武神」怪兽作为超量素材，同时登记被除外的怪兽为特殊召唤对象，并写入离墓地和特殊召唤的操作信息。
function c11221418.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c11221418.mfilter(chkc) end
	if chk==0 then return true end
	local tc=e:GetLabelObject()
	-- 显示选择提示“请选择要作为超量素材的卡”，供玩家选择墓地的武神怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 从自己墓地选择1只满足mfilter的「武神」怪兽，并登记为当前连锁的对象（超量素材）。
	local g=Duel.SelectTarget(tp,c11221418.mfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：所选墓地素材将被从墓地移出（CATEGORY_LEAVE_GRAVE），作为超量素材使用。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,g:GetCount(),0,0)
	-- 设置操作信息：被本卡效果除外的怪兽将被特殊召唤（CATEGORY_SPECIAL_SUMMON），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
end
-- 特殊召唤处理：将被除外且带有标记的怪兽特殊召唤，成功后把之前选择的墓地武神怪兽叠放在其下方作为超量素材。
function c11221418.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 获取在sptg阶段选择的墓地「武神」怪兽，作为要叠放的超量素材。
	local mc=Duel.GetFirstTarget()
	-- 确认被除外的怪兽仍带有本卡标记（确实因本卡除外）且特殊召唤成功时，才继续执行叠放素材的处理。
	if tc:GetFlagEffect(11221418)~=0 and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		if mc and mc:IsRelateToEffect(e) and mc:IsCanOverlay() then
			-- 将选择的墓地「武神」怪兽作为超量素材叠放在已特殊召唤的怪兽下方（Duel.Overlay）。
			Duel.Overlay(tc,Group.FromCards(mc))
		end
	end
end
