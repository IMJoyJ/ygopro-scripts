--クリフォート・ゲノム
-- 效果：
-- ←9 【灵摆】 9→
-- ①：自己不是「机壳」怪兽不能特殊召唤。这个效果不会被无效化。
-- ②：对方场上的怪兽的攻击力下降300。
-- 【怪兽效果】
-- ①：这张卡可以不用解放作召唤。
-- ②：特殊召唤或者不用解放作召唤的这张卡的等级变成4星，原本攻击力变成1800。
-- ③：通常召唤的这张卡不受原本的等级或者阶级比这张卡的等级低的怪兽发动的效果影响。
-- ④：这张卡被解放的场合，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
function c37991342.initial_effect(c)
	-- 为灵摆怪兽添加灵摆怪兽属性（灵摆召唤，灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- 自己不是「机壳」怪兽不能特殊召唤。这个效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c37991342.splimit)
	c:RegisterEffect(e2)
	-- 对方场上的怪兽的攻击力下降300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetValue(-300)
	c:RegisterEffect(e3)
	-- 这张卡可以不用解放作召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(37991342,0))  --"不用解放作召唤"
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SUMMON_PROC)
	e4:SetCondition(c37991342.ntcon)
	c:RegisterEffect(e4)
	-- 特殊召唤或者不用解放作召唤的这张卡的等级变成4星，原本攻击力变成1800。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_SUMMON_COST)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetOperation(c37991342.lvop)
	c:RegisterEffect(e5)
	-- 特殊召唤或者不用解放作召唤的这张卡的等级变成4星，原本攻击力变成1800。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_SPSUMMON_COST)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetOperation(c37991342.lvop2)
	c:RegisterEffect(e6)
	-- 通常召唤的这张卡不受原本的等级或者阶级比这张卡的等级低的怪兽发动的效果影响。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_IMMUNE_EFFECT)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCondition(c37991342.immcon)
	-- 设置效果值为机壳怪兽通用抗性过滤函数
	e7:SetValue(aux.qlifilter)
	c:RegisterEffect(e7)
	-- 这张卡被解放的场合，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(37991342,1))  --"魔陷破坏"
	e8:SetCategory(CATEGORY_DESTROY)
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e8:SetCode(EVENT_RELEASE)
	e8:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e8:SetTarget(c37991342.destg)
	e8:SetOperation(c37991342.desop)
	c:RegisterEffect(e8)
end
-- 限制非机壳怪兽特殊召唤
function c37991342.splimit(e,c)
	return not c:IsSetCard(0xaa)
end
-- 判断是否满足不用解放作召唤的条件
function c37991342.ntcon(e,c,minc)
	if c==nil then return true end
	-- 召唤等级不低于5且场上存在空位
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 判断是否满足等级和攻击力变更的条件
function c37991342.lvcon(e)
	return e:GetHandler():GetMaterialCount()==0
end
-- 设置召唤时等级和攻击力变更效果
function c37991342.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 设置等级变更效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c37991342.lvcon)
	e1:SetValue(4)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
	-- 设置攻击力变更效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_BASE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c37991342.lvcon)
	e2:SetValue(1800)
	e2:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e2)
end
-- 设置特殊召唤时等级和攻击力变更效果
function c37991342.lvop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 设置等级变更效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(4)
	e1:SetReset(RESET_EVENT+0x7f0000)
	c:RegisterEffect(e1)
	-- 设置攻击力变更效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_BASE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1800)
	e2:SetReset(RESET_EVENT+0x7f0000)
	c:RegisterEffect(e2)
end
-- 判断是否为通常召唤
function c37991342.immcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL)
end
-- 过滤魔法·陷阱卡
function c37991342.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置魔陷破坏效果的目标选择和操作信息
function c37991342.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c37991342.desfilter(chkc) end
	-- 检查是否存在可破坏的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c37991342.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择一张魔法·陷阱卡作为破坏对象
	local g=Duel.SelectTarget(tp,c37991342.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行魔陷破坏效果
function c37991342.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏目标卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
