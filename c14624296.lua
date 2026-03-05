--超重武者装留ダブル・ホーン
-- 效果：
-- 「超重武者装留 双角」的②的效果1回合只能使用1次。
-- ①：自己主要阶段以自己场上1只「超重武者」怪兽为对象才能发动。从自己的手卡·场上把这只怪兽当作装备卡使用给那只自己怪兽装备。装备怪兽在同1次的战斗阶段中可以作2次攻击。
-- ②：这张卡的效果让这张卡装备中的场合才能发动。装备的这张卡特殊召唤。
function c14624296.initial_effect(c)
	-- ①：自己主要阶段以自己场上1只「超重武者」怪兽为对象才能发动。从自己的手卡·场上把这只怪兽当作装备卡使用给那只自己怪兽装备。装备怪兽在同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetTarget(c14624296.eqtg)
	e1:SetOperation(c14624296.eqop)
	c:RegisterEffect(e1)
end
-- 过滤场上存在的「超重武者」怪兽
function c14624296.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9a)
end
-- 效果处理时的条件判断与目标选择
function c14624296.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c14624296.eqfilter(chkc) end
	-- 判断玩家魔法区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断玩家场上是否存在符合条件的「超重武者」怪兽
		and Duel.IsExistingTarget(c14624296.eqfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	-- 选择符合条件的「超重武者」怪兽作为装备对象
	Duel.SelectTarget(tp,c14624296.eqfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 装备效果的处理函数
function c14624296.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断装备条件是否满足
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 若条件不满足则将装备卡送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将装备卡装备给目标怪兽
	Duel.Equip(tp,c,tc)
	-- ②：这张卡的效果让这张卡装备中的场合才能发动。装备的这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c14624296.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- 装备怪兽在同1次的战斗阶段中可以作2次攻击
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：这张卡的效果让这张卡装备中的场合才能发动。装备的这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,14624296)
	e3:SetTarget(c14624296.sptg)
	e3:SetOperation(c14624296.spop)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e3)
end
-- 限制该装备卡只能装备给特定怪兽
function c14624296.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 特殊召唤效果的处理函数
function c14624296.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以特殊召唤该卡
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理函数
function c14624296.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将装备卡特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
