--古代の機械飛竜
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「古代的机械飞龙」以外的1张「古代的机械」卡加入手卡。这个效果的发动后，直到回合结束时自己不能把卡盖放。
-- ②：这张卡攻击的场合，对方直到伤害步骤结束时怪兽的效果不能发动。
function c17663375.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17663375,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,17663375)
	e1:SetTarget(c17663375.thtg)
	e1:SetOperation(c17663375.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡攻击的场合，对方直到伤害步骤结束时怪兽的效果不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(c17663375.aclimit)
	e3:SetCondition(c17663375.actcon)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于检索满足条件的「古代的机械」卡（不包括古代的机械飞龙）
function c17663375.thfilter(c)
	return c:IsSetCard(0x7) and not c:IsCode(17663375) and c:IsAbleToHand()
end
-- 效果处理时的判断条件，检查是否满足检索条件
function c17663375.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(c17663375.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时的操作信息，用于提示检索卡组
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行检索并加入手牌，同时设置后续不能盖卡的效果
function c17663375.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡加入手牌
	local g=Duel.SelectMatchingCard(tp,c17663375.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
	-- 设置后续不能盖卡的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_MSET)
	e1:SetTargetRange(1,0)
	-- 设置效果目标为所有卡
	e1:SetTarget(aux.TRUE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能覆盖怪兽的效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SSET)
	-- 注册不能覆盖魔法陷阱的效果
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_TURN_SET)
	-- 注册不能变里侧的效果
	Duel.RegisterEffect(e3,tp)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e4:SetTarget(c17663375.sumlimit)
	-- 注册不能特殊召唤到特定位置的效果
	Duel.RegisterEffect(e4,tp)
end
-- 限制特殊召唤只能召唤到里侧位置
function c17663375.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return bit.band(sumpos,POS_FACEDOWN)>0
end
-- 限制对方不能发动怪兽效果
function c17663375.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 判断是否为攻击状态
function c17663375.actcon(e)
	-- 判断是否为攻击状态
	return Duel.GetAttacker()==e:GetHandler()
end
