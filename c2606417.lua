--大逆転BOX
-- 效果：
-- ①：自己·对方的准备阶段发动。掷1次骰子，把最多有出现的数目数量的指示物给这张卡放置（最多6个）。
-- ②：对方怪兽攻击的伤害计算时1次或者对方场上的怪兽的效果发动时，把这张卡1个指示物取除，以那之内的1只为对象才能发动。进行1次投掷硬币，对里表作猜测。猜中的场合，从卡组把有「时间黑魔术师」的卡名记述的1只怪兽特殊召唤，作为对象的怪兽直到回合结束时攻击力变成0，效果无效化。
local s,id,o=GetID()
-- 初始化卡片效果，注册卡名记述、指示物上限及永续陷阱发动许可与①②效果（②按攻击宣言与怪兽效果发动拆分为两段）。
function s.initial_effect(c)
	-- 记录这张卡的卡文本中记述了「时间黑魔术师」。
	aux.AddCodeList(c,40235813)
	c:EnableCounterPermit(0x76)
	c:SetCounterLimit(0x76,6)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己·对方的准备阶段发动。掷1次骰子，把最多有出现的数目数量的指示物给这张卡放置（最多6个）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"放置指示物"
	e2:SetCategory(CATEGORY_COUNTER+CATEGORY_DICE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.cttg)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	-- ②：对方怪兽攻击的伤害计算时1次或者对方场上的怪兽的效果发动时，把这张卡1个指示物取除，以那之内的1只为对象才能发动。进行1次投掷硬币，对里表作猜测。猜中的场合，从卡组把有「时间黑魔术师」的卡名记述的1只怪兽特殊召唤，作为对象的怪兽直到回合结束时攻击力变成0，效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"投掷硬币"
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE+CATEGORY_COIN+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e3:SetCondition(s.atkcon)
	e3:SetCost(s.atkcost)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
	-- ②：对方场上的怪兽的效果发动时，把这张卡1个指示物取除，以那之内的1只为对象才能发动。进行1次投掷硬币，对里表作猜测。猜中的场合，从卡组把有「时间黑魔术师」的卡名记述的1只怪兽特殊召唤，作为对象的怪兽直到回合结束时攻击力变成0，效果无效化。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"投掷硬币"
	e4:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE+CATEGORY_COIN+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCondition(s.atkcon2)
	e4:SetCost(s.atkcost)
	e4:SetTarget(s.atktg2)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
end
s.mentioned_counter={
	[0x76]=true,
}
-- ①效果的目标处理函数：必发效果始终返回可发动。
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- ①效果的处理函数：掷1次骰子，结合上限6个计算可放置数量并让玩家选择要放置的指示物数量。
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 己方投掷1次骰子并获取点数结果。
	local ct=Duel.TossDice(tp,1)
	if c:GetCounter(0x76)+ct>6 then ct=6-c:GetCounter(0x76) end
	if ct>0 then
		if ct>1 then
			local tb={}
			for i=ct,1,-1 do
				table.insert(tb,i)
			end
			-- 发送提示信息，引导玩家选择要放置的指示物数量。
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))  --"请选择要放置的指示物的数量"
			-- 让己方宣言1到可放置上限之间的数字，作为本次放置的指示物数量。
			ct=Duel.AnnounceNumber(tp,1,table.unpack(tb))
		end
		c:AddCounter(0x76,ct)
	end
end
-- 过滤条件：检查卡片是否为场上表侧表示且攻击力不为0或效果未被无效的怪兽。
function s.mfilter(c)
	return c:IsOnField() and c:IsFaceup() and c:IsType(TYPE_MONSTER)
		and (c:GetAttack()~=0 or not c:IsDisabled())
end
-- ②效果（攻击分支）的发动条件：检查攻击怪兽是否为对方控制且满足攻击力不为0或效果未被无效的条件。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗中正在进行攻击的怪兽。
	local a=Duel.GetAttacker()
	return a:IsControler(1-tp) and s.mfilter(a)
end
-- ②效果（怪兽效果发动分支）的发动条件：检查是否为对方场上怪兽发动效果且满足条件。
function s.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER) and rc:IsRelateToEffect(re) and s.mfilter(rc)
end
-- ②效果的发动代价：检查并从这张卡取除1个指示物作为发动代价。
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x76,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x76,1,REASON_COST)
end
-- 过滤条件：检查卡片是否为记述了「时间黑魔术师」卡名且可特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	-- 判断卡片文本是否记述了「时间黑魔术师」且可以被特殊召唤。
	return aux.IsCodeListed(c,40235813) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果（攻击分支）的目标处理函数：检查攻击怪兽可否成为对象及卡组是否有可特招怪兽，并设置对象与硬币信息。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前战斗中发起攻击的怪兽。
	local a=Duel.GetAttacker()
	if chkc then return false end
	if chk==0 then return a:IsCanBeEffectTarget(e)
		-- 检查自己怪兽区是否存在可用于特殊召唤的空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己卡组是否存在记述「时间黑魔术师」的可特殊召唤怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 将发起攻击的对方怪兽设为当前连锁的处理对象。
	Duel.SetTargetCard(a)
	-- 设置操作信息：预计自己进行1次投掷硬币。
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- ②效果（怪兽效果发动分支）的目标处理函数：检查对方发动效果的怪兽在场上且可成为对象及卡组是否有可特招怪兽，并设置对象与硬币信息。
function s.atktg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=re:GetHandler()
	if chk==0 then return tc:IsOnField() and tc:IsCanBeEffectTarget(e)
		-- 检查自己怪兽区是否存在可用于特殊召唤的空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己卡组是否存在记述「时间黑魔术师」的可特殊召唤怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 将发动效果的对方怪兽设为当前连锁的处理对象。
	Duel.SetTargetCard(tc)
	-- 设置操作信息：预计自己进行1次投掷硬币。
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- ②效果的处理函数：猜测并投掷硬币，猜中时从卡组特招记述「时间黑魔术师」的怪兽，并将对象怪兽攻击力变为0且效果无效直到回合结束。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁指定的对方怪兽对象。
	local tc=Duel.GetFirstTarget()
	-- 发送提示信息，引导玩家宣言硬币的正反面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COIN)  --"请选择硬币的正反面"
	-- 让己方宣言硬币的正反面（正面为0，反面为1）。
	local coin=Duel.AnnounceCoin(tp)
	-- 由己方投掷1次硬币（正面为1，反面为0）。
	local res=Duel.TossCoin(tp,1)
	-- 判断是否猜中硬币且己方怪兽区有空位。
	if coin~=res and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 发送提示信息，引导玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己卡组选择1只记述了「时间黑魔术师」卡名的怪兽。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		-- 将所选怪兽表侧特殊召唤到自己场上，并判断是否特殊召唤成功。
		if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0
			and tc:IsFaceup() and tc:IsRelateToChain() and tc:IsCanBeDisabledByEffect(e) then
			-- 使与对象怪兽相关的当前连锁效果无效化。
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 作为对象的怪兽直到回合结束时效果无效化。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 作为对象的怪兽直到回合结束时效果无效化。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			-- 作为对象的怪兽直到回合结束时攻击力变成0
			local e3=Effect.CreateEffect(c)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_SET_ATTACK_FINAL)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e3:SetValue(0)
			tc:RegisterEffect(e3)
		end
	end
end
