--ゴーストリックの人形
-- 效果：
-- 自己场上有「鬼计」怪兽存在的场合才能让这张卡表侧表示召唤。
-- ①：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
-- ②：这张卡反转的场合发动。这个回合的结束阶段，场上的表侧表示怪兽全部变成里侧守备表示。那之后，可以把持有这个效果变成里侧守备表示的怪兽数量以下的等级的1只「鬼计」怪兽从卡组里侧守备表示特殊召唤。
function c46925518.initial_effect(c)
	-- 自己场上有「鬼计」怪兽存在的场合才能让这张卡表侧表示召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c46925518.sumcon)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46925518,0))  --"变成里侧表示"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c46925518.postg)
	e2:SetOperation(c46925518.posop)
	c:RegisterEffect(e2)
	-- ②：这张卡反转的场合发动。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_FLIP)
	e3:SetOperation(c46925518.fdop)
	c:RegisterEffect(e3)
end
-- 筛选条件：检查卡片是否为表侧表示的「鬼计」怪兽
function c46925518.sfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8d)
end
-- 不能召唤限制条件：当己方怪兽区不存在表侧表示的「鬼计」怪兽时，禁止表侧表示通常召唤这张卡
function c46925518.sumcon(e)
	-- 检查己方怪兽区是否不存在表侧表示的「鬼计」怪兽
	return not Duel.IsExistingMatchingCard(c46925518.sfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- ①效果的发动检测、次数标记与连锁信息设置：确认自身可转为里侧且本回合尚未发动过该效果，注册1回合1次标记并登记改变表示形式信息
function c46925518.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(46925518)==0 end
	c:RegisterFlagEffect(46925518,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 登记连锁的改变表示形式操作信息，预计改变这张卡的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- ①效果的处理流程：确认这张卡仍在场上且表侧表示后，将其变为里侧守备表示
function c46925518.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将这张卡变为里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- ②效果的处理流程：注册一个将在本回合结束阶段触发的延迟效果
function c46925518.fdop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合的结束阶段，场上的表侧表示怪兽全部变成里侧守备表示。那之后，可以把持有这个效果变成里侧守备表示的怪兽数量以下的等级的1只「鬼计」怪兽从卡组里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c46925518.condition)
	e1:SetOperation(c46925518.operation)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为己方注册持续至回合结束阶段的结束阶段触发效果
	Duel.RegisterEffect(e1,tp)
end
-- 筛选条件：检查场上怪兽是否为表侧表示且可以变成里侧表示
function c46925518.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 筛选条件：检查卡片是否为等级在指定数量以下且能以里侧守备表示特殊召唤的「鬼计」怪兽
function c46925518.spfilter(c,e,tp,lv)
	return c:IsSetCard(0x8d) and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 结束阶段效果的触发条件：确认场上存在至少1只表侧表示且可变为里侧的怪兽
function c46925518.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方怪兽区是否存在至少1只表侧表示且能转为里侧的怪兽
	return Duel.IsExistingMatchingCard(c46925518.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 结束阶段效果的处理流程：将场上所有表侧怪兽转为里侧守备表示并统计实际转换数量，之后在己方有空位时可选从卡组里侧守备表示特召1只等级在该数量以下的「鬼计」怪兽
function c46925518.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上全部表侧表示且可变成里侧的怪兽组
	local g=Duel.GetMatchingGroup(c46925518.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return end
	-- 将所选表侧怪兽全部变成里侧守备表示，并记录实际变更的数量
	local ct=Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	-- 检查己方主要怪兽区是否有空位，若无空位则结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取己方卡组中所有等级在变更数量以下且可里侧守备表示特殊召唤的「鬼计」怪兽组
	local sg=Duel.GetMatchingGroup(c46925518.spfilter,tp,LOCATION_DECK,0,nil,e,tp,ct)
	-- 若卡组存在满足条件的「鬼计」怪兽，询问己方是否执行特殊召唤
	if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(46925518,1)) then  --"是否要把「鬼计」怪兽从卡组里侧守备表示特殊召唤？"
		-- 中断效果处理，使后续的特殊召唤与前面的变为里侧守备表示视为不同时处理
		Duel.BreakEffect()
		-- 向己方提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		-- 将所选「鬼计」怪兽以里侧守备表示特殊召唤到己方场上，并判断是否成功
		if Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)~=0 then
			-- 向对方展示里侧特殊召唤的「鬼计」怪兽以确认卡名合法
			Duel.ConfirmCards(1-tp,tg)
		end
	end
end
