--羅刹
-- 效果：
-- 这张卡不能特殊召唤。召唤·反转的回合的结束阶段时回到持有者手卡。这张卡召唤·反转时，把「罗刹」以外的手卡1只灵魂怪兽给对方观看才能发动。选择对方场上表侧攻击表示存在的1只怪兽回到持有者手卡。这个效果发动的回合，自己不能把怪兽特殊召唤。
function c43378076.initial_effect(c)
	-- 为卡片添加在召唤或反转召唤成功时回到手卡的效果
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡不能被特殊召唤
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 召唤·反转时，把「罗刹」以外的手卡1只灵魂怪兽给对方观看才能发动。选择对方场上表侧攻击表示存在的1只怪兽回到持有者手卡。这个效果发动的回合，自己不能把怪兽特殊召唤。
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
-- 过滤函数，用于筛选手卡中非罗刹的灵魂怪兽且未公开的卡片
function c43378076.cfilter(c)
	return c:IsType(TYPE_SPIRIT) and not c:IsCode(43378076) and not c:IsPublic()
end
-- 检查是否满足发动条件：本回合未进行过特殊召唤，并且手卡存在符合条件的灵魂怪兽
function c43378076.sretcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合是否未进行过特殊召唤
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0
		-- 检查手卡是否存在符合条件的灵魂怪兽
		and Duel.IsExistingMatchingCard(c43378076.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要给对方确认的灵魂怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择符合条件的1只灵魂怪兽
	local g=Duel.SelectMatchingCard(tp,c43378076.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方确认所选的灵魂怪兽
	Duel.ConfirmCards(1-tp,g)
	-- 将玩家手卡洗牌
	Duel.ShuffleHand(tp)
	-- 创建一个效果，使本回合玩家不能特殊召唤怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数，用于筛选对方场上表侧攻击表示且可以送回手卡的怪兽
function c43378076.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsAbleToHand()
end
-- 设置效果的目标选择逻辑：选择对方场上表侧攻击表示存在的怪兽
function c43378076.srettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c43378076.filter(chkc) end
	-- 检查对方场上是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c43378076.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要送回手卡的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c43378076.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，指定将怪兽送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行效果操作：将目标怪兽送回手卡
function c43378076.sretop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽送回手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
