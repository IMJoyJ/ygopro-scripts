--ペンデュラム・エボリューション
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：从手卡让1只灵摆怪兽回到卡组才能发动。和回去的怪兽卡名不同的1只攻击力2500的灵摆怪兽从卡组加入手卡。
-- ②：自己把额外卡组的里侧的灵摆怪兽特殊召唤的回合的自己主要阶段才能发动。进行怪兽的灵摆召唤。
-- ③：以自己场上1只「霸王龙 扎克」为对象才能发动。这个回合，那只怪兽可以向对方怪兽全部各作1次攻击。
function c55795155.initial_effect(c)
	-- 记录这张卡上记载了「霸王龙 扎克」的卡名。
	aux.AddCodeList(c,13331639)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：从手卡让1只灵摆怪兽回到卡组才能发动。和回去的怪兽卡名不同的1只攻击力2500的灵摆怪兽从卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(55795155,0))  --"卡组检索"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,55795155)
	e2:SetTarget(c55795155.thtg)
	e2:SetOperation(c55795155.thop)
	c:RegisterEffect(e2)
	-- ②：自己把额外卡组的里侧的灵摆怪兽特殊召唤的回合的自己主要阶段才能发动。进行怪兽的灵摆召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(55795155,1))  --"灵摆召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,55795156)
	e3:SetCondition(c55795155.pcon)
	e3:SetTarget(c55795155.ptg)
	e3:SetOperation(c55795155.pop)
	c:RegisterEffect(e3)
	-- ③：以自己场上1只「霸王龙 扎克」为对象才能发动。这个回合，那只怪兽可以向对方怪兽全部各作1次攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(55795155,2))  --"攻击全体"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,55795157)
	e4:SetCondition(c55795155.atkcon)
	e4:SetTarget(c55795155.atktg)
	e4:SetOperation(c55795155.atkop)
	c:RegisterEffect(e4)
	if not c55795155.global_check then
		c55795155.global_check=true
		-- 这个卡名的①②③的效果1回合各能使用1次。自己把额外卡组的里侧的灵摆怪兽特殊召唤的回合的自己主要阶段才能发动。进行怪兽的灵摆召唤。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(c55795155.checkop)
		-- 注册全局环境下的事件监听效果，用于记录玩家特殊召唤额外卡组里侧灵摆怪兽的操作。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 过滤出从额外卡组特殊召唤时原本是里侧表示的灵摆怪兽。
function c55795155.checkfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsPreviousPosition(POS_FACEDOWN) and c:IsSummonLocation(LOCATION_EXTRA)
end
-- 遍历特殊召唤成功的怪兽，若满足条件则为对应的召唤玩家注册全局标识。
function c55795155.checkop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c55795155.checkfilter,nil)
	local tc=g:GetFirst()
	while tc do
		-- 为进行特殊召唤的玩家注册本回合有效的标识效果，用于标记该玩家本回合已特殊召唤过额外卡组里侧的灵摆怪兽。
		Duel.RegisterFlagEffect(tc:GetSummonPlayer(),55795155,RESET_PHASE+PHASE_END,0,1)
		tc=g:GetNext()
	end
