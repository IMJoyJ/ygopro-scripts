--『焔聖剣－アルマス』
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡装备中的场合才能发动。从自己的卡组·墓地选「『焰圣剑-阿尔玛斯』」以外的1张「焰圣剑」装备魔法卡给可以把那张卡装备的自己场上1只怪兽装备。那之后，这张卡破坏。
-- ②：装备怪兽被送去墓地让这张卡被送去墓地的场合，以自己的墓地·除外状态的1只战士族·炎属性怪兽为对象才能发动。那只怪兽加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果，注册各项效果
function s.initial_effect(c)
	-- 对应装备魔法卡的发动与装备效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 对应装备魔法卡的装备对象限制
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ①：这张卡装备中的场合才能发动。从自己的卡组·墓地选「『焰圣剑-阿尔玛斯』」以外的1张「焰圣剑」装备魔法卡给可以把那张卡装备的自己场上1只怪兽装备。那之后，这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_EQUIP+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.eqtg)
	e3:SetOperation(s.eqop)
	c:RegisterEffect(e3)
	-- ②：装备怪兽被送去墓地让这张卡被送去墓地的场合，以自己的墓地·除外状态的1只战士族·炎属性怪兽为对象才能发动。那只怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.thcon)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
-- 作为装备魔法卡发动时的对象选择与目标确认
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在可以装备的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果分类为装备，并将自身作为装备卡登记到操作信息中
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 作为装备魔法卡发动时的效果处理（将自身装备给目标怪兽）
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 过滤条件：场上表侧表示且可以装备指定装备卡的怪兽
function s.filter(c,ec)
	return c:IsFaceup() and ec:CheckEquipTarget(c)
end
-- 过滤条件：卡组·墓地中「『焰圣剑-阿尔玛斯』」以外的「焰圣剑」装备魔法卡，且场上有可以装备它的怪兽
function s.eqfilter(c,tp)
	return c:GetType()&(TYPE_SPELL+TYPE_EQUIP)==TYPE_SPELL+TYPE_EQUIP and c:IsSetCard(0x607a) and not c:IsCode(id)
		and c:CheckUniqueOnField(tp) and not c:IsForbidden()
		-- 检查自己场上是否存在可以装备该装备魔法卡的怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil,c)
end
-- 效果①的发动准备与可行性检查
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己魔陷区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组或墓地中是否存在符合条件的「焰圣剑」装备魔法卡
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp) end
	-- 设置效果分类为装备，操作范围为卡组和墓地
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,0,LOCATION_DECK+LOCATION_GRAVE)
	-- 设置效果分类为破坏，操作对象为自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理（装备新卡并破坏自身）
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 若魔陷区已无空位，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要装备的装备魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从卡组或墓地选择1张符合条件的「焰圣剑」装备魔法卡（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp)
	if #g>0 then
		local tc=g:GetFirst()
		-- 提示玩家选择要装备的表侧表示怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 选择自己场上1只可以装备该卡的表侧表示怪兽
		local eqg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,tc)
		if #eqg>0 then
			-- 为选择的怪兽显示被选为目标的动画
			Duel.HintSelection(eqg)
			-- 将选中的装备魔法卡装备给选中的怪兽，若装备成功则继续处理
			if Duel.Equip(tp,tc,eqg:GetFirst()) then
				local c=e:GetHandler()
				if c:IsRelateToEffect(e) then
					-- 中断当前效果处理，使后续的破坏处理与装备处理不同时进行
					Duel.BreakEffect()
					-- 因效果破坏这张卡
					Duel.Destroy(c,REASON_EFFECT)
				end
			end
		end
	end
end
-- 效果②的发动条件：装备怪兽被送去墓地导致这张卡被送去墓地
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_LOST_TARGET) and c:GetPreviousEquipTarget():IsLocation(LOCATION_GRAVE)
end
-- 过滤条件：墓地或除外状态的战士族·炎属性怪兽
function s.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_WARRIOR)
		and c:IsAbleToHand() and c:IsFaceupEx()
end
-- 效果②的发动准备与对象选择
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.thfilter(chkc) end
	-- 检查墓地或除外状态是否存在符合条件的战士族·炎属性怪兽
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择墓地或除外状态的1只战士族·炎属性怪兽作为对象
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	-- 设置效果分类为加入手牌，操作对象为选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
-- 效果②的效果处理（将对象怪兽加入手牌）
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
