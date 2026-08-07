--大逆転BOX
-- 效果：
-- ①：自己·对方的准备阶段发动。掷1次骰子，把最多有出现的数目数量的指示物给这张卡放置（最多6个）。
-- ②：对方怪兽攻击的伤害计算时1次或者对方场上的怪兽的效果发动时，把这张卡1个指示物取除，以那之内的1只为对象才能发动。进行1次投掷硬币，对里表作猜测。猜中的场合，从卡组把有「时间黑魔术师」的卡名记述的1只怪兽特殊召唤，作为对象的怪兽直到回合结束时攻击力变成0，效果无效化。
local s,id,o=GetID()
-- 初始化卡片效果，注册时间黑魔术师卡号，允许放置指示物，设置指示物上限为6个，创建永续发动效果，创建准备阶段触发的放置指示物效果，创建攻击伤害计算时和对方怪兽效果发动时的投掷硬币效果
function s.initial_effect(c)
	-- 记录该卡效果文本上记载着时间黑魔术师（卡号40235813）
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
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE+CATEGORY_COIN+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
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
	-- ②：对方怪兽攻击的伤害计算时1次或者对方场上的怪兽的效果发动时，把这张卡1个指示物取除，以那之内的1只为对象才能发动。进行1次投掷硬币，对里表作猜测。猜中的场合，从卡组把有「时间黑魔术师」的卡名记述的1只怪兽特殊召唤，作为对象的怪兽直到回合结束时攻击力变成0，效果无效化。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"投掷硬币"
	e4:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE+CATEGORY_COIN+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
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
-- 准备阶段放置指示物效果的目标函数，用于判断是否可以发动
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- 准备阶段放置指示物效果的处理函数，投掷骰子并根据结果添加相应数量的指示物
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 投掷一次骰子获取结果
	local ct=Duel.TossDice(tp,1)
	if c:GetCounter(0x76)+ct>6 then ct=6-c:GetCounter(0x76) end
	if ct>0 then
		if ct>1 then
			local tb={}
			for i=ct,1,-1 do
				table.insert(tb,i)
			end
			-- 提示玩家选择要放置的指示物数量
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))  --"请选择要放置的指示物的数量"
			-- 玩家宣言要放置的指示物数量
			ct=Duel.AnnounceNumber(tp,1,table.unpack(tb))
		end
		c:AddCounter(0x76,ct)
	end
end
-- 判断目标是否为场上正面表示的怪兽且攻击力非0或未被无效化
function s.mfilter(c)
	return c:IsOnField() and c:IsFaceup() and c:IsType(TYPE_MONSTER)
		and (c:GetAttack()~=0 or not c:IsDisabled())
end
-- 攻击伤害计算时触发效果的条件函数，判断攻击怪兽是否为对方控制且满足mfilter条件
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击的怪兽
	local a=Duel.GetAttacker()
	return a:IsControler(1-tp) and s.mfilter(a)
end
-- 对方怪兽效果发动时触发效果的条件函数，判断发动者是否为对方控制且为怪兽类型且满足mfilter条件
function s.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER) and rc:IsRelateToEffect(re) and s.mfilter(rc)
end
-- 投掷硬币效果的费用函数，移除一张指示物作为代价
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x76,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x76,1,REASON_COST)
end
-- 筛选卡组中可特殊召唤的时间黑魔术师相关怪兽
function s.spfilter(c,e,tp)
	-- 判断目标怪兽是否记载着时间黑魔术师（卡号40235813）且可以特殊召唤
	return aux.IsCodeListed(c,40235813) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 攻击伤害计算时触发效果的目标函数，检查攻击怪兽是否可作为对象、是否有空位、卡组是否存在满足条件的怪兽
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前攻击的怪兽
	local a=Duel.GetAttacker()
	if chkc then return false end
	if chk==0 then return a:IsCanBeEffectTarget(e)
		-- 检查目标玩家场上是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果目标为攻击怪兽
	Duel.SetTargetCard(a)
	-- 设置操作信息，提示将进行一次硬币投掷
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 对方怪兽效果发动时触发效果的目标函数，检查发动怪兽是否可作为对象、是否有空位、卡组是否存在满足条件的怪兽
function s.atktg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=re:GetHandler()
	if chk==0 then return tc:IsOnField() and tc:IsCanBeEffectTarget(e)
		-- 检查目标玩家场上是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果目标为发动怪兽
	Duel.SetTargetCard(tc)
	-- 设置操作信息，提示将进行一次硬币投掷
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 投掷硬币效果的处理函数，根据猜中与否决定是否特殊召唤并使对象怪兽无效化
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 提示玩家选择硬币正反面
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COIN)  --"请选择硬币的正反面"
	-- 玩家宣言硬币正反面
	local coin=Duel.AnnounceCoin(tp)
	-- 投掷一次硬币获取结果
	local res=Duel.TossCoin(tp,1)
	-- 判断猜中与否且场上是否有空位
	if coin~=res and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择满足条件的怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		-- 执行特殊召唤操作
		if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0
			and tc:IsFaceup() and tc:IsRelateToChain() and tc:IsCanBeDisabledByEffect(e) then
			-- 使目标怪兽的连锁无效化
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 使对象怪兽效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 使对象怪兽效果无效化
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			-- 将对象怪兽攻击力设为0
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
