--無孔砲塔－ディセイブラスター
-- 效果：
-- ←5 【灵摆】 5→
-- ①：只要这张卡在灵摆区域存在，和这张卡相同纵列发动的魔法·陷阱·怪兽的效果无效化。
-- 【怪兽效果】
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：有着没有卡存在的纵列的场合，这张卡可以从手卡往那个纵列的自己场上特殊召唤。
-- ②：只要这张卡在怪兽区域存在，和这张卡相同纵列发动的魔法·陷阱·怪兽的效果无效化。
-- ③：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数。
function s.initial_effect(c)
	-- 注册灵摆怪兽的灵摆召唤及灵摆卡发动等基本属性。
	aux.EnablePendulumAttribute(c)
	-- ①：只要这张卡在灵摆区域存在，和这张卡相同纵列发动的魔法·陷阱·怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(s.discon)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：有着没有卡存在的纵列的场合，这张卡可以从手卡往那个纵列的自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.hspcon)
	e2:SetValue(s.hspval)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，和这张卡相同纵列发动的魔法·陷阱·怪兽的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.discon)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
	-- ③：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))  --"放置到灵摆区域"
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(s.pencon)
	e4:SetTarget(s.pentg)
	e4:SetOperation(s.penop)
	c:RegisterEffect(e4)
end
-- 相同纵列效果无效化效果的条件判断函数。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前处理的连锁的发动者、发动位置以及所在的区域序号。
	local op,loc,seq2=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE)
	if loc&LOCATION_SZONE~=0 and seq2>4 then return false end
	-- 获取这张卡在主要怪兽区域的规范化序号（处理额外怪兽区的情况）。
	local seq1=aux.MZoneSequence(c:GetSequence())
	-- 将发动效果的卡片所在的区域序号进行规范化处理。
	seq2=aux.MZoneSequence(seq2)
	return bit.band(loc,LOCATION_ONFIELD)~=0
		and (op==1-tp and seq1==4-seq2 or op==tp and seq1==seq2)
end
-- 相同纵列效果无效化效果的操作函数。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家展示该卡片发动的动画提示。
	Duel.Hint(HINT_CARD,0,id)
	-- 使该连锁的效果无效。
	Duel.NegateEffect(ev)
end
-- 计算并返回场上没有任何卡存在的纵列所对应的怪兽区域掩码。
function s.hspzone(tp)
	local zone=0
	-- 获取双方场上的所有卡片。
	local lg=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	-- 遍历场上的每一张卡片。
	for tc in aux.Next(lg) do
		zone=bit.bor(zone,tc:GetColumnZone(LOCATION_MZONE,tp))
	end
	return bit.bnot(zone)
end
-- 自身规则特殊召唤效果的条件判断函数。
function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local zone=s.hspzone(tp)
	-- 检查在没有任何卡存在的纵列中，自己场上是否有可用的怪兽区域。
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
end
-- 自身规则特殊召唤效果的数值函数，用于指定可以特殊召唤的区域。
function s.hspval(e,c)
	local tp=c:GetControler()
	local zone=s.hspzone(tp)
	return 0,zone
end
-- 被破坏时在灵摆区域放置效果的条件判断函数（须在怪兽区域被破坏且表侧表示）。
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 被破坏时在灵摆区域放置效果的靶标判断函数。
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的灵摆区域是否有空位。
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 被破坏时在灵摆区域放置效果的操作函数。
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡表侧表示移动到自己的灵摆区域。
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
