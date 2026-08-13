--魅惑の女王 LV7
-- 效果：
-- ①：这张卡是已用「魅惑的女王 LV5」的效果特殊召唤的场合，1回合1次，以对方场上1只怪兽为对象才能发动。那只对方怪兽当作装备魔法卡使用给这张卡装备（只有1只可以装备）。
-- ②：这张卡被战斗破坏的场合，作为代替把这张卡的效果装备的怪兽破坏。
local s,id,o=GetID()
-- 定义这张卡的所有效果：登记LV5卡名；特殊召唤成功时如果来源为LV5则留下标志；①的装备效果（通常起动版和二速版）。
function c50140163.initial_effect(c)
	-- 将卡号23756165（魅惑的女王 LV5）登记为这张卡记载的卡名，用于判定‘这张卡是用魅惑的女王 LV5的效果特殊召唤’等关联事实。
	aux.AddCodeList(c,23756165)
	-- ①：这张卡是已用「魅惑的女王 LV5」的效果特殊召唤的场合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(c50140163.regop)
	c:RegisterEffect(e1)
	-- ①：这张卡是已用「魅惑的女王 LV5」的效果特殊召唤的场合，1回合1次，以对方场上1只怪兽为对象才能发动。那只对方怪兽当作装备魔法卡使用给这张卡装备（只有1只可以装备）。
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
-- 特殊召唤成功时，检查特殊召唤信息中记录的卡号是否是23756165；若是，则为这张卡注册持续到离场等重置的标志，记录‘由LV5效果特殊召唤’的事实。
function c50140163.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetSpecialSummonInfo(SUMMON_INFO_CODE)==23756165 then
		c:RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end
-- ①效果（一速起动版）的发动条件：确认拥有‘由LV5效果特殊召唤’的标志、当前没有由自己效果装备的怪兽、且该效果没有被赋予二速化，满足时才可作为起动效果发动。
function c50140163.eqcon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 返回真需三条件同时满足：拥有LV5特召标志（标志>0）、自身没有被自己效果装备的怪兽、且未处于可变为诱发即时效果的二速状态。
	return c:GetFlagEffect(id+1)>0 and not aux.IsSelfEquip(c,FLAG_ID_ALLURE_QUEEN) and not aux.IsCanBeQuickEffect(c,tp,95937545)
end
-- ①效果（二速诱发即时效果版）的发动条件：与一速版条件相同，但要求当前已被赋予二速化能力，此时可在对方回合作为诱发即时效果发动。
function c50140163.eqcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 返回真需三条件同时满足：拥有LV5特召标志（标志>0）、自身没有被自己效果装备的怪兽、且已被95937545效果赋予二速化能力。
	return c:GetFlagEffect(id+1)>0 and not aux.IsSelfEquip(c,FLAG_ID_ALLURE_QUEEN) and aux.IsCanBeQuickEffect(c,tp,95937545)
end
-- 定义对象筛选条件：对象怪兽必须能够变更控制权（才能被装备到己方场上）。
function c50140163.filter(c)
	return c:IsAbleToChangeControler()
end
-- 发动时的目标选择函数：检查对象合法性（对方主要怪兽区、可变更控制权）；首次检查时确认己方魔陷区有空位且对方场上存在可选的怪兽。具体选择操作在后续SelectTarget中完成。
function c50140163.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c50140163.filter(chkc) end
	-- 检查己方魔陷区是否有空位，以容纳即将装备过来的对方怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查对方场上是否存在至少1只满足可变更控制权条件的怪兽，作为效果可选择的发动对象。
		and Duel.IsExistingTarget(c50140163.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 给出选择提示消息“请选择要装备的卡”（HINTMSG_EQUIP），在后续选择框中显示对应文案。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择对方场上1只满足条件的怪兽作为效果对象，并将其登记为当前连锁的对象，供效果处理时获取。
	local g=Duel.SelectTarget(tp,c50140163.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 装备限制函数：只有效果持有者（魅惑的女王 LV7）这张卡才能成为该装备卡的装备对象，防止装备到其他怪兽上。
function c50140163.eqlimit(e,c)
	return e:GetOwner()==c
end
-- ①效果处理：取得对象怪兽，若仍与效果关联，则将其作为装备魔法卡装备给自己（保留原表示形式）；装备成功后，标记该怪兽为‘由这张卡的效果装备’，并给它附加只能装备给魅惑女王、以及代替其被战斗破坏的效果。
function c50140163.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的对象怪兽，即要被装备来的对方怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local atk=tc:GetTextAttack()
		local def=tc:GetTextDefense()
		if atk<0 then atk=0 end
		if def<0 then def=0 end
		-- 尝试将对象怪兽以装备卡形式装备给自己；若装备失败（如魔陷区无空位、怪兽已不能装备等），则终止本次效果处理。
		if not Duel.Equip(tp,tc,c,false) then return end
		tc:RegisterFlagEffect(FLAG_ID_ALLURE_QUEEN,RESET_EVENT+RESETS_STANDARD,0,0,id)
		-- 那只对方怪兽当作装备魔法卡使用给这张卡装备（只有1只可以装备）。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c50140163.eqlimit)
		tc:RegisterEffect(e1)
		-- ②：这张卡被战斗破坏的场合，作为代替把这张卡的效果装备的怪兽破坏。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE+EFFECT_FLAG_SET_AVAILABLE)
		e2:SetCode(EFFECT_DESTROY_SUBSTITUTE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(c50140163.repval)
		tc:RegisterEffect(e2)
	end
end
-- 代替破坏判定：只有本次破坏原因为战斗破坏（REASON_BATTLE）时，才将这装备的怪兽作为代替破坏的对象。
function c50140163.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
