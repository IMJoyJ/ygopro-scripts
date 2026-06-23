--リビング・フォッシル
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只4星以下的怪兽为对象才能把这张卡发动。那只怪兽特殊召唤，把这张卡装备。这个效果特殊召唤的怪兽从场上离开的场合除外。这张卡从场上离开时那只怪兽除外。
-- ②：装备怪兽的攻击力·守备力下降1000，效果无效化。
function c34959756.initial_effect(c)
	-- ①：以自己墓地1只4星以下的怪兽为对象才能把这张卡发动。那只怪兽特殊召唤，把这张卡装备。这个效果特殊召唤的怪兽从场上离开的场合除外。这张卡从场上离开时那只怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,34959756+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c34959756.target)
	e1:SetOperation(c34959756.activate)
	c:RegisterEffect(e1)
	-- 这个效果特殊召唤的怪兽从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c34959756.rmop)
	c:RegisterEffect(e2)
	-- ②：装备怪兽的攻击力·守备力下降1000，效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(-1000)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	-- ②：装备怪兽的攻击力·守备力下降1000，效果无效化。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e5)
end
-- 筛选墓地里等级4以下且可以特殊召唤的怪兽
function c34959756.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件
function c34959756.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c34959756.spfilter(chkc,e,tp) end
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在符合条件的怪兽
		and Duel.IsExistingTarget(c34959756.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c34959756.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置操作信息为装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备对象限制函数
function c34959756.eqlimit(e,c)
	return e:GetLabelObject()==c
end
-- 处理效果发动时的特殊召唤与装备
function c34959756.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)
		-- 将目标怪兽特殊召唤
		and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 设置装备对象限制
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c34959756.eqlimit)
		e1:SetLabelObject(tc)
		c:RegisterEffect(e1)
		-- 设置装备怪兽离场时的处理
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e2:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e2,true)
	end
end
-- 处理装备卡离场时将装备怪兽除外
function c34959756.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetHandler():GetEquipTarget()
	if tc then
		-- 将装备怪兽除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
