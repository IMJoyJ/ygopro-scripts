--甲虫装機 ギガマンティス
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：以自己场上1只「甲虫装机」怪兽为对象才能发动。这张卡从手卡当作装备卡使用给那只自己的「甲虫装机」怪兽装备。
-- ②：把这张卡当作装备卡使用来装备的怪兽的原本攻击力变成2400。
-- ③：给怪兽装备的这张卡被送去墓地的场合，以「甲虫装机 吉咖螳螂」以外的自己墓地1只「甲虫装机」怪兽为对象才能发动。那只怪兽特殊召唤。
function c94573223.initial_effect(c)
	-- ①：以自己场上1只「甲虫装机」怪兽为对象才能发动。这张卡从手卡当作装备卡使用给那只自己的「甲虫装机」怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94573223,0))  --"装备"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetRange(LOCATION_HAND)
	e1:SetTarget(c94573223.eqtg)
	e1:SetOperation(c94573223.eqop)
	c:RegisterEffect(e1)
	-- ②：把这张卡当作装备卡使用来装备的怪兽的原本攻击力变成2400。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_SET_BASE_ATTACK)
	e2:SetValue(2400)
	c:RegisterEffect(e2)
	-- ③：给怪兽装备的这张卡被送去墓地的场合，以「甲虫装机 吉咖螳螂」以外的自己墓地1只「甲虫装机」怪兽为对象才能发动。那只怪兽特殊召唤。这个卡名的③的效果1回合只能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(94573223,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,94573223)
	e3:SetCondition(c94573223.spcon)
	e3:SetTarget(c94573223.sptg)
	e3:SetOperation(c94573223.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的「甲虫装机」怪兽
function c94573223.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x56)
end
-- 装备效果的靶向与合法性检测（Target）
function c94573223.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c94573223.filter(chkc) end
	-- 第一阶段：检查自己场上的魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并且自己场上存在至少1只满足过滤条件的「甲虫装机」怪兽
		and Duel.IsExistingTarget(c94573223.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示的「甲虫装机」怪兽作为效果对象
	Duel.SelectTarget(tp,c94573223.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 装备效果的执行处理（Operation）
function c94573223.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 如果魔陷区无空位、对象怪兽变为里侧表示、对象怪兽已离开场上或控制权转移
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not tc:IsControler(tp) then
		-- 将这张卡（吉咖螳螂）送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡装备给目标怪兽
	Duel.Equip(tp,c,tc)
	-- 这张卡从手卡当作装备卡使用给那只自己的「甲虫装机」怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c94573223.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end
-- 装备限制：只能装备给作为效果对象的那只怪兽
function c94573223.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 特殊召唤效果的发动条件：给怪兽装备的这张卡被送去墓地
function c94573223.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:GetPreviousEquipTarget() and not c:IsReason(REASON_LOST_TARGET)
end
-- 过滤条件：自己墓地中「甲虫装机 吉咖螳螂」以外的、可以特殊召唤的「甲虫装机」怪兽
function c94573223.spfilter(c,e,tp)
	return c:IsSetCard(0x56) and not c:IsCode(94573223) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的靶向与合法性检测（Target）
function c94573223.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c94573223.spfilter(chkc,e,tp) end
	-- 第一阶段：检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己墓地存在至少1只满足过滤条件的「甲虫装机」怪兽
		and Duel.IsExistingTarget(c94573223.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的「甲虫装机」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c94573223.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息：包含特殊召唤分类，操作对象为选中的怪兽，数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的执行处理（Operation）
function c94573223.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为特殊召唤对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
