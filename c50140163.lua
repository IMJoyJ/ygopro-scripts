--魅惑の女王 LV7
-- 效果：
-- ①：这张卡是已用「魅惑的女王 LV5」的效果特殊召唤的场合，1回合1次，以对方场上1只怪兽为对象才能发动。那只对方怪兽当作装备魔法卡使用给这张卡装备（只有1只可以装备）。
-- ②：这张卡被战斗破坏的场合，作为代替把这张卡的效果装备的怪兽破坏。
local s,id,o=GetID()
-- 初始化效果函数，注册特殊召唤成功时的触发效果和装备效果
function c50140163.initial_effect(c)
	-- 记录该卡与「魅惑的女王 LV5」的关联，用于判断是否由其特殊召唤
	aux.AddCodeList(c,23756165)
	-- 当此卡通过特殊召唤成功时，若为由「魅惑的女王 LV5」的效果特殊召唤，则标记flag id+1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(c50140163.regop)
	c:RegisterEffect(e1)
	-- 装备效果的起动形式，需满足条件且目标为对方怪兽，发动后将其当作装备卡装备给自身
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50140163,0))  --"装备"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCondition(c50140163.eqcon1)
	e2:SetTarget(c50140163.eqtg)
	e2:SetOperation(c50140163.eqop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCondition(c50140163.eqcon2)
	c:RegisterEffect(e3)
end
c50140163.lvup={23756165}
c50140163.lvdn={23756165,87257460}
-- 判断此卡是否由「魅惑的女王 LV5」特殊召唤而来，用于触发装备效果
function c50140163.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetSpecialSummonInfo(SUMMON_INFO_CODE)==23756165 then
		c:RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end
-- 判断此卡是否已通过LV5特殊召唤并标记flag，且当前未装备由自身效果装备的卡
function c50140163.eqcon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否已通过LV5特殊召唤并标记flag，且当前未装备由自身效果装备的卡，且不处于对方特定卡片影响下
	return c:GetFlagEffect(id+1)>0 and not aux.IsSelfEquip(c,FLAG_ID_ALLURE_QUEEN) and not aux.IsCanBeQuickEffect(c,tp,95937545)
end
-- 判断此卡是否已通过LV5特殊召唤并标记flag，且当前未装备由自身效果装备的卡，且处于对方特定卡片影响下
function c50140163.eqcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否已通过LV5特殊召唤并标记flag，且当前未装备由自身效果装备的卡，且处于对方特定卡片影响下
	return c:GetFlagEffect(id+1)>0 and not aux.IsSelfEquip(c,FLAG_ID_ALLURE_QUEEN) and aux.IsCanBeQuickEffect(c,tp,95937545)
end
-- 筛选可被控制权变更的怪兽作为装备目标
function c50140163.filter(c)
	return c:IsAbleToChangeControler()
end
-- 设置装备效果的目标选择条件，需满足场上存在可装备的对方怪兽
function c50140163.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c50140163.filter(chkc) end
	-- 检查玩家场上是否有足够的魔法陷阱区域用于装备
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查是否存在符合条件的对方怪兽作为装备对象
		and Duel.IsExistingTarget(c50140163.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择目标怪兽作为装备对象
	local g=Duel.SelectTarget(tp,c50140163.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 设置装备限制效果，确保只有装备者自身才能装备该卡
function c50140163.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 执行装备操作，将目标怪兽装备给自身，并注册相关效果
function c50140163.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local atk=tc:GetTextAttack()
		local def=tc:GetTextDefense()
		if atk<0 then atk=0 end
		if def<0 then def=0 end
		-- 尝试将目标怪兽装备给自身，若失败则返回
		if not Duel.Equip(tp,tc,c,false) then return end
		tc:RegisterFlagEffect(FLAG_ID_ALLURE_QUEEN,RESET_EVENT+RESETS_STANDARD,0,0,id)
		-- 为装备的怪兽添加装备限制效果，防止被其他效果装备
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c50140163.eqlimit)
		tc:RegisterEffect(e1)
		-- 为装备的怪兽注册替代破坏效果，使其在因战斗破坏时可被代替破坏
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE+EFFECT_FLAG_SET_AVAILABLE)
		e2:SetCode(EFFECT_DESTROY_SUBSTITUTE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(c50140163.repval)
		tc:RegisterEffect(e2)
	end
end
-- 判断破坏原因是否为战斗，用于决定是否触发替代破坏效果
function c50140163.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
