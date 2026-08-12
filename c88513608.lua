--捨て身の宝札
-- 效果：
-- 自己场上表侧攻击表示存在的怪兽2只以上的攻击力合计比对方场上表侧表示存在的攻击力最低的怪兽低的场合，从自己卡组抽2张卡。这张卡发动的回合，自己不能把怪兽召唤·反转召唤·特殊召唤，也不能把表示形式变更。
function c88513608.initial_effect(c)
	-- 自己场上表侧攻击表示存在的怪兽2只以上的攻击力合计比对方场上表侧表示存在的攻击力最低的怪兽低的场合，从自己卡组抽2张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c88513608.condition)
	e1:SetCost(c88513608.cost)
	e1:SetTarget(c88513608.target)
	e1:SetOperation(c88513608.activate)
	c:RegisterEffect(e1)
	if not c88513608.global_check then
		c88513608.global_check=true
		-- 这张卡发动的回合，自己不能把怪兽召唤·反转召唤·特殊召唤，也不能把表示形式变更。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHANGE_POS)
		ge1:SetOperation(c88513608.poscheck)
		-- 注册全局环境下的表示形式变更检测效果
		Duel.RegisterEffect(ge1,0)
	end
end
-- 表示形式变更时的检测函数，若非效果导致的变更，则为玩家注册已变更表示形式的标记
function c88513608.poscheck(e,tp,eg,ep,ev,re,r,rp)
	if re==nil then
		-- 为玩家注册表示形式已变更的标记，持续到回合结束
		Duel.RegisterFlagEffect(rp,88513608,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 检查是否满足自己场上表侧攻击表示怪兽2只以上且攻击力合计小于对方场上表侧表示攻击力最低怪兽的条件
function c88513608.check(tp)
	-- 获取自己场上所有表侧攻击表示的怪兽
	local sg=Duel.GetMatchingGroup(Card.IsPosition,tp,LOCATION_MZONE,0,nil,POS_FACEUP_ATTACK)
	if sg:GetCount()<2 then return false end
	-- 获取对方场上所有表侧表示的怪兽
	local og=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if og:GetCount()==0 then return false end
	local at1=sg:GetSum(Card.GetAttack)
	local tg,at2=og:GetMinGroup(Card.GetAttack)
	return at1<at2
end
-- 发动条件：检查当前是否满足攻击力对比条件
function c88513608.condition(e,tp,eg,ep,ev,re,r,rp)
	return c88513608.check(tp)
end
-- 发动代价：检查本回合是否进行过召唤、反转召唤、特殊召唤以及表示形式变更，并适用后续的禁止召唤和变更表示形式的限制
function c88513608.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查本回合自己是否进行过怪兽的通常召唤
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SUMMON)==0
		-- 检查本回合自己是否进行过怪兽的反转召唤
		and Duel.GetActivityCount(tp,ACTIVITY_FLIPSUMMON)==0
		-- 检查本回合自己是否进行过怪兽的特殊召唤
		and Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0
		-- 检查本回合自己是否进行过怪兽的表示形式变更
		and Duel.GetFlagEffect(tp,88513608)==0 end
	-- 这张卡发动的回合，自己不能把怪兽召唤·反转召唤·特殊召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 给玩家注册本回合不能特殊召唤怪兽的效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	-- 给玩家注册本回合不能召唤怪兽的效果
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	-- 给玩家注册本回合不能反转召唤怪兽的效果
	Duel.RegisterEffect(e3,tp)
	-- 也不能把表示形式变更。
	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_OATH)
	e4:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e4:SetReset(RESET_PHASE+PHASE_END)
	e4:SetTargetRange(LOCATION_MZONE,0)
	-- 给玩家注册本回合不能变更怪兽表示形式的效果
	Duel.RegisterEffect(e4,tp)
end
-- 效果的目标：检查是否能抽卡，并设置抽卡玩家和抽卡数量
function c88513608.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查自己是否能够从卡组抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置当前连锁的效果处理对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的效果处理参数为2（抽卡数量）
	Duel.SetTargetParam(2)
	-- 设置当前连锁的操作信息为：自己从卡组抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果的处理：再次检查条件，若满足则执行抽卡
function c88513608.activate(e,tp,eg,ep,ev,re,r,rp)
	if not c88513608.check(tp) then return end
	-- 获取当前连锁设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
