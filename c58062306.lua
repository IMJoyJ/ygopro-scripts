--ローズ・プリンセス
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：只有对方场上才有怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤的这张卡当作调整使用。
-- ②：把这张卡从手卡丢弃才能发动。从卡组把1张「白蔷薇回廊」加入手卡。
function c58062306.initial_effect(c)
	-- 注册卡片关联密码，表明本卡效果中记载了「白蔷薇回廊」的卡名
	aux.AddCodeList(c,84335863)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：只有对方场上才有怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤的这张卡当作调整使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,58062306+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c58062306.spcon)
	e1:SetOperation(c58062306.spop)
	c:RegisterEffect(e1)
	-- ②：把这张卡从手卡丢弃才能发动。从卡组把1张「白蔷薇回廊」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(58062306,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCost(c58062306.cost)
	e2:SetTarget(c58062306.target)
	e2:SetOperation(c58062306.operation)
	c:RegisterEffect(e2)
end
c58062306.treat_itself_tuner=true
-- 特殊召唤规则的条件判断函数
function c58062306.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 检查对方场上的怪兽数量是否大于0
		and Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
		-- 检查自己场上是否有可用于特殊召唤怪兽的空位
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 特殊召唤规则成功时的处理函数，用于为自身添加当作调整使用的效果
function c58062306.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 这个方法特殊召唤的这张卡当作调整使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(TYPE_TUNER)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	c:RegisterEffect(e1)
end
-- 发动效果的代价（Cost）判断与执行函数
function c58062306.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 作为发动代价，将这张卡从手卡丢弃并送去墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤卡组中卡名为「白蔷薇回廊」且能加入手卡的卡片的检索条件函数
function c58062306.filter(c)
	return c:IsCode(84335863) and c:IsAbleToHand()
end
-- 检索效果的发动准备与合法性检测函数
function c58062306.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查卡组中是否存在可检索的「白蔷薇回廊」
	if chk==0 then return Duel.IsExistingMatchingCard(c58062306.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示该效果会将卡组的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的实际处理函数
function c58062306.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从卡组中获取第一张满足条件的「白蔷薇回廊」
	local tg=Duel.GetFirstMatchingCard(c58062306.filter,tp,LOCATION_DECK,0,nil)
	if tg then
		-- 将获取到的「白蔷薇回廊」加入手卡
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,tg)
	end
end
