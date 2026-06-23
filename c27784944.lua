--極天気ランブラ
-- 效果：
-- ①：这张卡召唤成功时才能发动。从自己的手卡·卡组·墓地选1张「天气」魔法·陷阱卡在自己的魔法与陷阱区域表侧表示放置。
-- ②：只要这张卡在怪兽区域存在，自己场上的「天气」魔法·陷阱卡不会成为对方的效果的对象，不会被对方的效果破坏。
-- ③：场上的这张卡为让「天气」卡的效果发动而被除外的场合，下个回合的准备阶段才能发动。除外的这张卡特殊召唤。
function c27784944.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从自己的手卡·卡组·墓地选1张「天气」魔法·陷阱卡在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27784944,0))  --"放置「天气」魔法·陷阱卡"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c27784944.tftg)
	e1:SetOperation(c27784944.tfop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己场上的「天气」魔法·陷阱卡不会成为对方的效果的对象，不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(c27784944.immtg)
	-- 设置效果值为tgoval函数，用于过滤不会成为对方效果对象的卡
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置效果值为indoval函数，用于过滤不会被对方效果破坏的卡
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	-- ③：场上的这张卡为让「天气」卡的效果发动而被除外的场合，下个回合的准备阶段才能发动。除外的这张卡特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_REMOVE)
	e4:SetOperation(c27784944.spreg)
	c:RegisterEffect(e4)
	-- 放置「天气」魔法·陷阱卡
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(27784944,1))  --"除外的这张卡特殊召唤"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetRange(LOCATION_REMOVED)
	e5:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e5:SetCondition(c27784944.spcon)
	e5:SetTarget(c27784944.sptg)
	e5:SetOperation(c27784944.spop)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
end
-- 过滤函数：满足条件的卡为魔法陷阱卡且为天气卡组，且未被禁止，且在场上满足唯一性
function c27784944.tffilter(c,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsType(TYPE_FIELD) and c:IsSetCard(0x109)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 判断是否满足发动条件：场上存在魔法陷阱区域空位且自己手卡·卡组·墓地存在满足条件的天气魔法陷阱卡
function c27784944.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在魔法陷阱区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断自己手卡·卡组·墓地是否存在满足条件的天气魔法陷阱卡
		and Duel.IsExistingMatchingCard(c27784944.tffilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,nil,tp) end
	-- 向对方提示该效果发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 处理效果：若场上存在魔法陷阱区域空位则选择一张天气魔法陷阱卡放置到魔法陷阱区域
function c27784944.tfop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否存在魔法陷阱区域空位
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 选择满足条件的天气魔法陷阱卡
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c27784944.tffilter),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 将选中的卡移动到魔法陷阱区域
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
-- 过滤函数：满足条件的卡为天气魔法陷阱卡
function c27784944.immtg(e,c)
	return c:IsSetCard(0x109) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 处理效果：当此卡因费用被除外时，记录下回合数并注册标记
function c27784944.spreg(e,tp,eg,ep,ev,re,r,rp)
	if not re then return end
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if c:IsReason(REASON_COST) and rc:IsSetCard(0x109) and c:IsPreviousLocation(LOCATION_ONFIELD) and re:IsActivated() then
		-- 记录下回合数
		e:SetLabel(Duel.GetTurnCount()+1)
		c:RegisterFlagEffect(27784944,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
	end
end
-- 判断是否满足发动条件：当前回合数等于记录的回合数且此卡具有标记
function c27784944.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合数是否等于记录的回合数且此卡具有标记
	return e:GetLabelObject():GetLabel()==Duel.GetTurnCount() and e:GetHandler():GetFlagEffect(27784944)>0
end
-- 判断是否满足发动条件：场上存在怪兽区域空位且此卡可特殊召唤
function c27784944.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：准备特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():ResetFlagEffect(27784944)
end
-- 处理效果：若此卡满足特殊召唤条件则特殊召唤
function c27784944.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡特殊召唤到怪兽区域
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
