--羅刹
-- 效果：
-- 这张卡不能特殊召唤。召唤·反转的回合的结束阶段时回到持有者手卡。这张卡召唤·反转时，把「罗刹」以外的手卡1只灵魂怪兽给对方观看才能发动。选择对方场上表侧攻击表示存在的1只怪兽回到持有者手卡。这个效果发动的回合，自己不能把怪兽特殊召唤。
function c43378076.initial_effect(c)
	-- 为罗刹添加灵魂怪兽共通效果：在召唤成功或反转的回合结束阶段，这张卡回到持有者手卡。
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件判定值设为永远为false，从而禁止这张卡以任何方式特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 这张卡召唤·反转时，把「罗刹」以外的手卡1只灵魂怪兽给对方观看才能发动。选择对方场上表侧攻击表示存在的1只怪兽回到持有者手卡。这个效果发动的回合，自己不能把怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(43378076,0))  --"返回手卡"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetCost(c43378076.sretcost)
	e4:SetTarget(c43378076.srettg)
	e4:SetOperation(c43378076.sretop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_FLIP)
	c:RegisterEffect(e5)
end
-- 定义筛选函数：从手卡中选出「罗刹」以外的灵魂怪兽，且该卡没有公开给对方确认。
function c43378076.cfilter(c)
	return c:IsType(TYPE_SPIRIT) and not c:IsCode(43378076) and not c:IsPublic()
end
-- 发动代价判定：本回合该玩家尚未进行过特殊召唤，且手卡中存在1张符合条件的「罗刹」以外的灵魂怪兽。
function c43378076.sretcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动者本回合的特殊召唤次数是否为0，以符合‘这个效果发动的回合，自己不能把怪兽特殊召唤’的自肃条件。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0
		-- 同时检查手卡中是否存在至少1张满足cfilter条件的「罗刹」以外的灵魂怪兽。
		and Duel.IsExistingMatchingCard(c43378076.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 弹出提示，要求玩家选择一张手卡给对方确认。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 玩家从手卡选择1张符合条件的灵魂怪兽（用于给对方确认）。
	local g=Duel.SelectMatchingCard(tp,c43378076.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的手卡给对方玩家确认（展示）。
	Duel.ConfirmCards(1-tp,g)
	-- 确认后洗切该玩家手卡，防止手牌顺序信息泄露。
	Duel.ShuffleHand(tp)
	-- 选择对方场上表侧攻击表示存在的1只怪兽回到持有者手卡。这个效果发动的回合，自己不能把怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 将‘不能特殊召唤怪兽’的效果注册到发动者tp，持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 定义对象筛选函数：选择对方场上表侧攻击表示且能够加入手卡的怪兽。
function c43378076.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsAbleToHand()
end
-- 取对象效果的目标处理：选择对方场上1只表侧攻击表示且可回手的怪兽作为对象，并设置回手卡的操作信息。
function c43378076.srettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c43378076.filter(chkc) end
	-- 发动时检测对方场上是否存在满足条件（表侧攻击表示且可回手）的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c43378076.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 弹出提示，要求玩家选择要返回手牌的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 玩家选择对方场上1只符合条件的怪兽，并将其设置为效果对象。
	local g=Duel.SelectTarget(tp,c43378076.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 将本次操作信息登记为：把1张对象卡回到手卡（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：如果对象卡仍与效果关联，则将其返回持有者手卡。
function c43378076.sretop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁处理时所选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡返回持有者手卡，返回原因为效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
