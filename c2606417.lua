--大逆転BOX
-- 效果：
-- ①：自己·对方的准备阶段发动。掷1次骰子，把最多有出现的数目数量的指示物给这张卡放置（最多6个）。
-- ②：对方怪兽攻击的伤害计算时1次或者对方场上的怪兽的效果发动时，把这张卡1个指示物取除，以那之内的1只为对象才能发动。进行1次投掷硬币，对里表作猜测。猜中的场合，从卡组把有「时间黑魔术师」的卡名记述的1只怪兽特殊召唤，作为对象的怪兽直到回合结束时攻击力变成0，效果无效化。
local s,id,o=GetID()
-- 注册卡片初始化效果：添加包含「时间黑魔术师」的卡名列表，允许放置指示物并上限为6，以及准备阶段放置指示物和伤害计算时/对方怪兽效果发动时投掷硬币特召并无效的效果。
function s.initial_effect(c)
	-- 注册记述「时间黑魔术师」卡名的代码列表。
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
	-- ②：对方怪兽攻击的伤害计算时1次，把这张卡1个指示物取除，以那之内的1只为对象才能发动。
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
	-- ②：对方场上的怪兽的效果发动时，把这张卡1个指示物取除，以那之内的1只为对象才能发动。
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
-- 准备阶段放置指示物效果的目标检查函数，直接返回true（必发效果）。
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- 准备阶段放置指示物效果的处理函数：掷1次骰子，玩家选择并把最多出现的数目数量（最多6个）的指示物给这张卡放置。
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 让发动玩家进行1次掷骰子。
	local ct=Duel.TossDice(tp,1)
	if c:GetCounter(0x76)+ct>6 then ct=6-c:GetCounter(0x76) end
	if ct>0 then
		if ct>1 then
			local tb={}
			for i=ct,1,-1 do
				table.insert(tb,i)
			end
			-- 弹出提示信息，要求玩家选择要放置指示物的数量。
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))  --"请选择要放置的指示物的数量"
			-- 让发动玩家在可选数量范围内宣言一个要放置的指示物数量。
			ct=Duel.AnnounceNumber(tp,1,table.unpack(tb))
		end
		c:AddCounter(0x76,ct)
	end
end
-- 怪兽过滤函数：检查卡片是否在场上表侧表示存在且为怪兽，并且攻击力不为0或效果未被无效。
function s.mfilter(c)
	return c:IsOnField() and c:IsFaceup() and c:IsType(TYPE_MONSTER)
		and (c:GetAttack()~=0 or not c:IsDisabled())
end
-- 伤害计算时发动效果的条件检查函数：检查攻击怪兽是否属于对方且满足怪兽过滤条件。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	return a:IsControler(1-tp) and s.mfilter(a)
end
-- 对方怪兽效果发动时效果的条件检查函数：检查是否为对方发动的怪兽效果，且发动效果的卡仍在场上并满足怪兽过滤条件。
function s.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER) and rc:IsRelateToEffect(re) and s.mfilter(rc)
end
-- 效果发动cost函数：取除这张卡的1个指示物。
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x76,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x76,1,REASON_COST)
end
-- 特殊召唤怪兽过滤函数：检查卡片文本是否记载有「时间黑魔术师」且能否被特殊召唤。
function s.spfilter(c,e,tp)
	-- 判断卡片是否在文本中记载有「时间黑魔术师」并能以常规方式特殊召唤。
	return aux.IsCodeListed(c,40235813) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 伤害计算时效果的目标选择函数：检查攻击怪兽能否作为效果对象，且自己场上有怪兽区域空位且卡组存在可特殊召唤的怪兽，将攻击怪兽设为对象。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前攻击的怪兽作为目标卡。
	local a=Duel.GetAttacker()
	if chkc then return false end
	if chk==0 then return a:IsCanBeEffectTarget(e)
		-- 检查发动玩家的怪兽区域是否有可用的空位数。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己卡组是否存在至少1张记载有「时间黑魔术师」的可以特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 将攻击怪兽设为当前效果的对象。
	Duel.SetTargetCard(a)
	-- 设置当前连锁的操作信息为包含1次硬币投掷。
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 对方怪兽效果发动时效果的目标选择函数：检查发动效果的怪兽能否作为效果对象，且自己场上有空位及卡组有可特召怪兽，将其设为对象。
function s.atktg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=re:GetHandler()
	if chk==0 then return tc:IsOnField() and tc:IsCanBeEffectTarget(e)
		-- 检查发动玩家的怪兽区域是否有可用的空位数。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己卡组是否存在至少1张记载有「时间黑魔术师」的可以特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 将发动效果的怪兽卡设为当前效果的对象。
	Duel.SetTargetCard(tc)
	-- 设置当前连锁的操作信息为包含1次硬币投掷。
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 硬币投掷及后续特召无效效果的处理函数：让玩家对里表作猜测，猜中的场合从卡组特召记载「时间黑魔术师」的怪兽，并将对象怪兽攻击力变成0且效果无效化。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁设定的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 弹出提示要求玩家选择宣言硬币的正反面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COIN)  --"请选择硬币的正反面"
	-- 让发动玩家宣言硬币的正反面。
	local coin=Duel.AnnounceCoin(tp)
	-- 进行1次投掷硬币。
	local res=Duel.TossCoin(tp,1)
	-- 判断硬币猜中且自己场上有怪兽区域空位。
	if coin~=res and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 弹出提示要求玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己卡组选择1张记载有「时间黑魔术师」的怪兽。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		-- 若成功选择并表侧表示特殊召唤该怪兽到自己场上。
		if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0
			and tc:IsFaceup() and tc:IsRelateToChain() and tc:IsCanBeDisabledByEffect(e) then
			-- 使作为对象的怪兽相关连锁的效果无效化。
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
			-- 作为对象的怪兽直到回合结束时攻击力变成0。
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
