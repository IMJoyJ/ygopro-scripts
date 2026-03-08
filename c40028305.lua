--超重武者装留シャイン・クロー
-- 效果：
-- 「超重武者装留 光爪」的②的效果1回合只能使用1次。
-- ①：自己主要阶段以自己场上1只「超重武者」怪兽为对象才能发动。从自己的手卡·场上把这只怪兽当作攻击力·守备力上升500的装备卡使用给那只自己怪兽装备。装备怪兽不会被战斗破坏。
-- ②：这张卡的效果让这张卡装备中的场合才能发动。装备的这张卡特殊召唤。
function c40028305.initial_effect(c)
	-- ①：自己主要阶段以自己场上1只「超重武者」怪兽为对象才能发动。从自己的手卡·场上把这只怪兽当作攻击力·守备力上升500的装备卡使用给那只自己怪兽装备。装备怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetTarget(c40028305.eqtg)
	e1:SetOperation(c40028305.eqop)
	c:RegisterEffect(e1)
end
-- 筛选场上正面表示的「超重武者」怪兽
function c40028305.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9a)
end
-- 效果处理时判断是否满足条件
function c40028305.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c40028305.eqfilter(chkc) end
	-- 判断玩家场上是否有足够的魔法陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断玩家场上是否有符合条件的「超重武者」怪兽
		and Duel.IsExistingTarget(c40028305.eqfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择目标怪兽
	Duel.SelectTarget(tp,c40028305.eqfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 处理装备效果的执行流程
function c40028305.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断装备条件是否满足
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 将装备卡送入墓地
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
	e1:SetValue(c40028305.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升500
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(500)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- 装备怪兽不会被战斗破坏
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetReset(RESET_EVENT+RESETS_STANDARD)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- ②：这张卡的效果让这张卡装备中的场合才能发动。装备的这张卡特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1,40028305)
	e5:SetTarget(c40028305.sptg)
	e5:SetOperation(c40028305.spop)
	e5:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e5)
end
-- 限制只能装备给特定怪兽
function c40028305.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 判断是否可以特殊召唤
function c40028305.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function c40028305.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将装备卡特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
