--サイコ・ギガサイバー
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：对方场上的魔法·陷阱卡数量比自己场上的魔法·陷阱卡多的场合，这张卡可以从手卡特殊召唤。
-- ②：自己场上有「人造人-念力震慑者」存在，这张卡向对方的效果怪兽攻击宣言时，把这张卡解放才能发动。那只对方怪兽当作永续陷阱卡使用在对方的魔法与陷阱区域表侧表示放置。
function c91870448.initial_effect(c)
	-- 注册卡片记载了「人造人-念力震慑者」的卡片密码。
	aux.AddCodeList(c,77585513)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：对方场上的魔法·陷阱卡数量比自己场上的魔法·陷阱卡多的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,91870448)
	e1:SetCondition(c91870448.spcon)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己场上有「人造人-念力震慑者」存在，这张卡向对方的效果怪兽攻击宣言时，把这张卡解放才能发动。那只对方怪兽当作永续陷阱卡使用在对方的魔法与陷阱区域表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(91870448,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,91870449)
	e2:SetCondition(c91870448.plcon)
	e2:SetCost(c91870448.plcost)
	e2:SetOperation(c91870448.plop)
	c:RegisterEffect(e2)
end
-- 特殊召唤规则的条件判断函数。
function c91870448.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查对方场上的魔法·陷阱卡数量是否比自己场上的魔法·陷阱卡多。
	return (Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_ONFIELD,0,nil,TYPE_SPELL+TYPE_TRAP)<Duel.GetMatchingGroupCount(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP))
		-- 检查自己场上是否有可用的怪兽区域。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
-- 过滤条件：表侧表示的「人造人-念力震慑者」。
function c91870448.confilter(c)
	return c:IsFaceup() and c:IsCode(77585513)
end
-- 效果②的发动条件：自己场上有「人造人-念力震慑者」存在，且攻击对象是对方场上表侧表示的效果怪兽。
function c91870448.plcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「人造人-念力震慑者」，若不存在则不能发动。
	if not Duel.IsExistingMatchingCard(c91870448.confilter,tp,LOCATION_ONFIELD,0,1,nil) then return false end
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsControler(1-tp) and bc:IsFaceup() and bc:IsType(TYPE_EFFECT)
end
-- 效果②的代价处理函数：把这张卡解放。
function c91870448.plcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	-- 解放自身作为发动代价。
	Duel.Release(c,REASON_COST)
end
-- 效果②的发动准备函数：检查对方的魔法与陷阱区域是否有空位。
function c91870448.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方的魔法与陷阱区域是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_SZONE,tp)>0 end
end
-- 效果②的效果处理函数：将对方怪兽移动到对方的魔法与陷阱区域表侧表示放置，并当作永续陷阱卡使用。
function c91870448.plop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc:IsRelateToBattle() and bc:IsControler(1-tp) and not bc:IsImmuneToEffect(e) then
		-- 将攻击目标的怪兽移动到对方的魔法与陷阱区域表侧表示放置。
		if Duel.MoveToField(bc,tp,1-tp,LOCATION_SZONE,POS_FACEUP,true) then
			-- 那只对方怪兽当作永续陷阱卡使用
			local e1=Effect.CreateEffect(c)
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
			bc:RegisterEffect(e1)
		end
	end
end
