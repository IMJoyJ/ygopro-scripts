--白騎士団のロード
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：从自己墓地把3只怪兽除外才能发动。这张卡从手卡特殊召唤。那之后，可以从以下效果选1个适用。
-- ●从手卡·卡组把1只「白夜」怪兽特殊召唤。
-- ●从卡组把1张「白之衣」加入手卡。
-- ②：这张卡和对方怪兽进行战斗的攻击宣言时发动。那只对方怪兽的攻击力变成0。
-- ③：这张卡被对方破坏的场合发动。给与对方1000伤害。
local s,id,o=GetID()
-- 初始化卡片效果，注册卡名记述以及①②③三个效果。
function s.initial_effect(c)
	-- 记录这张卡的卡文本中记述了「白之衣」。
	aux.AddCodeList(c,49306994)
	-- 这个卡名的①的效果1回合只能使用1次。①：从自己墓地把3只怪兽除外才能发动。这张卡从手卡特殊召唤。那之后，可以从以下效果选1个适用。●从手卡·卡组把1只「白夜」怪兽特殊召唤。●从卡组把1张「白之衣」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡和对方怪兽进行战斗的攻击宣言时发动。那只对方怪兽的攻击力变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"攻击力变成0"
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetType(EFFECT_TYPE_QUICK_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	-- ③：这张卡被对方破坏的场合发动。给与对方1000伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"给与伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.damcon)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end
-- 过滤条件：检查卡片是否为可以作为代价除外的怪兽。
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- ①效果的发动代价：检查并从自己墓地选择3只怪兽表侧除外。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动代价检查：确认自己墓地存在至少3只可作为代价除外的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,3,nil) end
	-- 发送提示信息，引导玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择3只可作为代价除外的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	-- 将选择的3只怪兽作为发动代价表侧表示除外。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①效果的目标处理函数：检查自己怪兽区空位和自身特招条件，并设置自身特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件检查：确认自己怪兽区至少有1个空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：预计将这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 过滤条件：检查卡片是否为可以特殊召唤的「白夜」怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1e9) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤条件：检查卡片是否为可以加入手卡的「白之衣」。
function s.thfilter(c)
	return c:IsCode(49306994) and c:IsAbleToHand()
end
-- ①效果的处理函数：从手卡特殊召唤自身，并让玩家选择是否适用后续特招「白夜」或检索「白之衣」效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认自身仍与当前连锁相关联，并将其从手卡表侧表示特殊召唤到自己场上，判断是否成功。
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 检查自己怪兽区是否有空位用于适用「白夜」特招选项。
		local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查自己手卡·卡组是否存在可特殊召唤的「白夜」怪兽。
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
		-- 检查自己卡组是否存在可加入手卡的「白之衣」。
		local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		local op=0
		if b1 or b2 then
			-- 让己方从不处理、特殊召唤「白夜」怪兽、将「白之衣」加入手卡中选择1个选项。
			op=aux.SelectFromOptions(tp,
				{true,aux.Stringid(id,3),0},  --"不处理效果"
				{b1,aux.Stringid(id,4),1},  --"特殊召唤"
				{b2,aux.Stringid(id,5),2})  --"加入手卡"
		end
		if op~=0 then
			-- 若选择了适用后续效果，则中断当前效果使其与自身特招视为不同时处理。
			Duel.BreakEffect()
		end
		if op==1 then
			-- 发送提示信息，引导玩家选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从自己手卡·卡组选择1只「白夜」怪兽。
			local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 将所选「白夜」怪兽以表侧表示特殊召唤到自己场上。
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		elseif op==2 then
			-- 发送提示信息，引导玩家选择要加入手卡的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 从自己卡组选择1张「白之衣」。
			local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
			if g:GetCount()>0 then
				-- 将所选「白之衣」以效果加入手卡。
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				-- 将加入手卡的「白之衣」展示给对方确认。
				Duel.ConfirmCards(1-tp,g)
			end
		end
	end
end
-- ②效果的目标处理函数：确认处于这张卡与怪兽进行战斗的攻击宣言时，并将交战对方怪兽设为连锁对象。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		-- 获取本次战斗中发起攻击的怪兽。
		local a=Duel.GetAttacker()
		-- 获取本次战斗中的攻击对象怪兽。
		local at=Duel.GetAttackTarget()
		return (a==c and at or at==c)
			and not c:IsStatus(STATUS_CHAINING)
	end
	-- 将与这张卡交战的怪兽设为当前连锁的处理对象。
	Duel.SetTargetCard(e:GetHandler():GetBattleTarget())
end
-- ②效果的处理函数：确认交战的对方怪兽仍在场上表侧且攻击力大于0，将其攻击力变成0。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁记录的交战怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsControler(1-tp) and tc:GetAttack()>0 then
		-- 那只对方怪兽的攻击力变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- ③效果的发动条件：检查此前由己方控制的这张卡是否被对方破坏。
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp)
end
-- ③效果的目标处理函数：设置伤害目标玩家为对方、伤害数值为1000及伤害操作信息。
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为对方。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设置为1000伤害。
	Duel.SetTargetParam(1000)
	-- 设置操作信息：预计给与对方1000点效果伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- ③效果的处理函数：从连锁信息读取目标玩家和数值并给与伤害。
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取目标玩家和伤害数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果给与对方1000点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
