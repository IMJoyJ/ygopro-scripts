--ワルキューレ・ドリット
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「女武神三女」以外的1张「女武神」卡加入手卡。
-- ②：这张卡的攻击力上升除外的对方怪兽数量×200。
function c3026686.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3026686,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,3026686)
	e1:SetTarget(c3026686.thtg)
	e1:SetOperation(c3026686.thop)
	c:RegisterEffect(e1)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：这张卡的攻击力上升除外的对方怪兽数量×200。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetValue(c3026686.atkvalue)
	c:RegisterEffect(e4)
end
-- 检索条件过滤函数，用于筛选「女武神」卡组中的卡
function c3026686.thfilter(c)
	return c:IsSetCard(0x122) and c:IsAbleToHand() and not c:IsCode(3026686)
end
-- 效果发动时的处理函数，用于设置效果发动时的处理信息
function c3026686.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，即卡组中是否存在符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c3026686.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息，表示将从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，用于执行检索并加入手牌的操作
function c3026686.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c3026686.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认自己选择的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 除外区怪兽过滤函数，用于筛选除外区的怪兽
function c3026686.rmfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
-- 计算攻击力上升值，为除外的对方怪兽数量×200
function c3026686.atkvalue(e,c)
	-- 返回除外的对方怪兽数量乘以200的结果
	return Duel.GetMatchingGroupCount(c3026686.rmfilter,c:GetControler(),0,LOCATION_REMOVED,nil)*200
end
