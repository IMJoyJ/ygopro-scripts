--チョコ・マジシャン・ガール
-- 效果：
-- ①：1回合1次，从手卡丢弃1只魔法师族怪兽才能发动。自己从卡组抽1张。
-- ②：1回合1次，这张卡被选择作为攻击对象的场合，以「巧克力魔术少女」以外的自己墓地1只魔法师族怪兽为对象才能发动。那只怪兽特殊召唤。那之后，攻击对象转移为那只怪兽，攻击怪兽的攻击力变成一半。
function c7198399.initial_effect(c)
	-- ①：1回合1次，从手卡丢弃1只魔法师族怪兽才能发动。自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7198399,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c7198399.drcost)
	e1:SetTarget(c7198399.drtg)
	e1:SetOperation(c7198399.drop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，这张卡被选择作为攻击对象的场合，以「巧克力魔术少女」以外的自己墓地1只魔法师族怪兽为对象才能发动。那只怪兽特殊召唤。那之后，攻击对象转移为那只怪兽，攻击怪兽的攻击力变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(7198399,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c7198399.sptg)
	e2:SetOperation(c7198399.spop)
	c:RegisterEffect(e2)
end
-- 过滤手牌中可丢弃的魔法师族怪兽
function c7198399.costfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsDiscardable()
end
-- 效果①的发动成本（Cost）函数
function c7198399.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可以丢弃的魔法师族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c7198399.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手牌丢弃1只魔法师族怪兽
	Duel.DiscardHand(tp,c7198399.costfilter,1,1,REASON_DISCARD+REASON_COST)
end
-- 效果①的发动准备（Target）函数
function c7198399.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前连锁的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为1
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果①的效果处理（Operation）函数
function c7198399.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 过滤墓地中除「巧克力魔术少女」以外的魔法师族怪兽
function c7198399.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and not c:IsCode(7198399) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备（Target）函数
function c7198399.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c7198399.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在满足特殊召唤条件的对象
		and Duel.IsExistingTarget(c7198399.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c7198399.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的效果处理（Operation）函数
function c7198399.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍存在于墓地，则将其特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 获取当前进行攻击的怪兽
		local a=Duel.GetAttacker()
		local ag=a:GetAttackableTarget()
		if a:IsAttackable() and not a:IsImmuneToEffect(e) and ag:IsContains(tc) then
			-- 中断当前效果处理，使后续处理不与特殊召唤同时发生
			Duel.BreakEffect()
			-- 将攻击对象转移为特殊召唤的怪兽
			Duel.ChangeAttackTarget(tc)
			-- 攻击怪兽的攻击力变成一半。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(math.ceil(a:GetAttack()/2))
			a:RegisterEffect(e1)
		end
	end
end
