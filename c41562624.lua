--不知火の武部
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤成功时才能发动。从手卡·卡组把1只「妖刀-不知火」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。
-- ②：这张卡被除外的场合才能发动。自己从卡组抽1张。那之后，选1张手卡丢弃。
function c41562624.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从手卡·卡组把1只「妖刀-不知火」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是不死族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41562624,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,41562624)
	e1:SetTarget(c41562624.sumtg)
	e1:SetOperation(c41562624.sumop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合才能发动。自己从卡组抽1张。那之后，选1张手卡丢弃。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41562624,1))
	e2:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,41562625)
	e2:SetTarget(c41562624.drtg)
	e2:SetOperation(c41562624.drop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选满足条件的「妖刀-不知火」怪兽
function c41562624.filter(c,e,tp)
	return c:IsSetCard(0x10d9) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足①效果的发动条件
function c41562624.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有特殊召唤怪兽的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡或卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c41562624.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理时要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ①效果的处理函数，用于特殊召唤怪兽并设置不能特殊召唤不死族怪兽的效果
function c41562624.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有特殊召唤怪兽的空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的怪兽
		local g=Duel.SelectMatchingCard(tp,c41562624.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			-- 将选中的怪兽特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	local c=e:GetHandler()
	-- 设置不能特殊召唤不死族怪兽的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c41562624.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤不死族怪兽的效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能特殊召唤的怪兽类型为不死族
function c41562624.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_ZOMBIE)
end
-- ②效果的处理函数，用于抽卡并丢弃手牌
function c41562624.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果处理时要丢弃的手卡数量
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	-- 设置效果处理时要抽卡的数量
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果的处理函数，用于抽卡并丢弃手牌
function c41562624.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功抽卡
	if Duel.Draw(tp,1,REASON_EFFECT)>0 then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 洗切玩家的手牌
		Duel.ShuffleHand(tp)
		-- 丢弃1张手牌
		Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
