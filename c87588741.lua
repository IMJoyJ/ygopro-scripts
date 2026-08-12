--クリフォート・アクセス
-- 效果：
-- ←9 【灵摆】 9→
-- ①：自己不是「机壳」怪兽不能特殊召唤。这个效果不会被无效化。
-- ②：对方场上的怪兽的攻击力下降300。
-- 【怪兽效果】
-- ①：这张卡可以不用解放作召唤。
-- ②：特殊召唤或者不用解放作召唤的这张卡的等级变成4星，原本攻击力变成1800。
-- ③：通常召唤的这张卡不受原本的等级或者阶级比这张卡的等级低的怪兽发动的效果影响。
-- ④：把「机壳」怪兽解放对这张卡的上级召唤成功时才能发动。对方墓地的怪兽数量比自己墓地的怪兽多的场合，自己回复那个相差×300基本分，给与对方那个数值的伤害。
function c87588741.initial_effect(c)
	-- 注册灵摆怪兽的灵摆召唤和灵摆卡的发动效果
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是「机壳」怪兽不能特殊召唤。这个效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c87588741.splimit)
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
	e4:SetDescription(aux.Stringid(87588741,0))  --"不用解放作召唤"
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SUMMON_PROC)
	e4:SetCondition(c87588741.ntcon)
	c:RegisterEffect(e4)
	-- ②：特殊召唤或者不用解放作召唤的这张卡的等级变成4星，原本攻击力变成1800。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_SUMMON_COST)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetOperation(c87588741.lvop)
	c:RegisterEffect(e5)
	-- ②：特殊召唤或者不用解放作召唤的这张卡的等级变成4星，原本攻击力变成1800。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_SPSUMMON_COST)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetOperation(c87588741.lvop2)
	c:RegisterEffect(e6)
	-- ③：通常召唤的这张卡不受原本的等级或者阶级比这张卡的等级低的怪兽发动的效果影响。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_IMMUNE_EFFECT)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCondition(c87588741.immcon)
	-- 设置免疫效果的过滤条件为不受原本等级或阶级低于这张卡等级的怪兽发动的效果影响
	e7:SetValue(aux.qlifilter)
	c:RegisterEffect(e7)
	-- ④：把「机壳」怪兽解放对这张卡的上级召唤成功时才能发动。对方墓地的怪兽数量比自己墓地的怪兽多的场合，自己回复那个相差×300基本分，给与对方那个数值的伤害。
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(87588741,1))
	e8:SetCategory(CATEGORY_DAMAGE+CATEGORY_RECOVER)
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e8:SetCode(EVENT_SUMMON_SUCCESS)
	e8:SetCondition(c87588741.damcon)
	e8:SetTarget(c87588741.damtg)
	e8:SetOperation(c87588741.damop)
	c:RegisterEffect(e8)
	-- ④：把「机壳」怪兽解放对这张卡的上级召唤成功时才能发动。对方墓地的怪兽数量比自己墓地的怪兽多的场合，自己回复那个相差×300基本分，给与对方那个数值的伤害。
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_SINGLE)
	e9:SetCode(EFFECT_MATERIAL_CHECK)
	e9:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e9:SetValue(c87588741.valcheck)
	e9:SetLabelObject(e8)
	c:RegisterEffect(e9)
end
-- 限制只能特殊召唤「机壳」怪兽
function c87588741.splimit(e,c)
	return not c:IsSetCard(0xaa)
end
-- 判定是否满足不用解放作召唤的条件
function c87588741.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判定怪兽原本等级在5星以上、不需要解放且己方场上有可用怪兽区域
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 判定这张卡在召唤时是否没有使用解放素材
function c87588741.lvcon(e)
	return e:GetHandler():GetMaterialCount()==0
end
-- 注册不用解放作召唤成功时等级变成4星、原本攻击力变成1800的效果
function c87588741.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ②：特殊召唤或者不用解放作召唤的这张卡的等级变成4星，原本攻击力变成1800。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c87588741.lvcon)
	e1:SetValue(4)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
	-- ②：特殊召唤或者不用解放作召唤的这张卡的等级变成4星，原本攻击力变成1800。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_BASE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c87588741.lvcon)
	e2:SetValue(1800)
	e2:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e2)
end
-- 注册特殊召唤成功时等级变成4星、原本攻击力变成1800的效果
function c87588741.lvop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ②：特殊召唤或者不用解放作召唤的这张卡的等级变成4星，原本攻击力变成1800。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(4)
	e1:SetReset(RESET_EVENT+0x7f0000)
	c:RegisterEffect(e1)
	-- ②：特殊召唤或者不用解放作召唤的这张卡的等级变成4星，原本攻击力变成1800。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_BASE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1800)
	e2:SetReset(RESET_EVENT+0x7f0000)
	c:RegisterEffect(e2)
end
-- 判定这张卡是否为通常召唤
function c87588741.immcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL)
end
-- 判定是否为把「机壳」怪兽解放进行的上级召唤
function c87588741.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE) and e:GetLabel()==1
end
-- 判定对方墓地怪兽数量是否比自己墓地多，并设置回复和伤害的操作信息
function c87588741.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己墓地的怪兽数量
	local ct1=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	-- 获取对方墓地的怪兽数量
	local ct2=Duel.GetMatchingGroupCount(Card.IsType,tp,0,LOCATION_GRAVE,nil,TYPE_MONSTER)
	local ct=ct2-ct1
	if chk==0 then return ct>0 end
	-- 设置回复基本分的操作信息
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ct*300)
	-- 设置给与对方伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*300)
end
-- 执行回复相差数量×300的基本分，并给与对方相同数值伤害的效果处理
function c87588741.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己墓地的怪兽数量
	local ct1=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	-- 获取对方墓地的怪兽数量
	local ct2=Duel.GetMatchingGroupCount(Card.IsType,tp,0,LOCATION_GRAVE,nil,TYPE_MONSTER)
	local ct=ct2-ct1
	if ct>0 then
		-- 自己回复相差数量×300的基本分
		local val=Duel.Recover(tp,ct*300,REASON_EFFECT)
		-- 给与对方与实际回复数值相同的伤害
		Duel.Damage(1-tp,val,REASON_EFFECT)
	end
end
-- 检查解放的素材中是否存在「机壳」怪兽，并为触发效果设置标记
function c87588741.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsSetCard,1,nil,0xaa) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
