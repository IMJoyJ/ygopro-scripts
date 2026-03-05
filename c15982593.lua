--騎士皇レガーティア
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。自己抽1张。那之后，可以把对方场上1只攻击力最高的怪兽破坏。
-- ②：攻击力2000以下的自己怪兽不会被战斗破坏。
-- ③：自己·对方的结束阶段才能发动。从自己的手卡·墓地把同调怪兽以外的1只「百夫长骑士」怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
local s,id,o=GetID()
-- 初始化效果函数，设置同调召唤手续、特殊召唤限制和三个效果
function s.initial_effect(c)
	-- 为该卡添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合才能发动。自己抽1张。那之后，可以把对方场上1只攻击力最高的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.ddtg)
	e1:SetOperation(s.ddop)
	c:RegisterEffect(e1)
	-- ②：攻击力2000以下的自己怪兽不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.bdtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：自己·对方的结束阶段才能发动。从自己的手卡·墓地把同调怪兽以外的1只「百夫长骑士」怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
-- 效果处理函数，设置抽卡目标和操作信息
function s.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置连锁的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁的目标参数为1
	Duel.SetTargetParam(1)
	-- 设置操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理函数，执行抽卡并询问是否破坏对方攻击力最高的怪兽
function s.ddop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 检查玩家是否成功抽卡且对方场上存在表侧表示的怪兽
	if Duel.Draw(p,d,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
		-- 询问玩家是否破坏对方攻击力最高的怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把对方攻击力最高的怪兽破坏？"
		-- 中断当前效果处理，使后续效果视为不同时处理
		Duel.BreakEffect()
		-- 获取对方场上所有表侧表示的怪兽
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		local tg=g:GetMaxGroup(Card.GetAttack)
		if #tg>1 then
			-- 提示玩家选择要破坏的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=tg:Select(tp,1,1,nil)
			-- 显示选中的怪兽被选为对象的动画效果
			Duel.HintSelection(sg)
			-- 破坏选中的怪兽
			Duel.Destroy(sg,REASON_EFFECT)
		-- 直接破坏攻击力最高的怪兽
		else Duel.Destroy(tg,REASON_EFFECT) end
	end
end
-- 判断是否为攻击力2000以下的表侧表示怪兽
function s.bdtg(e,c)
	return c:IsFaceup() and c:IsAttackBelow(2000)
end
-- 过滤满足条件的「百夫长骑士」怪兽
function s.filter(c)
	return c:IsSetCard(0x1a2) and c:IsType(TYPE_MONSTER) and not c:IsForbidden() and not c:IsType(TYPE_SYNCHRO)
end
-- 设置效果处理函数，检查是否有符合条件的怪兽可放置
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手卡或墓地是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil)
		-- 检查玩家魔法与陷阱区域是否有空位
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
-- 效果处理函数，将符合条件的怪兽当作永续陷阱卡放置
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查玩家魔法与陷阱区域是否有空位
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽移动到魔法与陷阱区域
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		-- 将选中的怪兽转换为永续陷阱卡类型
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
