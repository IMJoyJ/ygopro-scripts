--No.46 神影龍ドラッグルーオン
-- 效果：
-- 龙族8星怪兽×2
-- ①：1回合1次，自己场上没有其他怪兽存在的场合，可以把这张卡1个超量素材取除，从以下效果选择1个发动。
-- ●从手卡把1只龙族怪兽特殊召唤。
-- ●以对方场上1只龙族怪兽为对象才能发动。得到那只龙族怪兽的控制权。
-- ●直到对方回合结束时，对方场上的龙族怪兽不能把效果发动。
function c2978414.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，要求满足龙族种族条件的8星怪兽叠放2只以上
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),8,2)
	c:EnableReviveLimit()
	-- ●从手卡把1只龙族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2978414,0))  --"从手卡把1只龙族怪兽特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetCondition(c2978414.condition)
	e1:SetCost(c2978414.cost)
	e1:SetTarget(c2978414.sptg)
	e1:SetOperation(c2978414.spop)
	c:RegisterEffect(e1)
	-- ●以对方场上1只龙族怪兽为对象才能发动。得到那只龙族怪兽的控制权。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2978414,1))  --"选择对方场上1只龙族怪兽得到控制权"
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCondition(c2978414.condition)
	e2:SetCost(c2978414.cost)
	e2:SetTarget(c2978414.cttg)
	e2:SetOperation(c2978414.ctop)
	c:RegisterEffect(e2)
	-- ●直到对方回合结束时，对方场上的龙族怪兽不能把效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(2978414,2))  --"对方场上的龙族怪兽不能把效果发动"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e3:SetCondition(c2978414.condition)
	e3:SetCost(c2978414.cost)
	e3:SetOperation(c2978414.efop)
	c:RegisterEffect(e3)
end
-- 设置该卡的编号为46
aux.xyz_number[2978414]=46
-- 判断自己场上是否只有这张卡或没有其他怪兽
function c2978414.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否只有这张卡或没有其他怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<=1
end
-- 设置发动此效果的费用为去除1个超量素材
function c2978414.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	-- 向对方提示发动了此效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义特殊召唤的过滤条件，必须是龙族且可以特殊召唤
function c2978414.spfilter(c,e,tp)
	-- 定义特殊召唤的过滤条件，必须是龙族且可以特殊召唤
	return c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,aux.DragonXyzSpSummonType(c))
end
-- 设置特殊召唤效果的目标函数，检查是否有满足条件的龙族怪兽可特殊召唤
function c2978414.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有足够的召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在满足条件的龙族怪兽
		and Duel.IsExistingMatchingCard(c2978414.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 执行特殊召唤操作，选择手牌中的龙族怪兽进行特殊召唤
function c2978414.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有足够的召唤空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c2978414.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		local sc=g:GetFirst()
		-- 执行特殊召唤操作并完成召唤程序
		if Duel.SpecialSummon(g,0,tp,tp,false,aux.DragonXyzSpSummonType(sc),POS_FACEUP)~=0 and aux.DragonXyzSpSummonType(sc) then
			sc:CompleteProcedure()
		end
	end
end
-- 定义控制权变更的过滤条件，必须是正面表示的龙族怪兽且可以改变控制权
function c2978414.ctfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsControlerCanBeChanged()
end
-- 设置控制权变更效果的目标函数，检查对方场上是否存在满足条件的龙族怪兽
function c2978414.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c2978414.ctfilter(chkc) end
	-- 检查对方场上是否存在满足条件的龙族怪兽
	if chk==0 then return Duel.IsExistingTarget(c2978414.ctfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择满足条件的对方龙族怪兽
	local g=Duel.SelectTarget(tp,c2978414.ctfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置控制权变更效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 执行控制权变更操作，获得目标怪兽的控制权
function c2978414.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_DRAGON) then
		-- 获得目标怪兽的控制权
		Duel.GetControl(tc,tp)
	end
end
-- 设置效果发动后对方场上的龙族怪兽不能发动效果
function c2978414.efop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置效果发动后对方场上的龙族怪兽不能发动效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TRIGGER)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(c2978414.actfilter)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
	-- 将效果注册到全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 定义效果发动的过滤条件，仅对龙族怪兽生效
function c2978414.actfilter(e,c)
	return c:IsRace(RACE_DRAGON)
end
