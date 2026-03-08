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
	-- 1回合1次，选择自己的场上·墓地1只名字带有「星圣」的怪兽才能发动。这张卡变成和选择的怪兽相同等级。
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
-- 判断特殊召唤条件：自己场上没有怪兽且对方场上存在怪兽且自己场上存在空位
function c44635489.spcon(e,c)
	if c==nil then return true end
	-- 判断自己场上是否存在怪兽
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 判断对方场上是否存在怪兽
		and	Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
		-- 判断自己场上是否存在空位
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 筛选目标怪兽：名字带有「星圣」且等级高于1且不是当前等级且在场上或墓地
function c44635489.filter(c,clv)
	return c:IsSetCard(0x53) and c:IsLevelAbove(1) and not c:IsLevel(clv)
		and ((c:IsLocation(LOCATION_MZONE) and c:IsFaceup()) or c:IsLocation(LOCATION_GRAVE))
end
-- 设置等级变化效果的目标选择逻辑
function c44635489.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and c44635489.filter(chkc,e:GetHandler():GetLevel()) end
	-- 检查是否存在符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c44635489.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,e:GetHandler(),e:GetHandler():GetLevel()) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择符合条件的目标怪兽
	Duel.SelectTarget(tp,c44635489.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,e:GetHandler(),e:GetHandler():GetLevel())
end
-- 执行等级变化效果的操作
function c44635489.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e)
		and (not tc:IsLocation(LOCATION_MZONE) or tc:IsFaceup()) then
		-- 将当前怪兽等级设置为所选目标怪兽的等级
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e:GetHandler():RegisterEffect(e1)
	end
end
-- 设置超量素材限制效果：不是名字带有「星圣」的怪兽不能作为超量素材
function c44635489.xyzlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0x53)
end
