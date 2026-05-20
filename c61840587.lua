--携帯型バッテリー
-- 效果：
-- 从自己墓地选择2只名字带有「电池人」的怪兽，攻击表示特殊召唤。这张卡从场上离开时，那些怪兽全部破坏。那些怪兽全部从场上离开时这张卡破坏。
function c61840587.initial_effect(c)
	-- 从自己墓地选择2只名字带有「电池人」的怪兽，攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c61840587.target)
	e1:SetOperation(c61840587.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时，那些怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c61840587.desop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- 那些怪兽全部从场上离开时这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c61840587.descon2)
	e3:SetOperation(c61840587.desop2)
	e3:SetLabelObject(e1)
	c:RegisterEffect(e3)
end
-- 过滤自己墓地中名字带有「电池人」且可以攻击表示特殊召唤的怪兽
function c61840587.filter(c,e,tp)
	return c:IsSetCard(0x28) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果发动时的对象选择与合法性检测
function c61840587.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c61840587.filter(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检测自己场上的怪兽区域空位数是否大于1
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检测自己墓地是否存在至少2只满足条件的「电池人」怪兽
		and Duel.IsExistingTarget(c61840587.filter,tp,LOCATION_GRAVE,0,2,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地2只满足条件的「电池人」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c61840587.filter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp)
	-- 设置连锁的操作信息，表示该效果包含特殊召唤2只对象怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
	if e:GetLabelObject() then e:GetLabelObject():DeleteGroup() end
	e:SetLabelObject(nil)
end
-- 过滤出仍与该效果相关且可以攻击表示特殊召唤的怪兽
function c61840587.sfilter(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果处理，将选择的墓地怪兽特殊召唤，并建立与这张卡的相互关联
function c61840587.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(c61840587.sfilter,nil,e,tp)
	local sct=sg:GetCount()
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if sct==0 or ft<=0 or (sct>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	if sct>ft then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		sg=sg:Select(tp,ft,ft,nil)
		sct=ft
	end
	local tc=sg:GetFirst()
	-- 循环将符合条件的怪兽以表侧攻击表示进行特殊召唤的准备步骤
	while tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK) do
		c:SetCardTarget(tc)
		tc:CreateRelation(c,RESET_EVENT+0x1020000)
		tc=sg:GetNext()
	end
	e:SetLabelObject(sg)
	sg:KeepAlive()
	-- 完成所有准备步骤中怪兽的特殊召唤
	Duel.SpecialSummonComplete()
end
-- 过滤出仍与这张卡关联、在怪兽区且未确定被破坏的怪兽
function c61840587.desfilter1(c,rc)
	return c:IsRelateToCard(rc) and c:IsLocation(LOCATION_MZONE) and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- 这张卡离场时，破坏所有与其关联的怪兽
function c61840587.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sg=e:GetLabelObject():GetLabelObject()
	if not sg then return end
	-- 因效果破坏所有仍与这张卡关联的怪兽
	Duel.Destroy(sg:Filter(c61840587.desfilter1,nil,c),REASON_EFFECT)
	sg:DeleteGroup()
	e:SetLabelObject(nil)
end
-- 检测与这张卡关联的怪兽是否全部从场上离开
function c61840587.descon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sg=e:GetLabelObject():GetLabelObject()
	if not sg or c:IsStatus(STATUS_DESTROY_CONFIRMED) then return false end
	local rg=eg:Filter(Card.IsRelateToCard,nil,c)
	local tc=rg:GetFirst()
	while tc do sg:RemoveCard(tc) tc=rg:GetNext() end
	return sg:GetCount()==0
end
-- 关联怪兽全部离场时，破坏这张卡
function c61840587.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果破坏这张卡
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
