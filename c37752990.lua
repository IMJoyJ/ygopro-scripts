--ダイナミスト・ケラトプス
-- 效果：
-- ←3 【灵摆】 3→
-- ①：这张卡以外的自己场上的「雾动机龙」卡被战斗或者对方的效果破坏的场合，可以作为代替把这张卡破坏。
-- 【怪兽效果】
-- ①：自己场上的怪兽只有「雾动机龙·角龙」以外的「雾动机龙」怪兽的场合，这张卡可以从手卡特殊召唤。
function c37752990.initial_effect(c)
	-- 为这张卡注册灵摆怪兽的基础属性，使其可以在灵摆区发动、进行灵摆召唤并作为灵摆卡使用。
	aux.EnablePendulumAttribute(c)
	-- ①：这张卡以外的自己场上的「雾动机龙」卡被战斗或者对方的效果破坏的场合，可以作为代替把这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTarget(c37752990.reptg)
	e2:SetValue(c37752990.repval)
	e2:SetOperation(c37752990.repop)
	c:RegisterEffect(e2)
	-- ①：自己场上的怪兽只有「雾动机龙·角龙」以外的「雾动机龙」怪兽的场合，这张卡可以从手卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(c37752990.spcon)
	c:RegisterEffect(e3)
end
-- 判定某张卡是否能被这张灵摆卡代替破坏：需是表侧表示、由这张卡控制、位于场上、属于「雾动机龙」字段，且破坏原因是战斗破坏或对方玩家的效果破坏，并且不是已经被代替破坏的卡。
function c37752990.filter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsOnField() and c:IsSetCard(0xd8)
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的发动条件判定：确认本回合被破坏的怪兽中有满足条件的「雾动机龙」卡，同时这张灵摆卡自身可被效果破坏且尚未被预定破坏。
function c37752990.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(c37752990.filter,1,c,tp)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	-- 询问这张卡的控制者是否发动代替破坏效果（提示文字使用编号96的文本）。
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 代替破坏效果的Value函数：逐个判定准备破坏的卡是否满足代破条件，满足则返回true，表示由这张灵摆卡代替其破坏。
function c37752990.repval(e,c)
	return c37752990.filter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果处理时执行的实际操作：破坏这张灵摆卡，以代替原对象的破坏。
function c37752990.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将这张灵摆卡以效果破坏并附加“代替破坏”原因，从而替代原本要被破坏的「雾动机龙」卡。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
-- 特殊召唤条件检查用的排除过滤：若场上存在里侧表示怪兽、「雾动机龙·角龙」自身或非「雾动机龙」怪兽，则返回true，表示不满足“只有其他雾动机龙怪兽”的条件。
function c37752990.cfilter(c)
	return c:IsFacedown() or c:IsCode(37752990) or not c:IsSetCard(0xd8)
end
-- 手牌特殊召唤的规则条件：自己场上有怪兽且主要怪兽区有空位，并且自己场上不存在里侧表示怪兽、不存在同名「雾动机龙·角龙」、不存在非「雾动机龙」怪兽。
function c37752990.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查这张卡的控制者的主要怪兽区是否有可用的空位，用于放置特殊召唤的怪兽。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查这张卡的控制者场上是否有怪兽存在，满足“自己场上有怪兽”的特殊召唤前提。
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)>0
		-- 确认自己场上不存在任何会使特殊召唤条件不成立的卡：没有里侧表示怪兽、没有同名「雾动机龙·角龙」、没有非「雾动机龙」怪兽。
		and not Duel.IsExistingMatchingCard(c37752990.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
