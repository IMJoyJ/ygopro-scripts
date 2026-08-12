--魔界劇団－ダンディ・バイプレイヤー
-- 效果：
-- ←8 【灵摆】 8→
-- ①：自己灵摆召唤成功时才能发动。从自己的额外卡组把1只表侧表示的1星或者8星的「魔界剧团」灵摆怪兽加入手卡。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：自己的灵摆区域有2张「魔界剧团」卡存在的场合，把这张卡解放才能发动。从手卡以及自己的额外卡组的表侧表示怪兽之中把1只1星或者8星的「魔界剧团」灵摆怪兽特殊召唤。
function c39024589.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：自己灵摆召唤成功时才能发动。从自己的额外卡组把1只表侧表示的1星或者8星的「魔界剧团」灵摆怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39024589,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(c39024589.thcon)
	e1:SetTarget(c39024589.thtg)
	e1:SetOperation(c39024589.thop)
	c:RegisterEffect(e1)
	-- ①：自己的灵摆区域有2张「魔界剧团」卡存在的场合，把这张卡解放才能发动。从手卡以及自己的额外卡组的表侧表示怪兽之中把1只1星或者8星的「魔界剧团」灵摆怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39024589,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,39024589)
	e2:SetCondition(c39024589.spcon)
	e2:SetCost(c39024589.spcost)
	e2:SetTarget(c39024589.sptg)
	e2:SetOperation(c39024589.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断怪兽是否为灵摆召唤
function c39024589.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 判断是否有灵摆召唤成功的怪兽
function c39024589.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c39024589.cfilter,1,nil,tp)
end
-- 过滤函数，用于筛选满足条件的灵摆怪兽
function c39024589.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10ec) and c:IsLevel(1,8) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 设置连锁操作信息，确定效果处理时要加入手牌的卡
function c39024589.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足条件，即自己额外卡组是否存在满足条件的灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c39024589.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁操作信息，确定效果处理时要加入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理函数，选择并把符合条件的灵摆怪兽加入手牌
function c39024589.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c39024589.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的灵摆怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断灵摆区域是否有2张「魔界剧团」卡
function c39024589.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查灵摆区域是否有2张「魔界剧团」卡
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,2,nil,0x10ec)
end
-- 设置效果发动的代价，即解放自身
function c39024589.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身解放作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤函数，用于筛选可以特殊召唤的灵摆怪兽
function c39024589.filter(c,e,tp,mc)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsSetCard(0x10ec)
		and c:IsLevel(1,8) and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断手牌中的灵摆怪兽是否可以特殊召唤
		and (c:IsLocation(LOCATION_HAND) and Duel.GetMZoneCount(tp,mc)>0
			-- 判断额外卡组中的灵摆怪兽是否可以特殊召唤
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0)
end
-- 设置连锁操作信息，确定效果处理时要特殊召唤的卡
function c39024589.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足条件，即手牌或额外卡组是否存在满足条件的灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c39024589.filter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	-- 设置连锁操作信息，确定效果处理时要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_EXTRA)
end
-- 效果处理函数，选择并把符合条件的灵摆怪兽特殊召唤
function c39024589.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c39024589.filter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	if g:GetCount()>0 then
		-- 将选中的灵摆怪兽特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
