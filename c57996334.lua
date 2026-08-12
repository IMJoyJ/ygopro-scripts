--ドドドバスター
-- 效果：
-- ①：只有对方场上才有怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤的这张卡的等级变成4星。
-- ②：这张卡上级召唤成功时，以自己墓地1只「怒怒怒」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
function c57996334.initial_effect(c)
	-- ①：只有对方场上才有怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤的这张卡的等级变成4星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c57996334.spcon)
	e1:SetOperation(c57996334.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡上级召唤成功时，以自己墓地1只「怒怒怒」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(57996334,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c57996334.sumcon)
	e2:SetTarget(c57996334.sumtg)
	e2:SetOperation(c57996334.sumop)
	c:RegisterEffect(e2)
end
-- 判断自身特殊召唤的条件是否满足（自己场上无怪兽、对方场上有怪兽且自己场上有空位）
function c57996334.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 检查对方场上的怪兽数量是否大于0
		and	Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
		-- 检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 自身特殊召唤成功时的处理，注册使自身等级变成4星的效果
function c57996334.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 这个方法特殊召唤的这张卡的等级变成4星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetReset(RESET_EVENT+0xff0000)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetValue(4)
	c:RegisterEffect(e1)
end
-- 检查这张卡是否是通过上级召唤成功
function c57996334.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 过滤出自己墓地中可以守备表示特殊召唤的「怒怒怒」怪兽
function c57996334.filter(c,e,tp)
	return c:IsSetCard(0x82) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 上级召唤成功时效果的发动准备，进行对象选择的合法性检查，并选择目标怪兽
function c57996334.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c57996334.filter(chkc,e,tp) end
	-- 在效果发动阶段，检查自己墓地是否存在满足条件的「怒怒怒」怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c57996334.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 并且检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 在界面上提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的「怒怒怒」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c57996334.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表示该效果包含将选中的1只怪兽特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 上级召唤成功时效果的处理，将选中的对象怪兽守备表示特殊召唤
function c57996334.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
