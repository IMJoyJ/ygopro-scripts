--輝光竜フォトン・ブラスト・ドラゴン
-- 效果：
-- 4星怪兽×2
-- ①：这张卡超量召唤的场合才能发动。从手卡把1只「光子」怪兽特殊召唤。
-- ②：只要超量召唤的这张卡在怪兽区域存在，自己场上的攻击力2000以上的怪兽不会被对方的效果破坏，对方不能把那些作为效果的对象。
-- ③：对方回合1次，把这张卡1个超量素材取除，以自己的墓地·除外状态的1只「银河眼光子龙」为对象才能发动。那只怪兽特殊召唤。
function c16643334.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为4、数量为2的怪兽进行叠放
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤的场合才能发动。从手卡把1只「光子」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16643334,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c16643334.spcon1)
	e1:SetTarget(c16643334.sptg1)
	e1:SetOperation(c16643334.spop1)
	c:RegisterEffect(e1)
	-- ②：只要超量召唤的这张卡在怪兽区域存在，自己场上的攻击力2000以上的怪兽不会被对方的效果破坏，对方不能把那些作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c16643334.indcon)
	-- 设置效果目标为攻击力2000以上的怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsAttackAbove,2000))
	-- 设置效果值为不会被对方的效果破坏
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- ②：只要超量召唤的这张卡在怪兽区域存在，自己场上的攻击力2000以上的怪兽不会被对方的效果破坏，对方不能把那些作为效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(c16643334.indcon)
	-- 设置效果目标为攻击力2000以上的怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsAttackAbove,2000))
	-- 设置效果值为不能成为对方的效果对象
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ③：对方回合1次，把这张卡1个超量素材取除，以自己的墓地·除外状态的1只「银河眼光子龙」为对象才能发动。那只怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(16643334,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMING_BATTLE_START+TIMING_END_PHASE)
	e4:SetCondition(c16643334.spcon2)
	e4:SetCost(c16643334.spcost2)
	e4:SetTarget(c16643334.sptg2)
	e4:SetOperation(c16643334.spop2)
	c:RegisterEffect(e4)
end
-- 效果条件：此卡为XYZ召唤成功
function c16643334.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 过滤函数：满足「光子」卡族且可特殊召唤
function c16643334.spfilter1(c,e,tp)
	return c:IsSetCard(0x55) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标函数：检查手卡是否存在满足条件的「光子」怪兽
function c16643334.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡是否存在满足条件的「光子」怪兽
		and Duel.IsExistingMatchingCard(c16643334.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息为特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数：选择并特殊召唤手卡中的「光子」怪兽
function c16643334.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「光子」怪兽
	local g=Duel.SelectMatchingCard(tp,c16643334.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果条件：此卡为XYZ召唤成功
function c16643334.indcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 效果条件：当前为对方回合
function c16643334.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方
	return Duel.GetTurnPlayer()~=tp
end
-- 效果费用函数：移除1个超量素材作为费用
function c16643334.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数：满足「银河眼光子龙」卡号且可特殊召唤
function c16643334.spfilter2(c,e,tp)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsCode(93717133) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标函数：检查墓地或除外状态是否存在满足条件的「银河眼光子龙」
function c16643334.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c16643334.spfilter2(chkc,e,tp) end
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地或除外状态是否存在满足条件的「银河眼光子龙」
		and Duel.IsExistingTarget(c16643334.spfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「银河眼光子龙」
	local g=Duel.SelectTarget(tp,c16643334.spfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置连锁操作信息为特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数：将选择的「银河眼光子龙」特殊召唤
function c16643334.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将选择的怪兽特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
