--星霜のペンデュラムグラフ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在魔法与陷阱区域存在，对方不能把自己场上的魔法师族怪兽作为魔法卡的效果的对象。
-- ②：自己的怪兽区域·灵摆区域的表侧表示的「魔术师」灵摆怪兽卡从场上离开的场合发动。从卡组把1只「魔术师」灵摆怪兽加入手卡。
function c74850403.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，对方不能把自己场上的魔法师族怪兽作为魔法卡的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果影响的对象为自己场上的魔法师族怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_SPELLCASTER))
	e2:SetValue(c74850403.evalue)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己的怪兽区域·灵摆区域的表侧表示的「魔术师」灵摆怪兽卡从场上离开的场合发动。从卡组把1只「魔术师」灵摆怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,74850403)
	e3:SetCondition(c74850403.thcon)
	e3:SetTarget(c74850403.thtg)
	e3:SetOperation(c74850403.thop)
	c:RegisterEffect(e3)
end
-- 判断效果是否为对方发动的魔法卡的效果
function c74850403.evalue(e,re,rp)
	return re:IsActiveType(TYPE_SPELL) and rp==1-e:GetHandlerPlayer()
end
-- 过滤离开场地的卡是否为自己场上（怪兽区域或灵摆区域）表侧表示的「魔术师」灵摆怪兽
function c74850403.thcfilter(c,tp)
	return c:IsType(TYPE_PENDULUM) and c:IsPreviousSetCard(0x98)
		and c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousLocation(LOCATION_MZONE+LOCATION_PZONE)
end
-- 检查离开场地的卡片中是否存在满足条件的「魔术师」灵摆怪兽
function c74850403.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c74850403.thcfilter,1,nil,tp)
end
-- 过滤卡组中可以加入手牌的「魔术师」灵摆怪兽
function c74850403.thfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x98) and c:IsAbleToHand()
end
-- 效果②的发动准备与效果分类、操作信息的注册
function c74850403.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理的操作信息为：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的实际处理：从卡组选择1只「魔术师」灵摆怪兽加入手牌并给对方确认
function c74850403.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足条件的「魔术师」灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c74850403.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
