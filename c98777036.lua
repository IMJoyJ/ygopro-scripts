--トラゴエディア
-- 效果：
-- ①：自己受到战斗伤害时才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡的攻击力·守备力上升自己手卡数量×600。
-- ③：1回合1次，从手卡把1只怪兽送去墓地，以持有和那个等级相同等级的对方场上1只表侧表示怪兽为对象才能发动。得到那只表侧表示怪兽的控制权。
-- ④：1回合1次，以自己墓地1只怪兽为对象才能发动。这张卡的等级直到回合结束时变成和那只怪兽相同。
function c98777036.initial_effect(c)
	-- ①：自己受到战斗伤害时才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98777036,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetCondition(c98777036.sumcon)
	e1:SetTarget(c98777036.sumtg)
	e1:SetOperation(c98777036.sumop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力·守备力上升自己手卡数量×600。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c98777036.value)
	c:RegisterEffect(e2)
	-- ②：这张卡的攻击力·守备力上升自己手卡数量×600。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(c98777036.value)
	c:RegisterEffect(e3)
	-- ③：1回合1次，从手卡把1只怪兽送去墓地，以持有和那个等级相同等级的对方场上1只表侧表示怪兽为对象才能发动。得到那只表侧表示怪兽的控制权。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetDescription(aux.Stringid(98777036,1))  --"得到控制权"
	e4:SetCategory(CATEGORY_CONTROL)
	e4:SetCountLimit(1)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCost(c98777036.ctcos)
	e4:SetTarget(c98777036.cttar)
	e4:SetOperation(c98777036.ctop)
	c:RegisterEffect(e4)
	-- ④：1回合1次，以自己墓地1只怪兽为对象才能发动。这张卡的等级直到回合结束时变成和那只怪兽相同。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetDescription(aux.Stringid(98777036,2))  --"改变等级"
	e5:SetCountLimit(1)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetTarget(c98777036.lvtar)
	e5:SetOperation(c98777036.lvop)
	c:RegisterEffect(e5)
end
-- 计算攻击力·守备力上升数值的辅助函数
function c98777036.value(e,c)
	-- 返回自身控制者手卡数量乘以600的数值
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)*600
end
-- 特殊召唤效果的发动条件：受到战斗伤害
function c98777036.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_BATTLE)>0 and ep==tp
end
-- 特殊召唤效果的发动准备与合法性检测
function c98777036.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身怪兽区域是否有空位，以及自身是否能特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的执行函数
function c98777036.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以表侧表示特殊召唤到发动效果玩家的场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤条件：对方场上表侧表示、等级与送去墓地的怪兽相同且可以改变控制权的怪兽
function c98777036.ctffilter(c,lv)
	return c:IsControlerCanBeChanged() and c:IsFaceup() and c:IsLevel(lv)
end
-- 过滤条件：手卡中可以作为Cost送去墓地的怪兽，且对方场上存在与之等级相同的表侧表示怪兽
function c98777036.ctfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
		-- 检查对方场上是否存在至少1只满足控制权转移过滤条件的同等级怪兽
		and Duel.IsExistingTarget(c98777036.ctffilter,tp,0,LOCATION_MZONE,1,nil,c:GetLevel())
end
-- 得到控制权效果的Cost（从手卡将1只怪兽送去墓地）
function c98777036.ctcos(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可作为Cost送去墓地且满足后续效果发动条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c98777036.ctfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择手卡中1只满足条件的怪兽
	local sg=Duel.SelectMatchingCard(tp,c98777036.ctfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	e:SetLabel(sg:GetFirst():GetLevel())
	-- 将选择的怪兽作为Cost送去墓地
	Duel.SendtoGrave(sg,REASON_COST)
end
-- 得到控制权效果的对象选择与合法性检测
function c98777036.cttar(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c98777036.ctffilter(chkc,e:GetLabel()) end
	if chk==0 then return true end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只与送去墓地的怪兽等级相同的表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c98777036.ctffilter,tp,0,LOCATION_MZONE,1,1,nil,e:GetLabel())
	-- 设置连锁处理中的操作信息：改变所选怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 得到控制权效果的执行函数
function c98777036.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 获得目标怪兽的控制权
		Duel.GetControl(tc,tp)
	end
end
-- 过滤条件：自己墓地中等级大于0且与自身当前等级不同的怪兽
function c98777036.lvfilter(c,lv)
	return c:IsLevelAbove(0) and not c:IsLevel(lv)
end
-- 改变等级效果的对象选择与合法性检测
function c98777036.lvtar(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local lv=e:GetHandler():GetLevel()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c98777036.lvfilter(chkc,lv) end
	-- 检查自己墓地是否存在满足等级改变过滤条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c98777036.lvfilter,tp,LOCATION_GRAVE,0,1,nil,lv) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己墓地1只怪兽作为效果对象
	Duel.SelectTarget(tp,c98777036.lvfilter,tp,LOCATION_GRAVE,0,1,1,nil,lv)
end
-- 改变等级效果的执行函数
function c98777036.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为等级参考的目标墓地怪兽
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsRelateToEffect(e) and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的等级直到回合结束时变成和那只怪兽相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
