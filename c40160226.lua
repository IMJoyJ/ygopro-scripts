--機海竜プレシオン
-- 效果：
-- 自己场上有海龙族怪兽存在的场合，这张卡可以不用解放作召唤。1回合1次，可以通过把自己场上1只水属性怪兽解放，选择对方场上表侧表示存在的1张卡破坏。
function c40160226.initial_effect(c)
	-- 自己场上有海龙族怪兽存在的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40160226,0))  --"不进行解放作召唤"
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c40160226.ntcon)
	c:RegisterEffect(e1)
	-- 1回合1次，可以通过把自己场上1只水属性怪兽解放，选择对方场上表侧表示存在的1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40160226,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c40160226.cost)
	e2:SetTarget(c40160226.target)
	e2:SetOperation(c40160226.operation)
	c:RegisterEffect(e2)
end
-- 判断卡是否为表侧表示且为海龙族，用于检查自己场上是否存在符合条件的海龙族怪兽。
function c40160226.ntfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SEASERPENT)
end
-- 无解放召唤规则的发动条件：若这张卡等级5以上、自己场上有表侧海龙族怪兽且主怪兽区有空位，则可以不解放作召唤。
function c40160226.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判定需要‘不用解放’（minc==0）、这张卡等级为5以上，且自己主怪兽区有空位。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1只表侧表示的海龙族怪兽，满足无解放召唤的条件。
		and Duel.IsExistingMatchingCard(c40160226.ntfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 该效果的代价：解放自己场上1只水属性怪兽以发动效果，先检查是否有可解放的水属性怪兽，再选择并解放。
function c40160226.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：自己场上是否存在至少1只水属性怪兽可作为解放代价（非上级召唤用）。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsAttribute,1,nil,ATTRIBUTE_WATER) end
	-- 选择自己场上1只水属性怪兽作为代价。
	local g=Duel.SelectReleaseGroup(tp,Card.IsAttribute,1,1,nil,ATTRIBUTE_WATER)
	-- 将选择的怪兽解放，作为发动效果的代价（REASON_COST）。
	Duel.Release(g,REASON_COST)
end
-- 目标筛选：对象必须为表侧表示的卡，用于选择对方场上的表侧表示卡。
function c40160226.filter(c)
	return c:IsFaceup()
end
-- 取对象的目标处理：确认对方场上有表侧表示卡可选，提示选择1张，并设定操作信息。
function c40160226.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c40160226.filter(chkc) end
	-- 确认对方场上是否存在1张表侧表示卡可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c40160226.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 显示选择提示“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张表侧表示的卡作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c40160226.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设定操作信息为破坏1张卡（CATEGORY_DESTROY），供发动后的时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：获取对象卡，确认其仍与效果相关且表侧表示，然后将其破坏。
function c40160226.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的1张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 以效果原因（REASON_EFFECT）破坏对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
