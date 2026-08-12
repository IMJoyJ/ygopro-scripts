--破壊剣－ドラゴンバスターブレード
-- 效果：
-- 「破坏剑-龙破坏之剑」的③的效果1回合只能使用1次。
-- ①：自己主要阶段以自己场上1只「破坏之剑士」为对象才能发动。从自己的手卡·场上把这只怪兽当作装备卡使用给那只自己怪兽装备。
-- ②：这张卡装备中的场合，对方不能从额外卡组把怪兽特殊召唤。
-- ③：这张卡装备中的场合才能发动。装备的这张卡特殊召唤。
function c76218313.initial_effect(c)
	-- ①：自己主要阶段以自己场上1只「破坏之剑士」为对象才能发动。从自己的手卡·场上把这只怪兽当作装备卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetTarget(c76218313.eqtg)
	e1:SetOperation(c76218313.eqop)
	c:RegisterEffect(e1)
	-- ②：这张卡装备中的场合，对方不能从额外卡组把怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetCondition(c76218313.effcon)
	e2:SetTarget(c76218313.splimit)
	c:RegisterEffect(e2)
	-- ③：这张卡装备中的场合才能发动。装备的这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1,76218313)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c76218313.spcon)
	e3:SetTarget(c76218313.sptg)
	e3:SetOperation(c76218313.spop)
	c:RegisterEffect(e3)
end
-- 过滤场上表侧表示的「破坏之剑士」的卡片过滤函数
function c76218313.filter(c)
	return c:IsFaceup() and c:IsCode(78193831)
end
-- 装备效果的发动准备与目标选择判定
function c76218313.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c76218313.filter(chkc) end
	-- 判定自己魔陷区是否有可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判定自己场上是否存在可以作为装备对象的「破坏之剑士」
		and Duel.IsExistingTarget(c76218313.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的对象怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只「破坏之剑士」作为效果的对象
	Duel.SelectTarget(tp,c76218313.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 装备效果的执行，将自身作为装备卡装备给目标怪兽，并添加装备限制效果
function c76218313.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 获取当前连锁中选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查魔陷区是否有空位、对象怪兽是否仍在自己场上表侧表示存在以及是否仍与效果相关联
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 若不满足装备条件，则将这张卡送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡装备给目标怪兽
	Duel.Equip(tp,c,tc)
	-- 当作装备卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c76218313.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end
-- 限制这张卡只能装备给作为对象的那只怪兽
function c76218313.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 判定这张卡当前是否有装备对象（即是否处于装备状态）
function c76218313.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget()
end
-- 特殊召唤效果的发动准备与可行性判定
function c76218313.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定自己怪兽区是否有可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的执行，将自身特殊召唤到场上
function c76218313.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 判定这张卡当前是否有装备对象（用于封锁额外卡组特召效果的生效条件）
function c76218313.effcon(e)
	return e:GetHandler():GetEquipTarget()
end
-- 限制特殊召唤的怪兽不能来自额外卡组
function c76218313.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end
