--大逆転BOX
-- 效果：
-- ①：自己·对方的准备阶段发动。掷1次骰子，把最多有出现的数目数量的指示物给这张卡放置（最多6个）。
-- ②：对方怪兽攻击的伤害计算时1次或者对方场上的怪兽的效果发动时，把这张卡1个指示物取除，以那之内的1只为对象才能发动。进行1次投掷硬币，对里表作猜测。猜中的场合，从卡组把有「时间黑魔术师」的卡名记述的1只怪兽特殊召唤，作为对象的怪兽直到回合结束时攻击力变成0，效果无效化。
local s,id,o=GetID()
-- 初始化卡片效果，注册时间黑魔术师卡号，允许放置指示物，设置最大指示物数量为6，创建永续发动效果，创建准备阶段触发的放置指示物效果，创建攻击伤害计算时和对方怪兽效果发动时的投掷硬币效果
function s.initial_effect(c)
	-- 记录该卡效果文本上记载着时间黑魔术师（40235813）这张卡
	aux.AddCodeList(c,40235813)
	c:EnableCounterPermit(0x76)
	c:SetCounterLimit(0x76,6)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 准备阶段触发的放置指示物效果，用于在准备阶段掷骰子并放置相应数量的指示物
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
	-- 攻击伤害计算时触发的投掷硬币效果，用于猜硬币结果并特殊召唤时间黑魔术师怪兽
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
	-- 对方怪兽效果发动时触发的投掷硬币效果，用于猜硬币结果并特殊召唤时间黑魔术师怪兽
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
-- 放置指示物效果的目标函数，检查是否满足条件
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- 放置指示物效果的操作函数，掷骰子决定放置指示物数量并添加到卡片上
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 掷一次骰子决定要放置的指示物数量
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
-- 判断目标怪兽是否满足效果处理条件的过滤函数
function s.mfilter(c)
	return c:IsOnField() and c:IsFaceup() and c:IsType(TYPE_MONSTER)
		and (c:GetAttack()~=0 or not c:IsDisabled())
end
-- 攻击伤害计算时触发效果的条件函数，检查攻击怪兽是否为对方控制且满足处理条件
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击怪兽
	local a=Duel.GetAttacker()
	return a:IsControler(1-tp) and s.mfilter(a)
end
-- 对方怪兽效果发动时触发效果的条件函数，检查发动者是否为对方且满足处理条件
function s.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER) and rc:IsRelateToEffect(re) and s.mfilter(rc)
end
-- 投掷硬币效果的费用函数，移除一张指示物作为费用
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x76,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x76,1,REASON_COST)
end
-- 筛选可特殊召唤的时间黑魔术师怪兽的过滤函数
function s.spfilter(c,e,tp)
	-- 判断目标卡是否记载着时间黑魔术师（40235813）且可以特殊召唤
	return aux.IsCodeListed(c,40235813) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 攻击伤害计算时触发效果的目标函数，检查攻击怪兽是否能成为效果对象并满足特殊召唤条件
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前攻击怪兽
	local a=Duel.GetAttacker()
	if chkc then return false end
	if chk==0 then return a:IsCanBeEffectTarget(e)
		-- 检查目标玩家场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的时间黑魔术师怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置当前连锁的目标为攻击怪兽
	Duel.SetTargetCard(a)
	-- 设置操作信息，提示将进行一次硬币投掷
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 对方怪兽效果发动时触发效果的目标函数，检查发动怪兽是否能成为效果对象并满足特殊召唤条件
function s.atktg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=re:GetHandler()
	if chk==0 then return tc:IsOnField() and tc:IsCanBeEffectTarget(e)
		-- 检查目标玩家场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的时间黑魔术师怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置当前连锁的目标为发动怪兽
	Duel.SetTargetCard(tc)
	-- 设置操作信息，提示将进行一次硬币投掷
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 投掷硬币效果的操作函数，处理猜硬币结果并特殊召唤时间黑魔术师怪兽
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 提示玩家选择硬币正反面
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COIN)  --"请选择硬币的正反面"
	-- 玩家宣言硬币正反面
	local coin=Duel.AnnounceCoin(tp)
	-- 掷一次硬币决定结果
	local res=Duel.TossCoin(tp,1)
	-- 判断猜硬币结果是否失败且场上存在特殊召唤区域
	if coin~=res and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的时间黑魔术师怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择满足条件的时间黑魔术师怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		-- 检查是否成功特殊召唤了怪兽并满足后续处理条件
		if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0
			and tc:IsFaceup() and tc:IsRelateToChain() and tc:IsCanBeDisabledByEffect(e) then
			-- 使目标怪兽的连锁无效化
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 使目标怪兽效果无效化
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 使目标怪兽效果无效化
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			-- 将目标怪兽攻击力设为0
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
