--トゥーン・バスター・ブレイダー
-- 效果：
-- ①：这张卡的攻击力上升对方的场上·墓地的龙族怪兽数量×500。
-- ②：这张卡在召唤·反转召唤·特殊召唤的回合不能攻击。
-- ③：自己场上有「卡通世界」存在，对方场上没有卡通怪兽存在的场合，这张卡可以直接攻击。
function c61190918.initial_effect(c)
	-- 记录这张卡的效果中记载了「卡通世界」（卡片密码：15259703）的卡片信息
	aux.AddCodeList(c,15259703)
	-- ②：这张卡在召唤·反转召唤·特殊召唤的回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c61190918.atklimit)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ①：这张卡的攻击力上升对方的场上·墓地的龙族怪兽数量×500。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(c61190918.val)
	c:RegisterEffect(e4)
	-- ③：自己场上有「卡通世界」存在，对方场上没有卡通怪兽存在的场合，这张卡可以直接攻击。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_DIRECT_ATTACK)
	e5:SetCondition(c61190918.dircon)
	c:RegisterEffect(e5)
end
-- 召唤、特殊召唤、反转召唤成功时执行的操作，给自身施加在该回合内不能攻击的效果
function c61190918.atklimit(e,tp,eg,ep,ev,re,r,rp)
	-- 不能攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示的「卡通世界」
function c61190918.dirfilter1(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 过滤条件：场上表侧表示的卡通怪兽
function c61190918.dirfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
-- 判断直接攻击的条件是否满足：自己场上有「卡通世界」存在，且对方场上没有卡通怪兽
function c61190918.dircon(e)
	-- 检查自己场上是否存在表侧表示的「卡通世界」
	return Duel.IsExistingMatchingCard(c61190918.dirfilter1,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
		-- 检查对方场上是否不存在表侧表示的卡通怪兽
		and not Duel.IsExistingMatchingCard(c61190918.dirfilter2,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end
-- 计算攻击力上升数值的函数，返回符合条件的怪兽数量×500
function c61190918.val(e,c)
	-- 计算对方场上和墓地的符合条件的龙族怪兽数量并乘以500
	return Duel.GetMatchingGroupCount(c61190918.filter,c:GetControler(),0,LOCATION_GRAVE+LOCATION_MZONE,nil)*500
end
-- 过滤条件：龙族怪兽，且在墓地中或在场上表侧表示
function c61190918.filter(c)
	return c:IsRace(RACE_DRAGON) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
