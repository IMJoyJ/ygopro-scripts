--セイクリッド・シェアト
-- 效果：
-- 对方场上有怪兽存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。此外，1回合1次，选择自己的场上·墓地1只名字带有「星圣」的怪兽才能发动。这张卡变成和选择的怪兽相同等级。把场上的这张卡作为超量素材的场合，不是名字带有「星圣」的怪兽的超量召唤不能使用。
function c44635489.initial_effect(c)
	-- 对方场上有怪兽存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c44635489.spcon)
	c:RegisterEffect(e1)
	-- 此外，1回合1次，选择自己的场上·墓地1只名字带有「星圣」的怪兽才能发动。这张卡变成和选择的怪兽相同等级。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44635489,0))  --"等级变化"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c44635489.lvtg)
	e2:SetOperation(c44635489.lvop)
	c:RegisterEffect(e2)
	-- 把场上的这张卡作为超量素材的场合，不是名字带有「星圣」的怪兽的超量召唤不能使用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetValue(c44635489.xyzlimit)
	c:RegisterEffect(e3)
end
-- EFFECT_SPSUMMON_PROC特殊召唤规则效果的发动条件：此卡在手卡时，满足自己场上无怪兽、对方场上有怪兽且自己主要怪兽区有空位，即可作为规则特殊召唤。
function c44635489.spcon(e,c)
	if c==nil then return true end
	-- 检查自己主要怪兽区没有怪兽（满足“自己场上没有怪兽存在”的条件）。
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 检查对方主要怪兽区存在怪兽（满足“对方场上有怪兽存在”的条件）。
		and	Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
		-- 检查自己主要怪兽区有可用的空格，用于将此卡从手卡特殊召唤到场上。
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 筛选可用作对象的“星圣”怪兽：必须是名字带有「星圣」、等级1以上、且等级与这张卡当前等级不同的怪兽；若在场需表侧表示，或在墓地即可。
function c44635489.filter(c,clv)
	return c:IsSetCard(0x53) and c:IsLevelAbove(1) and not c:IsLevel(clv)
		and ((c:IsLocation(LOCATION_MZONE) and c:IsFaceup()) or c:IsLocation(LOCATION_GRAVE))
end
-- 选择对象的发动处理：从自己场上·墓地中选出1只符合条件的“星圣”怪兽作为效果对象（取对象）。
function c44635489.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and c44635489.filter(chkc,e:GetHandler():GetLevel()) end
	-- 在发动时点检查是否存在至少1只符合条件的“星圣”怪兽可以作为对象，没有则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c44635489.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,e:GetHandler(),e:GetHandler():GetLevel()) end
	-- 弹出选择提示，告知玩家需要选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从符合条件的怪兽中选择1只，并将其设为效果对象。
	Duel.SelectTarget(tp,c44635489.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,e:GetHandler(),e:GetHandler():GetLevel())
end
-- 效果处理：若这张卡仍在场上表侧表示且与效果关联，对象也仍与效果关联，则创建一个使这张卡等级变为对象等级的效果并注册。
function c44635489.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果处理时选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e)
		and (not tc:IsLocation(LOCATION_MZONE) or tc:IsFaceup()) then
		-- 这张卡变成和选择的怪兽相同等级。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e:GetHandler():RegisterEffect(e1)
	end
end
-- 当此卡要作为超量素材时，如果所超量召唤的怪兽不是名字带有「星圣」的怪兽，则不能作为素材。
function c44635489.xyzlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0x53)
end
