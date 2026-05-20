--オレイカルコス・シュノロス
-- 效果：
-- 这张卡不能通常召唤。这张卡的①的效果可以特殊召唤。
-- ①：自己的通常怪兽被战斗破坏的场合，伤害步骤结束时才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡的攻击力上升对方场上的怪兽数量×1000。
-- ③：只要这张卡在怪兽区域存在，场上的4星通常怪兽不会被效果破坏。
function c7634581.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：自己的通常怪兽被战斗破坏的场合，伤害步骤结束时才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7634581,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c7634581.spcon)
	e1:SetTarget(c7634581.sptg)
	e1:SetOperation(c7634581.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力上升对方场上的怪兽数量×1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c7634581.value)
	c:RegisterEffect(e2)
	-- ③：只要这张卡在怪兽区域存在，场上的4星通常怪兽不会被效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c7634581.efilter)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 计算攻击力上升值的辅助函数，返回对方场上怪兽数量乘以1000的数值
function c7634581.value(e,c)
	-- 获取对方场上的怪兽数量并乘以1000作为返回值
	return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)*1000
end
-- 过滤出场上4星通常怪兽的靶向过滤函数
function c7634581.efilter(e,c)
	return c:IsType(TYPE_NORMAL) and c:IsLevel(4)
end
-- 过滤出原本在自己场上且是通常怪兽的卡片的辅助函数
function c7634581.cfilter(c,tp)
	return bit.band(c:GetPreviousTypeOnField(),TYPE_NORMAL)~=0 and c:IsPreviousControler(tp)
end
-- 检查被破坏的怪兽中是否存在自己场上的通常怪兽，作为特殊召唤效果的发动条件
function c7634581.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c7634581.cfilter,1,nil,tp)
end
-- 特殊召唤效果的发动准备与合法性检测函数
function c7634581.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) end
	-- 设置连锁的操作信息，表明该效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的具体执行函数，将自身特殊召唤并完成正规召唤程序
function c7634581.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 尝试将自身以表侧表示特殊召唤，并判断是否特殊召唤成功（无视召唤条件，但不无视苏生限制）
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end
