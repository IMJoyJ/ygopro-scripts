--氷結界の晶壁
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：这张卡的发动时，可以以自己墓地1只4星以下的「冰结界」怪兽为对象。那个场合，那只怪兽特殊召唤。
-- ②：只要这张卡在魔法与陷阱区域存在并在自己场上有「冰结界」怪兽3只以上存在，自己场上的「冰结界」怪兽不受从额外卡组特殊召唤的对方怪兽发动的效果影响。
function c43582229.initial_effect(c)
	-- ①：这张卡的发动时，可以以自己墓地1只4星以下的「冰结界」怪兽为对象。那个场合，那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,43582229+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c43582229.target)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在魔法与陷阱区域存在并在自己场上有「冰结界」怪兽3只以上存在，自己场上的「冰结界」怪兽不受从额外卡组特殊召唤的对方怪兽发动的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果目标为场上的「冰结界」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x2f))
	e2:SetCondition(c43582229.condition)
	e2:SetValue(c43582229.efilter)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断墓地中的怪兽是否满足4星以下、属于「冰结界」种族且可以特殊召唤的条件
function c43582229.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x2f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 处理发动时的选择与设置，若满足条件则设置特殊召唤的分类和操作
function c43582229.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c43582229.filter(chkc) end
	if chk==0 then return true end
	-- 判断玩家场上是否有足够的怪兽区域用于特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家墓地是否存在满足条件的「冰结界」怪兽
		and Duel.IsExistingTarget(c43582229.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 询问玩家是否选择将墓地中的怪兽特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(43582229,0)) then  --"是否把墓地怪兽特殊召唤？"
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(c43582229.activate)
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的墓地怪兽作为特殊召唤的目标
		local g=Duel.SelectTarget(tp,c43582229.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 设置本次连锁操作的信息，包括特殊召唤的卡和数量
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	else
		e:SetCategory(0)
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end
-- 执行特殊召唤操作，将目标怪兽特殊召唤到场上
function c43582229.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以正面表示的形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于判断场上正面表示的「冰结界」怪兽
function c43582229.imfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2f)
end
-- 判断自己场上有3只或以上「冰结界」怪兽存在
function c43582229.condition(e)
	-- 检查场上是否存在至少3只正面表示的「冰结界」怪兽
	return Duel.IsExistingMatchingCard(c43582229.imfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,3,nil)
end
-- 设置效果过滤函数，用于判断是否免疫从额外卡组特殊召唤的对方怪兽的效果
function c43582229.efilter(e,te)
	local tc=te:GetOwner()
	return te:IsActiveType(TYPE_MONSTER) and te:IsActivated()
		and te:GetOwnerPlayer()==1-e:GetHandlerPlayer()
		and te:GetActivateLocation()==LOCATION_MZONE and tc:IsSummonLocation(LOCATION_EXTRA)
end
