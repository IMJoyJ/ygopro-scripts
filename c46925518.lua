--ゴーストリックの人形
-- 效果：
-- 自己场上有「鬼计」怪兽存在的场合才能让这张卡表侧表示召唤。
-- ①：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
-- ②：这张卡反转的场合发动。这个回合的结束阶段，场上的表侧表示怪兽全部变成里侧守备表示。那之后，可以把持有这个效果变成里侧守备表示的怪兽数量以下的等级的1只「鬼计」怪兽从卡组里侧守备表示特殊召唤。
function c46925518.initial_effect(c)
	-- 自己场上有「鬼计」怪兽存在的场合不能让这张卡表侧表示召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c46925518.sumcon)
	c:RegisterEffect(e1)
	-- 自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46925518,0))  --"变成里侧表示"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c46925518.postg)
	e2:SetOperation(c46925518.posop)
	c:RegisterEffect(e2)
	-- 这张卡反转的场合发动。这个回合的结束阶段，场上的表侧表示怪兽全部变成里侧守备表示。那之后，可以把持有这个效果变成里侧守备表示的怪兽数量以下的等级的1只「鬼计」怪兽从卡组里侧守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_FLIP)
	e3:SetOperation(c46925518.fdop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否有表侧表示的「鬼计」怪兽
function c46925518.sfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8d)
end
-- 判断自己场上有「鬼计」怪兽存在时，该卡不能被召唤
function c46925518.sumcon(e)
	-- 若自己场上没有「鬼计」怪兽，则该卡可以被召唤
	return not Duel.IsExistingMatchingCard(c46925518.sfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 设置效果目标，检查该卡是否能变成里侧守备表示且未在本回合使用过此效果
function c46925518.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(46925518)==0 end
	c:RegisterFlagEffect(46925518,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置操作信息，表明该效果会将目标怪兽变为里侧守备表示
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 执行效果操作，将该卡变为里侧守备表示
function c46925518.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将目标怪兽变为里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 创建一个在结束阶段触发的效果，用于处理反转后的效果
function c46925518.fdop(e,tp,eg,ep,ev,re,r,rp)
	-- 注册该效果到玩家环境中
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c46925518.condition)
	e1:SetOperation(c46925518.operation)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 过滤函数，用于判断场上是否有表侧表示且可变为里侧表示的怪兽
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数，用于筛选满足条件的「鬼计」怪兽
function c46925518.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 判断是否满足发动条件，即自己场上有表侧表示的怪兽
function c46925518.spfilter(c,e,tp,lv)
	return c:IsSetCard(0x8d) and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 判断是否满足发动条件，即自己场上有表侧表示的怪兽
function c46925518.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 若场上存在表侧表示的怪兽，则满足发动条件
	return Duel.IsExistingMatchingCard(c46925518.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 获取所有可变为里侧守备表示的场上怪兽，并将其全部变为里侧守备表示
function c46925518.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取所有可变为里侧守备表示的场上怪兽
	local g=Duel.GetMatchingGroup(c46925518.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return end
	-- 将这些怪兽变为里侧守备表示，并记录变化数量
	local ct=Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	-- 若自己场上的怪兽区域不足，则不执行后续操作
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 从卡组中筛选出等级不超过已变更为里侧守备表示的怪兽数量的「鬼计」怪兽
	local sg=Duel.GetMatchingGroup(c46925518.spfilter,tp,LOCATION_DECK,0,nil,e,tp,ct)
	-- 若存在符合条件的怪兽且玩家选择发动效果，则进行特殊召唤
	if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(46925518,1)) then  --"是否要把「鬼计」怪兽从卡组里侧守备表示特殊召唤？"
		-- 中断当前连锁处理，使之后的效果视为不同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		-- 将选定的怪兽以里侧守备表示从卡组特殊召唤到场上
		if Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)~=0 then
			-- 向对方确认特殊召唤的怪兽
			Duel.ConfirmCards(1-tp,tg)
		end
	end
end
