--白騎士団のロード
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：从自己墓地把3只怪兽除外才能发动。这张卡从手卡特殊召唤。那之后，可以从以下效果选1个适用。
-- ●从手卡·卡组把1只「白夜」怪兽特殊召唤。
-- ●从卡组把1张「白之衣」加入手卡。
-- ②：这张卡和对方怪兽进行战斗的攻击宣言时发动。那只对方怪兽的攻击力变成0。
-- ③：这张卡被对方破坏的场合发动。给与对方1000伤害。
local s,id,o=GetID()
-- 初始化卡片效果：登记卡名记载信息，并注册①手卡特殊召唤的起动效果、②攻击宣言时对方怪兽攻击力变0的诱发即时必发效果、③被对方破坏时给与伤害的诱发效果
function s.initial_effect(c)
	-- 记录这张卡上记载着卡号49306994（「白之衣」）的卡名
	aux.AddCodeList(c,49306994)
	-- ①：从自己墓地把3只怪兽除外才能发动。这张卡从手卡特殊召唤。那之后，可以从以下效果选1个适用。●从手卡·卡组把1只「白夜」怪兽特殊召唤。●从卡组把1张「白之衣」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_SEARCH+CATEGORY_TOHAND)
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
-- 定义代价用过滤器：筛选可以作为代价除外的怪兽卡
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- ①效果的代价处理：从自己墓地选择3只怪兽并以表侧表示除外
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在3只以上可以作为代价除外的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,3,nil) end
	-- 向玩家提示请选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择3只可以作为代价除外的怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	-- 将选择的3只怪兽以表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①效果的目标判定：确认自己主要怪兽区有空格且这张卡可以从手卡特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己主要怪兽区是否有可用空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：确定要将这张卡特殊召唤1只
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 定义特殊召唤用过滤器：筛选可以特殊召唤的「白夜」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1e9) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义检索用过滤器：筛选可以加入手卡的「白之衣」（卡号49306994）
function s.thfilter(c)
	return c:IsCode(49306994) and c:IsAbleToHand()
end
-- ①效果的处理：把这张卡从手卡特殊召唤，那之后让玩家从「白夜」怪兽特殊召唤或「白之衣」加入手卡中选1个适用并处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与连锁相关，并将这张卡从手卡以表侧表示特殊召唤到自己场上
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 检查自己主要怪兽区是否有可用空格（选项一的前半条件）
		local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查自己手卡·卡组是否存在可以特殊召唤的「白夜」怪兽
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
		-- 检查自己卡组是否存在可以加入手卡的「白之衣」
		local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		local op=0
		if b1 or b2 then
			-- 让玩家从「不处理效果」「特殊召唤」「加入手卡」三个选项中选择1个
			op=aux.SelectFromOptions(tp,
				{true,aux.Stringid(id,3),0},  --"不处理效果"
				{b1,aux.Stringid(id,4),1},  --"特殊召唤"
				{b2,aux.Stringid(id,5),2})  --"加入手卡"
		end
		if op~=0 then
			-- 中断当前效果处理，使之后的处理与特殊召唤不同时处理
			Duel.BreakEffect()
		end
		if op==1 then
			-- 向玩家提示请选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让玩家从自己手卡·卡组选择1只可以特殊召唤的「白夜」怪兽
			local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 将选择的「白夜」怪兽以表侧表示特殊召唤到自己场上
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		elseif op==2 then
			-- 向玩家提示请选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 让玩家从自己卡组选择1张「白之衣」
			local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
			if g:GetCount()>0 then
				-- 将选择的「白之衣」加入持有者手卡
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				-- 向对方玩家展示加入手卡的卡
				Duel.ConfirmCards(1-tp,g)
			end
		end
	end
end
-- ②效果的目标设定：确认是这张卡和对方怪兽进行战斗的攻击宣言且这张卡不在连锁处理中，并将进行战斗的对方怪兽设为对象
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		-- 取得此次战斗攻击的卡
		local a=Duel.GetAttacker()
		-- 取得此次战斗的攻击对象
		local at=Duel.GetAttackTarget()
		return (a==c and at or at==c)
			and not c:IsStatus(STATUS_CHAINING)
	end
	-- 将进行战斗的那只对方怪兽设为当前连锁的对象
	Duel.SetTargetCard(e:GetHandler():GetBattleTarget())
end
-- ②效果的处理：若对象怪兽仍为对方场上表侧表示且攻击力大于0，则将其攻击力变成0
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象（那只对方怪兽）
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
-- ③效果的发动条件：确认这张卡是原本由自己控制且被对方破坏的场合
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp)
end
-- ③效果的目标设定：设定给与对方1000伤害的操作信息
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设定伤害的对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设定伤害的数值为1000
	Duel.SetTargetParam(1000)
	-- 设置操作信息：确定给与对方1000伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- ③效果的处理：读取对象玩家和伤害数值，给与对方1000伤害
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中读取对象玩家和对象参数（伤害数值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因给与对方1000伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
