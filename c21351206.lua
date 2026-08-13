--焔聖騎士－オジエ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「焰圣骑士-奥吉尔」以外的1只战士族·炎属性怪兽或者1张「圣剑」卡送去墓地。
-- ②：这张卡在墓地存在的场合，以自己场上1只战士族怪兽为对象才能发动。这张卡当作装备卡使用给那只自己怪兽装备。
-- ③：这张卡的装备怪兽不会被效果破坏。
function c21351206.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「焰圣骑士-奥吉尔」以外的1只战士族·炎属性怪兽或者1张「圣剑」卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21351206,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,21351206)
	e1:SetTarget(c21351206.tgtg)
	e1:SetOperation(c21351206.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡在墓地存在的场合，以自己场上1只战士族怪兽为对象才能发动。这张卡当作装备卡使用给那只自己怪兽装备。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,21351207)
	e3:SetTarget(c21351206.eqtg)
	e3:SetOperation(c21351206.eqop)
	c:RegisterEffect(e3)
	-- ③：这张卡的装备怪兽不会被效果破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
-- ①的送墓对象筛选：卡不是「焰圣骑士-奥吉尔」，且为战士族·炎属性怪兽或「圣剑」卡，并能送去墓地。
function c21351206.tgfilter(c)
	return ((c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE)) or c:IsSetCard(0x207a)) and not c:IsCode(21351206)
		and c:IsAbleToGrave()
end
-- ①的发动条件与操作信息设定：在chk==0时检查卡组是否存在符合条件的卡；在chk==1时设置将1张卡从卡组送去墓地的操作信息。
function c21351206.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组中存在至少1张满足tgfilter的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c21351206.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：效果处理时将1张卡从卡组送去墓地（CATEGORY_TOGRAVE），供相关连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①的实际处理：从卡组选择1张符合条件的卡，以效果原因送去墓地。
function c21351206.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示选择提示，提示文本为『请选择要送去墓地的卡』。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1张满足tgfilter的卡。
	local g=Duel.SelectMatchingCard(tp,c21351206.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因送入墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- ②的装备对象过滤条件：场上表侧表示的战士族怪兽。
function c21351206.eqfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- ②的发动条件与对象合法性校验：若指定了对象（chkc），则要求其为己方场上的表侧战士族怪兽；在发动检查（chk==0）时确认魔陷区有空位且自己场上有满足条件的表侧战士族怪兽。
function c21351206.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c21351206.eqfilter(chkc) end
	-- 发动条件之一：自己魔陷区存在可放置装备卡的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 发动条件之二：自己场上存在至少1只符合条件的表侧战士族怪兽可作为装备对象。
		and Duel.IsExistingTarget(c21351206.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家显示选择提示，提示文本为『请选择要装备的卡』。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示战士族怪兽，并将其登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,c21351206.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：效果处理时将此卡自身进行装备（CATEGORY_EQUIP），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	-- 设置操作信息：这张卡将离开墓地（CATEGORY_LEAVE_GRAVE），用于王家长眠之谷等涉及墓地的连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ②的实际处理：若此卡仍与效果关联且对象合法，则将此卡装备给对象怪兽；装备成功后设置一个只能装备给该对象怪兽的装备限制效果，并在标准重置时机消失。
function c21351206.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) and tc:IsRelateToEffect(e) then
		-- 尝试将此卡作为装备卡装备给对象怪兽；若装备失败则直接结束处理。
		if not Duel.Equip(tp,c,tc) then return end
		-- 这张卡当作装备卡使用给那只自己怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetLabelObject(tc)
		e1:SetValue(c21351206.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 装备限制判断：只有当初选择的目标怪兽才能装备这张卡。
function c21351206.eqlimit(e,c)
	return c==e:GetLabelObject()
end
