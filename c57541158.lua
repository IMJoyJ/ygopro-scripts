--海晶乙女スリーピーメイデン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1张「海晶少女」卡为对象才能发动。这张卡从手卡特殊召唤，这张卡得到以下效果。
-- ●只要这张卡在怪兽区域存在，作为对象的卡不会被对方的效果破坏。
-- ②：把墓地的这张卡除外，以自己场上1只「海晶少女」连接怪兽为对象才能发动。从自己墓地选1只「海晶少女」连接怪兽当作装备卡使用给作为对象的怪兽装备。
function c57541158.initial_effect(c)
	-- ①：以自己场上1张「海晶少女」卡为对象才能发动。这张卡从手卡特殊召唤，这张卡得到以下效果。●只要这张卡在怪兽区域存在，作为对象的卡不会被对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57541158,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,57541158)
	e1:SetTarget(c57541158.sptg)
	e1:SetOperation(c57541158.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只「海晶少女」连接怪兽为对象才能发动。从自己墓地选1只「海晶少女」连接怪兽当作装备卡使用给作为对象的怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(57541158,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,57541159)
	-- 将墓地的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c57541158.eqtg)
	e2:SetOperation(c57541158.eqop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「海晶少女」卡
function c57541158.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x12b)
end
-- 效果①的准备与对象选择：检查特殊召唤条件并选择自己场上1张「海晶少女」卡作为对象
function c57541158.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c57541158.filter(chkc) end
	-- 检查自己场上是否存在可以作为对象的表侧表示「海晶少女」卡
	if chk==0 then return Duel.IsExistingTarget(c57541158.filter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查自己场上是否有可用的怪兽区域空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1张表侧表示的「海晶少女」卡作为效果的对象
	Duel.SelectTarget(tp,c57541158.filter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置特殊召唤的操作信息（特殊召唤自身）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的处理：将自身特殊召唤，并赋予其“作为对象的卡不会被对方的效果破坏”的效果
function c57541158.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取发动时选择的对象卡片
	local tc=Duel.GetFirstTarget()
	-- 若自身特殊召唤成功，且作为对象的卡仍存在并受效果影响
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and c:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		c:SetCardTarget(tc)
		-- ●只要这张卡在怪兽区域存在，作为对象的卡不会被对方的效果破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_TARGET)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetRange(LOCATION_MZONE)
		-- 设置不会被对方的效果破坏
		e1:SetValue(aux.indoval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 过滤条件：自己场上表侧表示的「海晶少女」连接怪兽
function c57541158.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12b) and c:IsType(TYPE_LINK)
end
-- 过滤条件：墓地中可以作为装备卡使用的「海晶少女」连接怪兽
function c57541158.eqfilter(c)
	return c:IsSetCard(0x12b) and c:IsType(TYPE_LINK) and not c:IsForbidden()
end
-- 效果②的准备与对象选择：检查魔陷区空位、场上的连接怪兽以及墓地的装备卡，并选择装备对象
function c57541158.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c57541158.tgfilter(chkc) end
	-- 检查自己场上是否有可用的魔法与陷阱区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在可以作为对象的表侧表示「海晶少女」连接怪兽
		and Duel.IsExistingTarget(c57541158.tgfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己墓地是否存在可以作为装备卡的「海晶少女」连接怪兽
		and Duel.IsExistingMatchingCard(c57541158.eqfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示的「海晶少女」连接怪兽作为效果的对象
	Duel.SelectTarget(tp,c57541158.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的处理：从墓地选择1只「海晶少女」连接怪兽，作为装备卡装备给作为对象的怪兽
function c57541158.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的作为装备对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查作为对象的怪兽是否仍在场上表侧表示存在，且魔陷区有空位
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 提示玩家选择要装备的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 从自己墓地选择1只不受「王家之谷」影响的「海晶少女」连接怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c57541158.eqfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		local ec=g:GetFirst()
		if ec then
			-- 将选择的墓地怪兽作为装备卡装备给目标怪兽，若装备失败则结束处理
			if not Duel.Equip(tp,ec,tc) then return end
			-- 从自己墓地选1只「海晶少女」连接怪兽当作装备卡使用给作为对象的怪兽装备。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetLabelObject(tc)
			e1:SetValue(c57541158.eqlimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			ec:RegisterEffect(e1)
		end
	end
end
-- 装备限制：只能装备给作为对象的怪兽
function c57541158.eqlimit(e,c)
	return c==e:GetLabelObject()
end
