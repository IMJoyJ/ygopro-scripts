--機塊テスト
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只「机块」连接怪兽为对象才能发动。从自己墓地把连接1「机块」连接怪兽尽可能在作为那只怪兽所连接区的自己场上特殊召唤。这个效果特殊召唤的怪兽在结束阶段除外。
function c66380357.initial_effect(c)
	-- ①：以自己场上1只「机块」连接怪兽为对象才能发动。从自己墓地把连接1「机块」连接怪兽尽可能在作为那只怪兽所连接区的自己场上特殊召唤。这个效果特殊召唤的怪兽在结束阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,66380357+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c66380357.target)
	e1:SetOperation(c66380357.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上的「机块」连接怪兽，且其所连接区有可特殊召唤的墓地连接1「机块」连接怪兽
function c66380357.filter(c,e,tp)
	if not (c:IsType(TYPE_LINK) and c:IsSetCard(0x14b)) then return false end
	local zone=c:GetLinkedZone(tp)
	-- 检查自己墓地是否存在至少1只可以特殊召唤到该怪兽所连接区的连接1「机块」连接怪兽
	return Duel.IsExistingMatchingCard(c66380357.gfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,zone)
end
-- 过滤墓地中可以特殊召唤到指定区域的连接1「机块」连接怪兽
function c66380357.gfilter(c,e,tp,zone)
	return c:IsSetCard(0x14b) and c:IsType(TYPE_LINK) and c:IsLink(1)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 效果发动时的目标选择与操作信息设置（取自己场上1只「机块」连接怪兽为对象，并声明特殊召唤的操作信息）
function c66380357.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c66380357.filter(chkc,e,tp) end
	-- 检查自己场上是否存在符合条件的「机块」连接怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c66380357.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择作为效果对象的目标卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只「机块」连接怪兽作为对象
	local g=Duel.SelectTarget(tp,c66380357.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息（从墓地特殊召唤至少1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理函数（将墓地的连接1「机块」连接怪兽尽可能特殊召唤到对象怪兽的所连接区，并注册结束阶段除外的效果）
function c66380357.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local zone=bit.band(tc:GetLinkedZone(tp),0x1f)
	-- 计算对象怪兽所连接区中自己场上可用的怪兽区域数量上限
	local upbound=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)
	if upbound<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then upbound=1 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择最多等同于可用区域数量的、不受王家长眠之谷影响的连接1「机块」连接怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c66380357.gfilter),tp,LOCATION_GRAVE,0,1,upbound,nil,e,tp,zone)
	if g:GetCount()>0 then
		local fid=e:GetHandler():GetFieldID()
		local tc=g:GetFirst()
		while tc do
			-- 将选中的怪兽以表侧表示特殊召唤到对象怪兽的所连接区（单步处理）
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP,zone)
			tc:RegisterFlagEffect(66380357,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
			tc=g:GetNext()
		end
		-- 完成所有怪兽的特殊召唤处理
		Duel.SpecialSummonComplete()
		g:KeepAlive()
		-- 这个效果特殊召唤的怪兽在结束阶段除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(g)
		e1:SetCondition(c66380357.rmcon)
		e1:SetOperation(c66380357.rmop)
		-- 注册在结束阶段将特殊召唤的怪兽除外的全局时点效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 过滤带有当前效果标识（fid）的怪兽，用于后续除外处理
function c66380357.rmfilter(c,fid)
	return c:GetFlagEffectLabel(66380357)==fid
end
-- 检查是否存在需要除外的怪兽，若不存在则重置该除外效果
function c66380357.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c66380357.rmfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 结束阶段除外效果的具体执行（筛选出带有对应标识的怪兽并除外）
function c66380357.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c66380357.rmfilter,nil,e:GetLabel())
	-- 将目标怪兽因效果表侧表示除外
	Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
end
