--ジャイアント・メサイア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方怪兽的攻击宣言时才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从自己的手卡·墓地选1只昆虫族怪兽当作攻击力·守备力上升500的装备卡使用给这张卡装备。
-- ③：1回合1次，昆虫族怪兽进行战斗的伤害步骤开始时，以自己以及对方场上的卡各1张为对象才能发动。那些卡破坏。
function c39078434.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39078434,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,39078434)
	e1:SetCondition(c39078434.spcon)
	e1:SetTarget(c39078434.sptg)
	e1:SetOperation(c39078434.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从自己的手卡·墓地选1只昆虫族怪兽当作攻击力·守备力上升500的装备卡使用给这张卡装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39078434,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCountLimit(1,39078435)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(c39078434.eqtg)
	e2:SetOperation(c39078434.eqop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：1回合1次，昆虫族怪兽进行战斗的伤害步骤开始时，以自己以及对方场上的卡各1张为对象才能发动。那些卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(39078434,2))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_START)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1)
	e4:SetCondition(c39078434.descon)
	e4:SetTarget(c39078434.destg)
	e4:SetOperation(c39078434.desop)
	c:RegisterEffect(e4)
end
-- 判断是否为对方怪兽攻击宣言时触发的效果
function c39078434.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击怪兽是否为对方控制
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 设置特殊召唤的条件
function c39078434.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function c39078434.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡片特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义装备卡的筛选条件
function c39078434.eqfilter(c,tp)
	return c:IsRace(RACE_INSECT) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
-- 设置装备效果的条件
function c39078434.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的装备区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断手牌或墓地是否存在符合条件的昆虫族怪兽
		and Duel.IsExistingMatchingCard(c39078434.eqfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,tp) end
end
-- 执行装备操作
function c39078434.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断装备区域是否为空
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择符合条件的昆虫族怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c39078434.eqfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		-- 尝试将卡装备给目标怪兽
		if not Duel.Equip(tp,tc,c) then return end
		-- 设置装备卡的限制效果
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c39078434.eqlimit)
		tc:RegisterEffect(e1)
		-- 设置装备卡的攻击力提升效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(500)
		tc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e3)
	end
end
-- 设置装备卡的装备限制条件
function c39078434.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 判断战斗中的怪兽是否为昆虫族
function c39078434.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗中的攻击怪兽和防守怪兽
	local a,d=Duel.GetBattleMonster(tp)
	return a and a:IsFaceup() and a:IsRace(RACE_INSECT) or d and d:IsFaceup() and d:IsRace(RACE_INSECT)
end
-- 设置破坏效果的条件
function c39078434.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断己方场上是否存在可破坏的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,0,1,nil)
		-- 判断对方场上是否存在可破坏的卡
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择己方场上的卡
	local g1=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的卡
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置破坏效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 执行破坏操作
function c39078434.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将目标卡组破坏
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
