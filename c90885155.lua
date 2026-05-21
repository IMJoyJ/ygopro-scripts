--クリフォート・シェル
-- 效果：
-- ←9 【灵摆】 9→
-- ①：自己不是「机壳」怪兽不能特殊召唤。这个效果不会被无效化。
-- ②：对方场上的怪兽的攻击力下降300。
-- 【怪兽效果】
-- ①：这张卡可以不用解放作召唤。
-- ②：特殊召唤或者不用解放作召唤的这张卡的等级变成4星，原本攻击力变成1800。
-- ③：通常召唤的这张卡不受原本的等级或者阶级比这张卡的等级低的怪兽发动的效果影响。
-- ④：把「机壳」怪兽解放表侧表示上级召唤成功的场合，这张卡在同1次的战斗阶段中可以作2次攻击，向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
function c90885155.initial_effect(c)
	-- 注册灵摆怪兽的灵摆属性（灵摆召唤、灵摆卡的发动）。
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是「机壳」怪兽不能特殊召唤。这个效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c90885155.splimit)
	c:RegisterEffect(e2)
	-- ②：对方场上的怪兽的攻击力下降300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetValue(-300)
	c:RegisterEffect(e3)
	-- ①：这张卡可以不用解放作召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(90885155,0))  --"不用解放作召唤"
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SUMMON_PROC)
	e4:SetCondition(c90885155.ntcon)
	c:RegisterEffect(e4)
	-- ②：特殊召唤或者不用解放作召唤的这张卡的等级变成4星，原本攻击力变成1800。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_SUMMON_COST)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetOperation(c90885155.lvop)
	c:RegisterEffect(e5)
	-- ②：特殊召唤或者不用解放作召唤的这张卡的等级变成4星，原本攻击力变成1800。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_SPSUMMON_COST)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetOperation(c90885155.lvop2)
	c:RegisterEffect(e6)
	-- ③：通常召唤的这张卡不受原本的等级或者阶级比这张卡的等级低的怪兽发动的效果影响。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_IMMUNE_EFFECT)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCondition(c90885155.immcon)
	-- 设置免疫效果的过滤条件为：不受原本等级或阶级低于自身等级的怪兽发动的效果影响。
	e7:SetValue(aux.qlifilter)
	c:RegisterEffect(e7)
	-- ④：把「机壳」怪兽解放表侧表示上级召唤成功的场合，这张卡在同1次的战斗阶段中可以作2次攻击，向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e8:SetCode(EVENT_SUMMON_SUCCESS)
	e8:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e8:SetCondition(c90885155.effcon)
	e8:SetOperation(c90885155.effop)
	c:RegisterEffect(e8)
	-- 把「机壳」怪兽解放表侧表示上级召唤成功的场合
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_SINGLE)
	e9:SetCode(EFFECT_MATERIAL_CHECK)
	e9:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e9:SetValue(c90885155.valcheck)
	e9:SetLabelObject(e8)
	c:RegisterEffect(e9)
end
-- 限制只能特殊召唤「机壳」怪兽的过滤函数。
function c90885155.splimit(e,c)
	return not c:IsSetCard(0xaa)
end
-- 妥协召唤（不用解放作召唤）的条件判断函数。
function c90885155.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判断是否满足不用解放进行召唤的条件（等级5以上且怪兽区域有空位）。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 判断这张卡是否在没有解放怪兽的情况下被召唤（祭品数量为0）。
function c90885155.lvcon(e)
	return e:GetHandler():GetMaterialCount()==0
end
-- 不用解放作召唤成功时，注册使其等级变成4星、原本攻击力变成1800的效果。
function c90885155.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 不用解放作召唤的这张卡的等级变成4星
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c90885155.lvcon)
	e1:SetValue(4)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
	-- 不用解放作召唤的这张卡的原本攻击力变成1800
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_BASE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c90885155.lvcon)
	e2:SetValue(1800)
	e2:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e2)
end
-- 特殊召唤成功时，注册使其等级变成4星、原本攻击力变成1800的效果。
function c90885155.lvop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 特殊召唤的这张卡的等级变成4星
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(4)
	e1:SetReset(RESET_EVENT+0x7f0000)
	c:RegisterEffect(e1)
	-- 特殊召唤的这张卡的原本攻击力变成1800
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_BASE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1800)
	e2:SetReset(RESET_EVENT+0x7f0000)
	c:RegisterEffect(e2)
end
-- 免疫效果的启用条件：这张卡是通常召唤的。
function c90885155.immcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL)
end
-- 检查是否满足上级召唤成功且解放了「机壳」怪兽的条件。
function c90885155.effcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE) and e:GetLabel()==1
end
-- 为上级召唤成功的这张卡注册追加攻击和贯穿伤害的效果。
function c90885155.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这张卡在同1次的战斗阶段中可以作2次攻击
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	-- 向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 检查解放的祭品中是否存在「机壳」怪兽，并设置对应的Label标记。
function c90885155.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsSetCard,1,nil,0xaa) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
