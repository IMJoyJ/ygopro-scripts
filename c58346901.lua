--焔聖騎士－オリヴィエ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡以及自己场上的表侧表示的卡之中把1只战士族·炎属性怪兽或者1张装备魔法卡送去墓地才能发动。这张卡从手卡作为1星怪兽特殊召唤。
-- ②：这张卡在墓地存在的场合，以自己场上1只战士族怪兽为对象才能发动。这张卡当作装备卡使用给那只自己怪兽装备。
-- ③：这张卡的装备怪兽不会成为对方的效果的对象。
function c58346901.initial_effect(c)
	-- ①：从手卡以及自己场上的表侧表示的卡之中把1只战士族·炎属性怪兽或者1张装备魔法卡送去墓地才能发动。这张卡从手卡作为1星怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,58346901)
	e1:SetCost(c58346901.cost)
	e1:SetTarget(c58346901.target)
	e1:SetOperation(c58346901.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以自己场上1只战士族怪兽为对象才能发动。这张卡当作装备卡使用给那只自己怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,58346902)
	e2:SetTarget(c58346901.eqtg)
	e2:SetOperation(c58346901.eqop)
	c:RegisterEffect(e2)
	-- ③：这张卡的装备怪兽不会成为对方的效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置不会成为对方效果的对象的效果值
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
end
-- 过滤手卡或场上表侧表示的战士族·炎属性怪兽或装备魔法卡
function c58346901.cfilter(c,tp)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
		and (c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE)
			or (c:GetType()&(TYPE_EQUIP+TYPE_SPELL))==TYPE_EQUIP+TYPE_SPELL)
		-- 过滤条件：可以作为代价送去墓地，且该卡离开场上后有可用的怪兽区域
		and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- ①号效果的代价：从手卡或场上表侧表示的卡中将1张满足条件的卡送去墓地
function c58346901.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或场上是否存在可作为代价送去墓地的战士族·炎属性怪兽或装备魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c58346901.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler(),tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择1张手卡或场上表侧表示的战士族·炎属性怪兽或装备魔法卡
	local g=Duel.SelectMatchingCard(tp,c58346901.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler(),tp)
	-- 将选择的卡作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- ①号效果的启动与特殊召唤检测
function c58346901.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①号效果的处理：将自身特殊召唤，并将其等级变为1星
function c58346901.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 尝试将自身特殊召唤，若成功则执行后续处理
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 作为1星怪兽特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 过滤自己场上表侧表示的战士族怪兽
function c58346901.eqfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- ②号效果的启动与对象选择
function c58346901.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c58346901.eqfilter(chkc) end
	-- 检查自己场上的魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在可以作为装备对象的战士族怪兽
		and Duel.IsExistingTarget(c58346901.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示的战士族怪兽作为效果的对象
	Duel.SelectTarget(tp,c58346901.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置装备自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	-- 设置自身离开墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ②号效果的处理：将墓地的自身作为装备卡装备给目标怪兽，并添加装备限制
function c58346901.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) and tc:IsRelateToEffect(e) then
		-- 将自身作为装备卡装备给目标怪兽，若装备失败则结束处理
		if not Duel.Equip(tp,c,tc) then return end
		-- 当作装备卡使用给那只自己怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetLabelObject(tc)
		e1:SetValue(c58346901.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 装备限制：只能装备给作为对象的那只怪兽
function c58346901.eqlimit(e,c)
	return c==e:GetLabelObject()
end