end
-- 过滤手卡中可以作为发动成本送回卡组的灵摆怪兽，且卡组中存在与之卡名不同、攻击力为2500的灵摆怪兽。
function c55795155.cfilter(c,tp)
	return c:IsType(TYPE_PENDULUM) and c:IsAbleToDeckAsCost()
		-- 检查卡组中是否存在与该卡卡名不同、攻击力为2500且可加入手卡的灵摆怪兽。
		and Duel.IsExistingMatchingCard(c55795155.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
-- 过滤卡组中与指定卡名不同、攻击力为2500且可加入手卡的灵摆怪兽。
function c55795155.thfilter(c,code)
	return c:IsType(TYPE_PENDULUM) and c:IsAttack(2500) and not c:IsCode(code) and c:IsAbleToHand()
end
-- 效果①的发动准备与可行性检测函数。
function c55795155.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查手卡中是否存在满足发动成本条件的灵摆怪兽。
		and Duel.IsExistingMatchingCard(c55795155.cfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 向对方玩家提示当前发动的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置选择提示信息为“请选择要返回卡组的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择手卡中1只满足条件的灵摆怪兽作为发动成本。
	local g=Duel.SelectMatchingCard(tp,c55795155.cfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	e:SetLabel(g:GetFirst():GetCode())
	-- 给对方玩家确认选择的卡片。
	Duel.ConfirmCards(1-tp,g)
	-- 将选择的怪兽作为发动成本送回卡组并洗牌。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
	-- 设置当前连锁的处理信息为“从卡组将1张卡加入手卡”。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理函数（从卡组检索攻击力2500的灵摆怪兽）。
function c55795155.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置选择提示信息为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只与送回卡组的怪兽卡名不同且攻击力为2500的灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,c55795155.thfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	if g:GetCount()>0 then
		-- 将选择的怪兽加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动条件检测函数。
function c55795155.pcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家本回合是否已特殊召唤过额外卡组里侧的灵摆怪兽。
	return Duel.GetFlagEffect(tp,55795155)>0
end
-- 效果②的发动准备与可行性检测函数（模拟灵摆召唤的可行性）。
function c55795155.ptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		-- 获取自己左侧灵摆区域的卡片。
		local lpz=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
		-- 获取自己右侧灵摆区域的卡片。
		local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
		if lpz==nil or rpz==nil then return false end
		local loc=0
		-- 若主怪兽区域有空位，则将手卡纳入可选召唤来源。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_HAND end
		-- 若额外卡组怪兽出场区域有空位，则将额外卡组纳入可选召唤来源。
		if Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)>0 then loc=loc+LOCATION_EXTRA end
		if loc==0 then return false end
		-- ②：自己把额外卡组的里侧的灵摆怪兽特殊召唤的回合的自己主要阶段才能发动。进行怪兽的灵摆召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_EXTRA_PENDULUM_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		-- 设置额外灵摆召唤权效果的适用条件为无特殊限制（始终成立）。
		e1:SetValue(aux.TRUE)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 临时为玩家注册额外灵摆召唤权，以便后续进行灵摆召唤可行性检测。
		Duel.RegisterEffect(e1,tp)
		local eset={e1}
		local lscale=lpz:GetLeftScale()
		local rscale=rpz:GetRightScale()
		if lscale>rscale then lscale,rscale=rscale,lscale end
		-- 获取指定召唤来源区域（手卡和/或额外卡组）的所有卡片。
		local g=Duel.GetFieldGroup(tp,loc,0)
		-- 检测这些卡片中是否存在至少1张满足当前灵摆刻度及额外灵摆召唤条件的怪兽。
		local res=g:IsExists(aux.PConditionFilter,1,nil,e,tp,lscale,rscale,eset)
		e1:Reset()
		return res
	end
	-- 向对方玩家提示当前发动的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果②的效果处理函数（执行一次手卡/额外卡组的灵摆召唤）。
function c55795155.pop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 进行怪兽的灵摆召唤。 / ③：以自己场上1只「霸王龙 扎克」为对象才能发动。这个回合，那只怪兽可以向对方怪兽全部各作1次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_PENDULUM_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	-- 设置额外灵摆召唤权效果的适用条件为无特殊限制（始终成立）。
	e1:SetValue(aux.TRUE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 临时为玩家注册额外灵摆召唤权，以执行本次灵摆召唤。
	Duel.RegisterEffect(e1,tp)
	local eset={e1}
	-- 获取自己左侧灵摆区域的卡片。
	local lpz=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	-- 获取自己右侧灵摆区域的卡片。
	local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	local lscale=lpz:GetLeftScale()
	local rscale=rpz:GetRightScale()
	if lscale>rscale then lscale,rscale=rscale,lscale end
	local loc=0
	-- 获取主怪兽区域的可用空格数。
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取额外卡组灵摆怪兽出场所需的可用空格数。
	local ft2=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)
	-- 获取玩家场上可用的怪兽区域总数。
	local ft=Duel.GetUsableMZoneCount(tp)
	-- 检测是否存在限制从额外卡组特殊召唤数量的效果。
	local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
	if ect and ect<ft2 then ft2=ect end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then
		if ft1>0 then ft1=1 end
		if ft2>0 then ft2=1 end
		ft=1
	end
	if ft1>0 then loc=loc|LOCATION_HAND end
	if ft2>0 then loc=loc|LOCATION_EXTRA end
	-- 筛选出符合当前灵摆刻度及灵摆召唤条件的所有怪兽。
	local tg=Duel.GetMatchingGroup(aux.PConditionFilter,tp,loc,0,nil,e,tp,lscale,rscale,eset)
	-- 进一步过滤出满足本次额外灵摆召唤效果限制的怪兽。
	tg=tg:Filter(aux.PConditionExtraFilterSpecific,nil,e,tp,lscale,rscale,e1)
	-- 设置选择提示信息为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 设置多选时的数量校验函数，确保选择的怪兽数量不超过各区域的限制。
	aux.GCheckAdditional=aux.PendOperationCheck(ft1,ft2,ft)
	-- 让玩家选择要进行灵摆召唤的怪兽组合。
	local g=tg:SelectSubGroup(tp,aux.TRUE,false,1,math.min(#tg,ft))
	-- 重置多选数量校验函数。
	aux.GCheckAdditional=nil
	if not g then
		e1:Reset()
		return
	end
	local sg=Group.CreateGroup()
	sg:Merge(g)
	-- 闪烁显示左侧灵摆区域的卡片，表示其参与了灵摆召唤。
	Duel.HintSelection(Group.FromCards(lpz))
	-- 闪烁显示右侧灵摆区域的卡片，表示其参与了灵摆召唤。
	Duel.HintSelection(Group.FromCards(rpz))
	-- 触发灵摆召唤成功的事件时点。
	Duel.RaiseEvent(sg,EVENT_SPSUMMON_SUCCESS_G_P,e,REASON_EFFECT,tp,tp,0)
	-- 将选择的怪兽以灵摆召唤的方式特殊召唤到场上。
	Duel.SpecialSummon(sg,SUMMON_TYPE_PENDULUM,tp,tp,true,true,POS_FACEUP)
	e1:Reset()
end
-- 效果③的发动条件检测函数（必须能进入战斗阶段）。
function c55795155.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否可以进入战斗阶段。
	return Duel.IsAbleToEnterBP()
end
-- 过滤自己场上表侧表示的「霸王龙 扎克」。
function c55795155.atkfilter(c)
	return c:IsCode(13331639) and c:IsFaceup()
end
-- 效果③的发动准备与目标选择函数。
function c55795155.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsCode(13331639) and chkc:IsFaceup() end
	-- 检查自己场上是否存在可以作为效果对象的表侧表示「霸王龙 扎克」。
	if chk==0 then return Duel.IsExistingTarget(c55795155.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向对方玩家提示当前发动的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置选择提示信息为“请选择表侧表示的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「霸王龙 扎克」作为效果对象。
	Duel.SelectTarget(tp,c55795155.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果③的效果处理函数（赋予目标怪兽向对方全体怪兽各作1次攻击的效果）。
function c55795155.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，那只怪兽可以向对方怪兽全部各作1次攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ATTACK_ALL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
