--アポクリフォート・カーネル
-- 效果：
-- 这张卡不能特殊召唤，把自己场上3只「机壳」怪兽解放的场合才能通常召唤。
-- ①：通常召唤的这张卡不受魔法·陷阱卡的效果影响，也不受原本的等级或者阶级比这张卡的等级低的怪兽发动的效果影响。
-- ②：1回合1次，以对方场上1只怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。
function c40061558.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己场上3只「机壳」怪兽解放的场合才能通常召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRIBUTE_LIMIT)
	e2:SetValue(c40061558.tlimit)
	c:RegisterEffect(e2)
	-- 把自己场上3只「机壳」怪兽解放的场合才能通常召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(40061558,0))  --"把3只「机壳」怪兽解放"
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e3:SetCondition(c40061558.ttcon)
	e3:SetOperation(c40061558.ttop)
	e3:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_LIMIT_SET_PROC)
	c:RegisterEffect(e4)
	-- ①：通常召唤的这张卡不受魔法·陷阱卡的效果影响，也不受原本的等级或者阶级比这张卡的等级低的怪兽发动的效果影响。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
	e5:SetCondition(c40061558.immcon)
	e5:SetValue(c40061558.efilter)
	c:RegisterEffect(e5)
	-- ②：1回合1次，以对方场上1只怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_CONTROL)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1)
	e6:SetTarget(c40061558.cttg)
	e6:SetOperation(c40061558.ctop)
	c:RegisterEffect(e6)
end
-- 作为EFFECT_TRIBUTE_LIMIT的Value函数：限制这张卡上级召唤时只能把「机壳」（0xaa）怪兽作为祭品，非机壳怪兽不能用于解放召唤。
function c40061558.tlimit(e,c)
	return not c:IsSetCard(0xaa)
end
-- 作为召唤手续的Condition：当c为nil时（规则询问）返回true；否则判断是否满足至少3只祭品的上级召唤条件（所需最少祭品数不超过3且场上存在3只可祭品）。
function c40061558.ttcon(e,c,minc)
	if c==nil then return true end
	-- 检查所需的最少祭品数是否≤3，且当前场上存在至少3只可作为祭品的怪兽。
	return minc<=3 and Duel.CheckTribute(c,3)
end
-- 作为召唤手续的Operation：让玩家选择3只祭品怪兽，将选中怪兽记录为这张卡的素材，并解放它们以完成上级召唤。
function c40061558.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 让玩家tp选择恰好3只用于上级召唤这张卡的祭品怪兽，返回选中的祭品组g（受TRIBUTE_LIMIT限制只能选「机壳」怪兽）。
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	-- 将选中的祭品组g解放，解放原因为召唤（REASON_SUMMON）兼作上级召唤素材（REASON_MATERIAL）。
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 作为免疫效果的Condition：只有当这张卡是以通常召唤（SUMMON_TYPE_NORMAL）方式召唤成功时才适用，即只有通常召唤的这张卡获得后续免疫。
function c40061558.immcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL)
end
-- 作为无效/免疫效果的Value过滤函数：若发动效果的那张卡是魔法·陷阱卡，则此卡不受其效果影响（返回true）；否则调用机壳通用抗性过滤函数判断是否因发动怪兽的等级/阶级低于此卡而不受影响。
function c40061558.efilter(e,te)
	if te:IsActiveType(TYPE_SPELL+TYPE_TRAP) then return true
	-- 否则使用aux.qlifilter判断：若该效果由原本等级或阶级低于此卡的怪兽发动，则返回true（不受影响）。
	else return aux.qlifilter(e,te) end
end
-- 作为②效果的发动Target：处理对象选择，检查指定对象是否为对方场上1只可改变控制权的怪兽；发动时选择1只符合条件的对方怪兽作为对象，并设置操作信息为改变控制权。
function c40061558.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged() end
	-- 在发动合法性检查（chk==0）时，确认对方场上存在至少1只可以改变控制权的怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家tp发送HINTMSG_CONTROL选择提示消息，提示即将选择要改变控制权的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让玩家tp从对方场上选择1只可改变控制权的怪兽作为效果对象，并用Duel.SelectTarget将该对象与当前效果连锁关联。
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息：本效果包含改变控制权（CATEGORY_CONTROL），对象为已选择的1只怪兽g，供其他卡进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 作为②效果解决时的Operation：取得效果对象，确认其仍与效果有关联后，直到结束阶段获得其控制权。
function c40061558.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本效果发动时选择的对象怪兽（这是唯一对象，因此用GetFirstTarget获取）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 让tp获得对象怪兽tc的控制权，持续到结束阶段（PHASE_END），重置次数为1次，即只在结束阶段前有效。
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
