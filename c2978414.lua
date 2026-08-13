--No.46 神影龍ドラッグルーオン
-- 效果：
-- 龙族8星怪兽×2
-- ①：1回合1次，自己场上没有其他怪兽存在的场合，可以把这张卡1个超量素材取除，从以下效果选择1个发动。
-- ●从手卡把1只龙族怪兽特殊召唤。
-- ●以对方场上1只龙族怪兽为对象才能发动。得到那只龙族怪兽的控制权。
-- ●直到对方回合结束时，对方场上的龙族怪兽不能把效果发动。
function c2978414.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：以2只等级8的龙族怪兽作为超量素材进行XYZ召唤。
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
-- 将此卡登记为No.46，使其在No.相关规则/效果中视为编号46的怪兽。
aux.xyz_number[2978414]=46
-- 效果发动条件：自己场上没有其他怪兽存在时才能发动，统计自己场上怪兽区卡数不超过1。
function c2978414.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上怪兽区域存在的卡数量是否≤1，即除这张卡本身外没有其他怪兽。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<=1
end
-- 发动代价：取除这张卡的1个超量素材，并向对方玩家提示本卡选择发动的效果。
function c2978414.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	-- 向对方玩家提示本卡选择发动的是哪个效果，显示对应的效果描述。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 特殊召唤对象过滤：手牌中满足龙族且可以被特殊召唤的怪兽，同时兼容源数龙的特殊召唤规则判定。
function c2978414.spfilter(c,e,tp)
	-- 判断怪兽是否为龙族且能否被特殊召唤，若为源数龙则使用其特殊召唤规则进行判定。
	return c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,aux.DragonXyzSpSummonType(c))
end
-- 特殊召唤效果的发动条件检查：自己场上怪兽区有空位，且手牌中存在符合条件的龙族怪兽。
function c2978414.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并检查手牌是否存在至少1只可以被特殊召唤的龙族怪兽。
		and Duel.IsExistingMatchingCard(c2978414.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置本次效果处理的类别为特殊召唤，预定从手牌把1只怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：从手牌选择1只龙族怪兽特殊召唤；若该怪兽是源数龙，则补完其特殊召唤手续。
function c2978414.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认场上仍有可用怪兽区，否则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌选择1只符合条件的龙族怪兽。
	local g=Duel.SelectMatchingCard(tp,c2978414.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		local sc=g:GetFirst()
		-- 执行特殊召唤；若召唤成功且该怪兽为源数龙，则将其补完为正规特殊召唤（CompleteProcedure）。
		if Duel.SpecialSummon(g,0,tp,tp,false,aux.DragonXyzSpSummonType(sc),POS_FACEUP)~=0 and aux.DragonXyzSpSummonType(sc) then
			sc:CompleteProcedure()
		end
	end
end
-- 控制权取得对象的过滤条件：表侧表示、龙族、且控制权可以被改变。
function c2978414.ctfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsControlerCanBeChanged()
end
-- 取对象效果的目标选择：选择对方场上1只符合条件的龙族怪兽，并设置操作信息为改变控制权。
function c2978414.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c2978414.ctfilter(chkc) end
	-- 检查对方场上是否存在符合条件的龙族怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c2978414.ctfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 弹出“请选择要改变控制权的怪兽”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只龙族怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c2978414.ctfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置本次效果处理的类别为改变控制权，并指定对象。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理：获得对象龙族怪兽的控制权。
function c2978414.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得该效果的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_DRAGON) then
		-- 将对象怪兽的控制权转移给本卡的控制者。
		Duel.GetControl(tc,tp)
	end
end
-- 效果处理：生成一个持续到对方回合结束的领域效果，使对方场上的龙族怪兽不能发动效果。
function c2978414.efop(e,tp,eg,ep,ev,re,r,rp)
	-- ●直到对方回合结束时，对方场上的龙族怪兽不能把效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TRIGGER)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(c2978414.actfilter)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
	-- 将这个不能发动效果的封印效果注册到场上，由tp方发动，影响对方场上的龙族怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 封印效果的过滤条件：龙族怪兽。
function c2978414.actfilter(e,c)
	return c:IsRace(RACE_DRAGON)
end
