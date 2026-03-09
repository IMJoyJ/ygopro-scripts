--妖仙獣 凶旋嵐
-- 效果：
-- ①：这张卡召唤成功的场合才能发动。从卡组把「妖仙兽 凶旋岚」以外的1只「妖仙兽」怪兽特殊召唤。
-- ②：这张卡特殊召唤的回合的结束阶段发动。这张卡回到持有者手卡。
function c49249907.initial_effect(c)
	-- ①：这张卡召唤成功的场合才能发动。从卡组把「妖仙兽 凶旋岚」以外的1只「妖仙兽」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c49249907.sptg)
	e1:SetOperation(c49249907.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤的回合的结束阶段发动。这张卡回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCondition(c49249907.retcon)
	e2:SetTarget(c49249907.rettg)
	e2:SetOperation(c49249907.retop)
	c:RegisterEffect(e2)
	if not c49249907.global_check then
		c49249907.global_check=true
		-- 处理“这张卡召唤的回合”的效果
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetLabel(49249907)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		-- 注册用于记录特殊召唤的辅助效果
		ge1:SetOperation(aux.sumreg)
		-- 将辅助效果注册到全局环境
		Duel.RegisterEffect(ge1,0)
	end
end
-- 过滤函数，用于筛选满足条件的「妖仙兽」怪兽
function c49249907.filter(c,e,tp)
	return c:IsSetCard(0xb3) and not c:IsCode(49249907) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否可以发动效果，检查场上是否有空位和卡组中是否存在符合条件的怪兽
function c49249907.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c49249907.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤一张怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理效果的发动，选择并特殊召唤符合条件的怪兽
function c49249907.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c49249907.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断该卡是否在特殊召唤的回合
function c49249907.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(49249907)~=0
end
-- 设置操作信息，表示将要将该卡送回手牌
function c49249907.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将要将该卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 处理效果的发动，将该卡送回手牌
function c49249907.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将该卡送回持有者手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
