--ストーンヘンジ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只攻击力0的怪兽为对象才能把这张卡发动。那只怪兽攻击表示特殊召唤，把这张卡装备。这张卡从场上离开时那只怪兽破坏。
function c70786111.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己墓地1只攻击力0的怪兽为对象才能把这张卡发动。那只怪兽攻击表示特殊召唤，把这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,70786111+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c70786111.target)
	e1:SetOperation(c70786111.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c70786111.desop)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地中可以表侧攻击表示特殊召唤且攻击力为0的怪兽
function c70786111.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) and c:IsAttack(0)
end
-- 效果发动时的对象合法性检测与目标选择
function c70786111.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c70786111.filter(chkc,e,tp) end
	-- 在发动效果时，检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动效果时，检查自己墓地是否存在至少1只符合条件的怪兽
		and Duel.IsExistingTarget(c70786111.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c70786111.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息，该效果包含特殊召唤选定怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置连锁信息，该效果包含将这张卡作为装备卡装备的操作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 定义装备限制，使装备卡只能装备给这张卡效果特殊召唤的怪兽
function c70786111.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 效果处理，将选定的墓地怪兽特殊召唤并装备这张卡，同时为装备卡添加装备限制
function c70786111.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在效果发动时选择的作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽以表侧攻击表示特殊召唤，若特殊召唤失败则结束效果处理
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)==0 then return end
		-- 将这张卡作为装备卡装备给特殊召唤的怪兽
		Duel.Equip(tp,c,tc)
		-- 把这张卡装备。
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c70786111.eqlimit)
		c:RegisterEffect(e1)
	end
end
-- 当这张卡从场上离开时，将这张卡装备的怪兽破坏
function c70786111.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 因效果将该怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
