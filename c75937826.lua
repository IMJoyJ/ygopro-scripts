--巨大戦艦 ビッグ・コアMk－Ⅱ
-- 效果：
-- 这张卡特殊召唤成功时，给这张卡放置3个指示物。这张卡不会被战斗破坏。这张卡进行战斗的场合，伤害步骤结束时把这张卡放置的1个指示物取除。这张卡没有指示物的状态进行战斗的场合，伤害步骤结束时这张卡破坏。自己场上没有怪兽存在的场合，这张卡可以不用解放作召唤。
function c75937826.initial_effect(c)
	c:EnableCounterPermit(0x1f)
	-- 这张卡特殊召唤成功时，给这张卡放置3个指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75937826,0))  --"放置指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c75937826.addct)
	e1:SetOperation(c75937826.addc)
	c:RegisterEffect(e1)
	-- 这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 注册巨大战舰系列怪兽通用的战斗后移除指示物或破坏自身的效果
	aux.EnableBESRemove(c)
	-- 自己场上没有怪兽存在的场合，这张卡可以不用解放作召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(75937826,3))  --"不解放作召唤"
	e5:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_SUMMON_PROC)
	e5:SetCondition(c75937826.ntcon)
	c:RegisterEffect(e5)
end
-- 特殊召唤成功时放置指示物效果的Target函数，确认效果发动并设置指示物相关的操作信息
function c75937826.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表明该效果会放置3个0x1f类型的指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,3,0,0x1f)
end
-- 特殊召唤成功时放置指示物效果的Operation函数，若此卡仍在场上，则为其放置3个指示物
function c75937826.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1f,3)
	end
end
-- 不用解放作召唤的条件判定函数，判断是否满足不解放召唤的规则、等级限制以及自己场上没有怪兽的条件
function c75937826.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判定不需要解放、卡片等级在5星以上，且当前控制者的怪兽区域有可用空位
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 判定自己场上的怪兽数量为0
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
end
