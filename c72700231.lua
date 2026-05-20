--氷の魔妖－雪娘
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在，自己场上有「冰之魔妖-雪娘」以外的「魔妖」卡存在的场合才能发动。这张卡特殊召唤。那之后，从卡组把1只不死族怪兽送去墓地。
-- ②：只要这张卡在怪兽区域存在，自己不是「魔妖」怪兽不能从额外卡组特殊召唤。
function c72700231.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡在手卡·墓地存在，自己场上有「冰之魔妖-雪娘」以外的「魔妖」卡存在的场合才能发动。这张卡特殊召唤。那之后，从卡组把1只不死族怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72700231,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,72700231)
	e1:SetCondition(c72700231.condition)
	e1:SetTarget(c72700231.target)
	e1:SetOperation(c72700231.operation)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己不是「魔妖」怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c72700231.sslimit)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的「冰之魔妖-雪娘」以外的「魔妖」卡
function c72700231.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x121) and not c:IsCode(72700231)
end
-- 效果①的发动条件函数
function c72700231.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在「冰之魔妖-雪娘」以外的「魔妖」卡
	return Duel.IsExistingMatchingCard(c72700231.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤条件：卡组中可以送去墓地的不死族怪兽
function c72700231.tgfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToGrave()
end
-- 效果①的发动准备与合法性检测
function c72700231.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查卡组中是否存在可以送去墓地的不死族怪兽
		and Duel.IsExistingMatchingCard(c72700231.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置特殊召唤的操作信息（将自身特殊召唤）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置送去墓地的操作信息（从卡组将1张卡送去墓地）
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理（特殊召唤并送墓）
function c72700231.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身特殊召唤，若特殊召唤成功则继续处理
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从卡组选择1只满足条件的不死族怪兽
		local g=Duel.SelectMatchingCard(tp,c72700231.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 中断当前效果，使后续的送墓处理与特殊召唤不视为同时处理
			Duel.BreakEffect()
			-- 将选中的怪兽送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
-- 限制自己不能从额外卡组特殊召唤「魔妖」以外的怪兽
function c72700231.sslimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x121)
end
