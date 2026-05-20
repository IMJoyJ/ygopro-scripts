--剣聖の影霊衣－セフィラセイバー
-- 效果：
-- ←1 【灵摆】 1→
-- ①：自己不是「影灵衣」怪兽以及「神数」怪兽不能灵摆召唤。这个效果不会被无效化。
-- 【怪兽效果】
-- 「剑圣之影灵衣-神数剑士」的怪兽效果1回合只能使用1次。
-- ①：把自己的手卡·场上的这张卡解放才能发动。等级合计直到变成和仪式召唤的怪兽相同为止，把自己的手卡·场上的怪兽解放，从手卡把1只「影灵衣」仪式怪兽仪式召唤。
function c84388461.initial_effect(c)
	-- 为卡片注册灵摆怪兽的基本属性（包括灵摆召唤和灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是「影灵衣」怪兽以及「神数」怪兽不能灵摆召唤。这个效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c84388461.splimit)
	c:RegisterEffect(e2)
	-- 注册一个仪式召唤效果，要求解放的素材等级合计与仪式怪兽等级相同
	local e3=aux.AddRitualProcEqual2(c,c84388461.filter,nil,nil,c84388461.mfilter,true)
	e3:SetDescription(aux.Stringid(84388461,1))  --"仪式召唤"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCode(0)
	e3:SetCountLimit(1,84388461)
	e3:SetRange(LOCATION_MZONE+LOCATION_HAND)
	e3:SetCost(c84388461.cost)
	c:RegisterEffect(e3)
end
-- 限制灵摆召唤的怪兽必须是「影灵衣」怪兽或「神数」怪兽
function c84388461.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(0xb4,0xc4) then return false end
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 过滤「影灵衣」怪兽，用于确定可以仪式召唤的对象
function c84388461.filter(c)
	return c:IsSetCard(0xb4)
end
-- 过滤仪式素材，防止将作为发动代价已经解放的自身再次选为素材
function c84388461.mfilter(c,e,tp,chk)
	return not chk or c~=e:GetHandler()
end
-- 仪式召唤效果的发动代价：检查并解放手卡或场上的这张卡
function c84388461.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放作为发动代价的这张卡
	Duel.Release(e:GetHandler(),REASON_COST)
end
