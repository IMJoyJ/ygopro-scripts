--ギミック・パペット－ギガンテス・ドール
-- 效果：
-- 4星「机关傀儡」怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡2个超量素材取除，以对方场上最多2只怪兽为对象才能发动。那些怪兽的控制权直到结束阶段得到。这个效果的发动后，直到回合结束时自己不是「机关傀儡」怪兽不能特殊召唤，不用超量怪兽不能攻击宣言。
-- ②：把这张卡解放才能发动。自己场上的全部怪兽的等级直到回合结束时变成8星。
function c7593748.initial_effect(c)
	-- 设定该卡为4星「机关傀儡」怪兽2只叠放的超量召唤手续
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x1083),4,2)
	c:EnableReviveLimit()
	-- ①：把这张卡2个超量素材取除，以对方场上最多2只怪兽为对象才能发动。那些怪兽的控制权直到结束阶段得到。这个效果的发动后，直到回合结束时自己不是「机关傀儡」怪兽不能特殊召唤，不用超量怪兽不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetDescription(aux.Stringid(7593748,0))  --"获得控制权"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,7593748)
	e1:SetCost(c7593748.cost)
	e1:SetTarget(c7593748.target)
	e1:SetOperation(c7593748.operation)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放才能发动。自己场上的全部怪兽的等级直到回合结束时变成8星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(7593748,1))  --"改变等级"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,7593749)
	e2:SetCost(c7593748.lvcost)
	e2:SetTarget(c7593748.lvtg)
	e2:SetOperation(c7593748.lvop)
	c:RegisterEffect(e2)
end
-- 效果①的代价：取除这张卡的2个超量素材
function c7593748.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 过滤可以改变控制权的怪兽
function c7593748.filter(c)
	return c:IsControlerCanBeChanged()
end
-- 效果①的靶向选择（对象选择）：检查对方场上是否存在可改变控制权的怪兽，并选择最多2只作为对象
function c7593748.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c7593748.filter(chkc) end
	-- 获取自己场上因控制权转移可使用的怪兽区域空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE,1-tp,LOCATION_REASON_CONTROL)
	-- 检查自己场上是否有空位且对方场上是否存在至少1只可改变控制权的对象怪兽
	if chk==0 then return ft>0 and Duel.IsExistingTarget(c7593748.filter,tp,0,LOCATION_MZONE,1,nil) end
	local ct=math.min(ft,2)
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择最多为空位数（且最多2只）的对方场上怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c7593748.filter,tp,0,LOCATION_MZONE,1,ct,nil)
	-- 设置连锁信息，表明该效果包含改变控制权的操作，涉及卡片为选中的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,#g,0,0)
end
-- 效果①的处理：获得对象怪兽的控制权，并适用不能特殊召唤「机关傀儡」以外的怪兽以及不用超量怪兽不能攻击宣言的限制
function c7593748.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选为对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 让玩家直到结束阶段为止得到这些对象怪兽的控制权
	Duel.GetControl(tg,tp,PHASE_END,1)
	-- 这个效果的发动后，直到回合结束时自己不是「机关傀儡」怪兽不能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c7593748.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤「机关傀儡」以外怪兽的玩家限制效果
	Duel.RegisterEffect(e1,tp)
	-- 不用超量怪兽不能攻击宣言。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c7593748.atktg)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不用超量怪兽不能攻击宣言的玩家限制效果
	Duel.RegisterEffect(e2,tp)
end
-- 限制不能特殊召唤非「机关傀儡」怪兽
function c7593748.splimit(e,c)
	return not c:IsSetCard(0x1083)
end
-- 限制非超量怪兽不能进行攻击宣言
function c7593748.atktg(e,c)
	return not c:IsType(TYPE_XYZ)
end
-- 效果②的代价：检查并解放这张卡
function c7593748.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤自己场上表侧表示、等级不为8且有等级的怪兽
function c7593748.lvfilter(c)
	return c:IsFaceup() and not c:IsLevel(8) and c:GetLevel()>0
end
-- 效果②的靶向选择（目标检查）：检查自己场上是否存在可以改变等级的怪兽
function c7593748.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上（除自身外）是否存在至少1只可以改变等级的表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c7593748.lvfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
end
-- 效果②的处理：将自己场上全部怪兽的等级直到回合结束时变成8星
function c7593748.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有满足等级改变条件的怪兽
	local g=Duel.GetMatchingGroup(c7593748.lvfilter,tp,LOCATION_MZONE,0,nil)
	local lc=g:GetFirst()
	while lc do
		-- 自己场上的全部怪兽的等级直到回合结束时变成8星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(8)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		lc:RegisterEffect(e1)
		lc=g:GetNext()
	end
end
