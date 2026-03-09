--相剣大邪－七星龍淵
-- 效果：
-- 调整＋调整以外的幻龙族怪兽1只以上
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡在怪兽区域存在的状态，自己把幻龙族同调怪兽同调召唤的场合才能发动。自己抽1张。
-- ②：对方把怪兽特殊召唤的场合才能发动。那之内的1只除外，给与对方1200伤害。
-- ③：对方把魔法·陷阱卡的效果发动时才能发动。那张卡除外，给与对方1200伤害。
function c47710198.initial_effect(c)
	-- 为卡片添加同调召唤手续，要求必须满足调整且为幻龙族的怪兽作为1只调整，其余为幻龙族的调整以外的怪兽至少1只
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_WYRM),1)
	c:EnableReviveLimit()
	-- ①：这张卡在怪兽区域存在的状态，自己把幻龙族同调怪兽同调召唤的场合才能发动。自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47710198,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,47710198)
	e1:SetCondition(c47710198.drcon)
	e1:SetTarget(c47710198.drtg)
	e1:SetOperation(c47710198.drop)
	c:RegisterEffect(e1)
	-- 注册一个合并的特殊召唤成功事件监听器，用于触发效果②
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,47710198,EVENT_SPSUMMON_SUCCESS)
	-- ②：对方把怪兽特殊召唤的场合才能发动。那之内的1只除外，给与对方1200伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47710198,1))  --"特殊召唤的怪兽除外"
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(custom_code)
	e2:SetCountLimit(1,47710199)
	e2:SetTarget(c47710198.remtg1)
	e2:SetOperation(c47710198.remop1)
	c:RegisterEffect(e2)
	-- ③：对方把魔法·陷阱卡的效果发动时才能发动。那张卡除外，给与对方1200伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(47710198,2))  --"发动的卡除外"
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,47710200)
	e3:SetCondition(c47710198.remcon2)
	e3:SetTarget(c47710198.remtg2)
	e3:SetOperation(c47710198.remop2)
	c:RegisterEffect(e3)
end
-- 判断是否满足效果①的发动条件，即自己场上存在此卡，且有幻龙族同调怪兽被特殊召唤成功
function c47710198.drcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return eg:GetCount()==1 and tc~=e:GetHandler() and tc:IsSummonType(SUMMON_TYPE_SYNCHRO) and tc:IsSummonPlayer(tp)
		and tc:IsRace(RACE_WYRM)
end
-- 设置效果①的目标为自身玩家并设定抽卡数量为1
function c47710198.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以进行抽卡操作
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置连锁目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置连锁目标参数为1张卡
	Duel.SetTargetParam(1)
	-- 设置效果①的操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行效果①的处理，使自己抽一张卡
function c47710198.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 定义用于筛选对方场上可除外怪兽的过滤函数
function c47710198.filter(c,e,tp)
	return c:IsSummonPlayer(1-tp) and c:IsLocation(LOCATION_MZONE) and c:IsAbleToRemove()
		and (not e or c:IsRelateToEffect(e))
end
-- 设置效果②的目标为符合条件的怪兽组并设定操作信息为除外与伤害
function c47710198.remtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c47710198.filter,1,nil,nil,tp) end
	local g=eg:Filter(c47710198.filter,nil,nil,tp)
	-- 设置效果②的操作对象为符合条件的怪兽组
	Duel.SetTargetCard(g)
	-- 设置效果②的操作信息为除外效果
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 设置效果②的操作信息为造成伤害效果
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1200)
end
-- 执行效果②的处理，选择一只怪兽除外并造成对方1200伤害
function c47710198.remop1(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c47710198.filter,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	if g:GetCount()>1 then
		-- 向玩家提示选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		tc=g:Select(tp,1,1,nil):GetFirst()
	end
	-- 判断是否成功将目标怪兽除外且处于除外状态
	if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and (tc:IsLocation(LOCATION_REMOVED) or tc:IsType(TYPE_TOKEN)) then
		-- 对对方造成1200伤害
		Duel.Damage(1-tp,1200,REASON_EFFECT)
	end
end
-- 判断是否满足效果③的发动条件，即对方发动魔法或陷阱卡的效果
function c47710198.remcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ep==1-tp and re:GetHandler():IsRelateToEffect(re) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置效果③的目标为被发动的魔法或陷阱卡并设定操作信息为除外与伤害
function c47710198.remtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsAbleToRemove() end
	-- 设置效果③的操作信息为除外效果
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
	-- 设置效果③的操作信息为造成伤害效果
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1200)
end
-- 执行效果③的处理，将对方发动的魔法或陷阱卡除外并造成对方1200伤害
function c47710198.remop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	if tc:IsRelateToEffect(re) then
		-- 判断是否成功将目标卡除外且处于除外状态
		if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_REMOVED) then
			-- 对对方造成1200伤害
			Duel.Damage(1-tp,1200,REASON_EFFECT)
		end
	end
end
