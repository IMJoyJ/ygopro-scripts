--古代の機械暗黒巨人
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「古代的机械巨人」使用。
-- ②：这张卡召唤·特殊召唤的场合才能发动。除「古代的机械暗黑巨人」外的「古代的机械」卡或「齿车街」合计最多2张从卡组加入手卡。那之后，选自己1张手卡丢弃。这个效果的发动后，直到回合结束时自己不能把卡盖放。
-- ③：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
function c64603182.initial_effect(c)
	-- 使这张卡在怪兽区域和墓地存在时，卡名当作「古代的机械巨人」使用。
	aux.EnableChangeCode(c,83104731,LOCATION_MZONE+LOCATION_GRAVE)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。除「古代的机械暗黑巨人」外的「古代的机械」卡或「齿车街」合计最多2张从卡组加入手卡。那之后，选自己1张手卡丢弃。这个效果的发动后，直到回合结束时自己不能把卡盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64603182,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,64603182)
	e1:SetTarget(c64603182.thtg)
	e1:SetOperation(c64603182.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ③：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(c64603182.aclimit)
	e3:SetCondition(c64603182.actcon)
	c:RegisterEffect(e3)
end
-- 过滤卡组中除「古代的机械暗黑巨人」以外的「古代的机械」卡片或「齿车街」且可以加入手牌的过滤函数。
function c64603182.thfilter(c)
	return not c:IsCode(64603182) and (c:IsSetCard(0x7) or c:IsCode(37694547)) and c:IsAbleToHand()
end
-- 检索效果的发动准备与合法性检测函数（Target）。
function c64603182.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足检索条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c64603182.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示该效果包含从卡组将卡加入手牌的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索并丢弃手牌以及限制后续盖放卡片的效果处理函数（Operation）。
function c64603182.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1到2张满足条件的卡。
	local g=Duel.SelectMatchingCard(tp,c64603182.thfilter,tp,LOCATION_DECK,0,1,2,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片因效果加入玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
		-- 洗切玩家的手牌。
		Duel.ShuffleHand(tp)
		-- 中断当前效果处理，使后续的丢弃手牌处理不与加入手牌同时进行（造成错时点）。
		Duel.BreakEffect()
		-- 让玩家选择并因效果丢弃1张手牌。
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
	-- 这个效果的发动后，直到回合结束时自己不能把卡盖放。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_MSET)
	e1:SetTargetRange(1,0)
	-- 设置限制效果的目标过滤函数为始终成立（即影响所有符合条件的卡片）。
	e1:SetTarget(aux.TRUE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册“不能盖放怪兽（里侧表示通常召唤）”的效果。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SSET)
	-- 给玩家注册“不能盖放魔法·陷阱卡”的效果。
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_TURN_SET)
	-- 给玩家注册“不能将场上的卡转为里侧表示”的效果。
	Duel.RegisterEffect(e3,tp)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e4:SetTarget(c64603182.sumlimit)
	-- 给玩家注册“不能以里侧表示特殊召唤怪兽”的效果。
	Duel.RegisterEffect(e4,tp)
end
-- 限制特殊召唤表示形式的过滤函数，判定特殊召唤的表示形式是否为里侧表示。
function c64603182.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return bit.band(sumpos,POS_FACEDOWN)>0
end
-- 限制发动的过滤函数，判定是否为魔法·陷阱卡的发动。
function c64603182.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 限制发动效果的条件函数，判定当前进行攻击的怪兽是否为这张卡自身。
function c64603182.actcon(e)
	-- 检查当前攻击的怪兽是否是此卡自身。
	return Duel.GetAttacker()==e:GetHandler()
end
