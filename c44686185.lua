--影六武衆－ハツメ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：从自己墓地以及自己场上的表侧表示怪兽之中把2只「六武众」怪兽除外，以「影六武众-初芽」以外的自己墓地1只「六武众」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：只让自己场上的「六武众」怪兽1只被效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c44686185.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：从自己墓地以及自己场上的表侧表示怪兽之中把2只「六武众」怪兽除外，以「影六武众-初芽」以外的自己墓地1只「六武众」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44686185,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,44686185)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c44686185.cost)
	e1:SetTarget(c44686185.target)
	e1:SetOperation(c44686185.operation)
	c:RegisterEffect(e1)
	-- ②：只让自己场上的「六武众」怪兽1只被效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(c44686185.reptg)
	e2:SetValue(c44686185.repval)
	e2:SetOperation(c44686185.repop)
	c:RegisterEffect(e2)
end
-- 判断怪兽是否位于主要怪兽区（序号0-4），用于统计作为代价除外后能腾出的主怪兽区空格数量。
function c44686185.filter0(c)
	return c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5
end
-- 筛选可作为①效果代价除外的「六武众」怪兽：必须持有「六武众」字段、是怪兽、满足除外代价条件，且位于自己墓地或是自己场上表侧表示。
function c44686185.filter1(c)
	return c:IsSetCard(0x103d) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
-- 作为第一张代价候选的判定：自身是合法除外对象，且场上/墓地还存在另一张卡能与它组成2张代价，同时满足后续特殊召唤所需格子和对象条件。
function c44686185.filter3(c,e,tp)
	return c44686185.filter1(c)
		-- 判定除当前候选卡外，场上/墓地是否存在至少一张满足filter4的卡作为第二张代价候选，以确保能凑齐2张除外代价。
		and Duel.IsExistingMatchingCard(c44686185.filter4,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,1,c,e,tp,c)
end
-- 筛选第二张代价候选的判定：两张候选卡均可作为代价除外；被除外的卡中位于主怪兽区的数量加上当前可用空格数，能保证特殊召唤时有空位；并且墓地存在不包含在候选组中的「影六武众-初芽」以外「六武众」怪兽作为特殊召唤对象。
function c44686185.filter4(c,e,tp,rc)
	-- 获取自己场上主怪兽区当前可用的空格数，用于判断除外场上怪兽后是否能有足够的空位特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=Group.FromCards(c,rc)
	local ct=g:FilterCount(c44686185.filter0,nil)
	return c44686185.filter1(c) and ft+ct>0
		-- 确认在排除作为代价的候选组g后，墓地仍有至少1只满足filter2的「六武众」怪兽可以作为特殊召唤对象。
		and Duel.IsExistingTarget(c44686185.filter2,tp,LOCATION_GRAVE,0,1,g,e,tp)
end
-- ①效果的代价处理：从自己墓地以及自己场上表侧表示怪兽中，选择2只「六武众」怪兽以表侧表示除外；选择过程保证两张卡能作为代价、除外后有空闲主怪兽区、且墓地存在合法特召对象。
function c44686185.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：确认自己的墓地+场上表侧表示怪兽中，是否存在至少一张可作为第一张代价的候选卡，并能找到另一张组合成2张代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c44686185.filter3,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,1,nil,e,tp) end
	-- 发送选择提示，提示玩家选择第1只要除外的卡（用于支付代价）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从自己墓地和场上表侧表示怪兽中选择第1只满足filter3的「六武众」怪兽作为代价。
	local g1=Duel.SelectMatchingCard(tp,c44686185.filter3,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,1,1,nil,e,tp)
	-- 发送选择提示，提示玩家选择第2只要除外的卡（用于支付代价）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择第2只「六武众」怪兽作为代价，该卡必须与第1张卡组成合法组合（满足filter4），并排除已选的第1张卡。
	local g2=Duel.SelectMatchingCard(tp,c44686185.filter4,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,1,1,g1:GetFirst(),e,tp,g1:GetFirst())
	g1:Merge(g2)
	-- 将选出的2只「六武众」怪兽以表侧表示除外，作为①效果的发动代价（REASON_COST）。
	Duel.Remove(g1,POS_FACEUP,REASON_COST)
end
-- 筛选特殊召唤对象：墓地中持有「六武众」字段、卡名不是「影六武众-初芽」、且可以被当前效果正常特殊召唤的怪兽。
function c44686185.filter2(c,e,tp)
	return c:IsSetCard(0x103d) and not c:IsCode(44686185) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标选择与操作信息：从自己墓地选择1只「影六武众-初芽」以外的「六武众」怪兽作为效果对象，并设置连锁操作信息为特殊召唤。
function c44686185.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c44686185.filter2(chkc,e,tp) end
	if chk==0 then return true end
	-- 发送选择提示，提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足filter2的「六武众」怪兽作为效果对象并登记为当前连锁的目标。
	local g=Duel.SelectTarget(tp,c44686185.filter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息：本次效果将特殊召唤对象怪兽1只（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：取得发动时选择的目标怪兽，若其仍与效果关联，则将其表侧表示特殊召唤到自己场上。
function c44686185.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁对象中取得第1个目标怪兽（即发动时选择的墓地「六武众」怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧攻击表示特殊召唤到其控制者tp的场上，正常检查召唤条件与苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断某只怪兽是否符合②效果的代替破坏条件：表侧表示、持有「六武众」字段、位于自己主怪兽区、控制者为效果操控者、被效果破坏且不是由代替破坏造成。
function c44686185.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x103d)
		and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏的触发判定：墓地中的此卡可以被除外，且本次将被效果破坏的怪兽组eg中恰好有1只满足repfilter条件的己方表侧「六武众」怪兽。
function c44686185.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c44686185.repfilter,1,nil,tp)
		and eg:GetCount()==1 end
	-- 条件满足时，询问玩家是否选择用墓地的这张卡代替破坏；返回玩家的是否选择。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 作为EFFECT_DESTROY_REPLACE的Value函数，对将被破坏的卡c调用repfilter判断其是否满足代替破坏的对象条件。
function c44686185.repval(e,c)
	return c44686185.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏的最终处理：当玩家选择代替后，将墓地的此卡除外，以代替那只「六武众」怪兽被破坏。
function c44686185.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将效果持有者（墓地中的这张卡）以表侧表示除外，除外原因为效果（REASON_EFFECT），用于执行代替破坏。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
