--ヴァンプ・オブ・ヴァンパイア
-- 效果：
-- ①：这张卡召唤成功时或者自己场上有「吸血鬼」怪兽召唤时，以比这张卡攻击力高的对方场上1只怪兽为对象才能发动。那只怪兽当作装备卡使用给这张卡装备。这个效果1回合只能使用1次。
-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的原本攻击力数值。
-- ③：用这张卡的效果把装备卡装备的这张卡被送去墓地的场合发动。这张卡从墓地特殊召唤。
function c82962242.initial_effect(c)
	-- ①：这张卡召唤成功时，以比这张卡攻击力高的对方场上1只怪兽为对象才能发动。那只怪兽当作装备卡使用给这张卡装备。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82962242,0))  --"装备"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetTarget(c82962242.eqtg)
	e1:SetOperation(c82962242.eqop)
	c:RegisterEffect(e1)
	-- ①：自己场上有「吸血鬼」怪兽召唤时，以比这张卡攻击力高的对方场上1只怪兽为对象才能发动。那只怪兽当作装备卡使用给这张卡装备。这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(82962242,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCondition(c82962242.eqcon)
	e2:SetTarget(c82962242.eqtg)
	e2:SetOperation(c82962242.eqop)
	c:RegisterEffect(e2)
	-- ③：用这张卡的效果把装备卡装备的这张卡被送去墓地的场合发动。这张卡从墓地特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD_P)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(c82962242.checkop)
	c:RegisterEffect(e3)
	-- ③：用这张卡的效果把装备卡装备的这张卡被送去墓地的场合发动。这张卡从墓地特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(82962242,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c82962242.spcon)
	e4:SetTarget(c82962242.sptg)
	e4:SetOperation(c82962242.spop)
	c:RegisterEffect(e4)
	e3:SetLabelObject(e4)
end
-- 过滤出自己场上表侧表示的「吸血鬼」怪兽
function c82962242.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x8e) and c:IsControler(tp)
end
-- 判断是否因自己场上有其他「吸血鬼」怪兽召唤而触发效果
function c82962242.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c82962242.cfilter,1,nil,tp)
end
-- 过滤出对方场上表侧表示、攻击力比这张卡高且可以转移控制权的怪兽
function c82962242.eqfilter(c,atk)
	return c:IsFaceup() and c:GetAttack()>atk and c:IsAbleToChangeControler()
end
-- 装备效果的靶向与对象选择函数，判断是否满足发动条件并进行取对象操作
function c82962242.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c82962242.eqfilter(chkc,e:GetHandler():GetAttack()) end
	-- 在发动效果的准备阶段，检查自己魔陷区是否有可用的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查对方场上是否存在至少1只攻击力比这张卡高的怪兽可以作为对象
		and Duel.IsExistingTarget(c82962242.eqfilter,tp,0,LOCATION_MZONE,1,nil,e:GetHandler():GetAttack()) end
	-- 向发动效果的玩家提示选择要装备的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择对方场上1只符合条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c82962242.eqfilter,tp,0,LOCATION_MZONE,1,1,nil,e:GetHandler():GetAttack())
end
-- 装备效果的执行函数，将选中的怪兽作为装备卡装备给这张卡，并使其攻击力上升，同时设置装备限制和标记
function c82962242.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，如果自己魔陷区没有空位，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	-- 获取在发动时选择的作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or not tc:IsType(TYPE_MONSTER) then return end
	local atk=tc:GetTextAttack()
	if tc:IsFacedown() or atk<0 then atk=0 end
	-- 将目标怪兽作为装备卡装备给这张卡，如果装备失败则结束处理
	if not Duel.Equip(tp,tc,c) then return end
	-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的原本攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	-- ①：那只怪兽当作装备卡使用给这张卡装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c82962242.eqlimit)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e2)
	tc:RegisterFlagEffect(82962242,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- 限制装备卡只能装备在当前卡片上，且在当前卡片效果无效时失效
function c82962242.eqlimit(e,c)
	return e:GetOwner()==c and not c:IsDisabled()
end
-- 过滤出带有本卡效果标记的装备卡
function c82962242.spfilter(c)
	return c:GetFlagEffect(82962242)~=0
end
-- 在卡片离开场上时，检测其装备卡中是否存在通过本卡效果装备的怪兽，并将检测结果保存在特殊召唤效果的Label中
function c82962242.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetEquipGroup():IsExists(c82962242.spfilter,1,nil) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 特殊召唤效果的发动条件，要求离场前确实装备了本卡效果装备的卡，且之前是在怪兽区
function c82962242.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabel()==1 and e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
-- 特殊召唤效果的靶向与对象选择函数，检查怪兽区空位以及自身是否能特殊召唤，并设置特殊召唤的操作信息
function c82962242.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果的准备阶段，检查自己怪兽区是否有可用的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，声明将特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的执行函数，将自身从墓地特殊召唤
function c82962242.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身以表侧表示特殊召唤到自己的怪兽区
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
