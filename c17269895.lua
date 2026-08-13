--覇者の鳴動
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，在对方把10只以上的怪兽特殊召唤的回合，不能对应这张卡的发动让效果发动。
-- ①：让这个回合对方特殊召唤的怪兽数量的以下效果各适用。
-- ●1只以上：自己的墓地·除外状态的1只暗属性同调怪兽特殊召唤。
-- ●3只以上：直到下次的自己回合的结束时为止的期间，自己的怪兽区域的「红莲魔龙」不受对方发动的效果影响。
-- ●5只以上：对方场上的怪兽全部变成里侧守备表示。
local s,id,o=GetID()
-- 定义卡片的初始化函数：登记「红莲魔龙」关联卡名；创建并注册此卡的魔法卡发动效果（同名卡1回合1次、自由时点发动，发动前进行目标与条件判定，发动后执行效果）；并注册一个全场的特殊召唤成功计数效果，统计本回合双方特殊召唤的怪兽数量。
function s.initial_effect(c)
	-- 将卡号70902743（「红莲魔龙」）登记为效果文本中记载的关联卡名。
	aux.AddCodeList(c,70902743)
	-- 对应效果原文：“这个卡名的卡在1回合只能发动1张，在对方把10只以上的怪兽特殊召唤的回合，不能对应这张卡的发动让效果发动。①：让这个回合对方特殊召唤的怪兽数量的以下效果各适用。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	if not s.global_check then
		s.global_check=true
		-- 对应效果原文：“在对方把10只以上的怪兽特殊召唤的回合，不能对应这张卡的发动让效果发动。①：让这个回合对方特殊召唤的怪兽数量的以下效果各适用。●1只以上：自己的墓地·除外状态的1只暗属性同调怪兽特殊召唤。●3只以上：直到下次的自己回合的结束时为止的期间，自己的怪兽区域的「红莲魔龙」不受对方发动的效果影响。●5只以上：对方场上的怪兽全部变成里侧守备表示。”
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		-- 将全局计数效果注册到全场，使每次怪兽特殊召唤成功时都能触发s.checkop，从而记录特殊召唤次数。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 特殊召唤成功时的计数处理：遍历所有成功特殊召唤的怪兽，为对应的召唤玩家各添加一个本回合特殊召唤数量的标记（阶段结束重置），用于后续判断对方本回合特殊召唤了几只怪兽。
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		-- 为这次特殊召唤的怪兽的召唤玩家添加一个计数标记（标识码id），每次特殊召唤成功都添加1个，从而累计该玩家本回合特殊召唤的怪兽数量。
		Duel.RegisterFlagEffect(tc:GetSummonPlayer(),id,RESET_PHASE+PHASE_END,0,1)
		tc=eg:GetNext()
	end
end
-- 定义暗属性同调怪兽的特殊召唤筛选条件：对象需为表侧表示（墓地/除外中的表侧）、暗属性、同调怪兽，且能够被当前效果特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义可变为里侧守备表示的筛选条件：对象需为表侧表示且允许变成里侧守备表示。
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 效果发动前的条件判定：根据对方本回合特殊召唤数量ct判断是否满足“1只以上”“3只以上”“5只以上”任一分支的可发动条件；只要满足任一分支即可发动；同时设置特殊召唤和位置变更的操作信息；若ct达到10只以上，则设置连锁限制使这张卡不能被连锁。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方玩家（1-tp）本回合已经特殊召唤的怪兽数量（通过之前累计的标记数量得到）。
	local ct=Duel.GetFlagEffect(1-tp,id)
	-- 判定“1只以上”分支的成立条件：对方本回合特殊召唤数不少于1，且自己主要怪兽区域有空位。
	local b1=ct>=1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定“1只以上”分支还需存在满足条件的墓地·除外状态的暗属性同调怪兽可供特殊召唤。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
	-- 判定“3只以上”分支的成立条件：对方本回合特殊召唤数不少于3，且本回合尚未对自己场上的「红莲魔龙」适用过免疫效果（用id+o标记防止重复适用）。
	local b2=ct>=3 and Duel.GetFlagEffect(tp,id+o)==0
	-- 判定“5只以上”分支的成立条件：对方本回合特殊召唤数不少于5，且对方场上有至少1只表侧表示且可变成里侧守备的怪兽。
	local b3=ct>=5 and Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil)
	if chk==0 then return b1 or b2 or b3 end
	-- 设置操作信息：本效果可能从自己墓地·除外区特殊召唤1只怪兽，供其他卡牌效果进行连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	-- 获取对方场上所有满足s.posfilter条件的表侧怪兽，作为“5只以上”分支可能变为里侧守备的对象。
	local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
	if ct>=5 and g:GetCount()>0 then
		-- 设置操作信息：若满足5只以上条件，则将对方场上这些表侧怪兽全部变为里侧守备表示，数量为g中的怪兽数。
		Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
	end
	if ct>=10 and e:IsCostChecked() and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 对方本回合特殊召唤了10只以上怪兽时，设置连锁限制，使所有其他效果都不能连锁这张卡的发动。
		Duel.SetChainLimit(aux.FALSE)
	end
end
-- 效果处理：先处理“1只以上”分支，若条件满足则从自己墓地·除外区选择1只符合条件的暗属性同调怪兽特殊召唤，并标记已处理过。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次获取对方本回合特殊召唤的怪兽数量，用于判断各分支是否执行。
	local ct=Duel.GetFlagEffect(1-tp,id)
	local flag=false
	-- 检查“1只以上”分支：对方本回合特殊召唤数不少于1且自己场上有空位。
	if ct>=1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查“1只以上”分支是否有可特殊召唤的暗属性同调怪兽（追加不受「王家长眠之谷」影响的过滤条件）。
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) then
		-- 发送选择提示消息，提示操作玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让操作玩家从自己墓地·除外区选择1只符合条件的暗属性同调怪兽（并排除受「王家长眠之谷」影响的卡）作为特殊召唤对象。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			flag=true
		end
	end
	-- 判定“3只以上”分支：对方本回合特殊召唤数不少于3，且本回合尚未适用过「红莲魔龙」免疫效果。
	if ct>=3 and Duel.GetFlagEffect(tp,id+o)==0 then
		-- 如果之前已经处理过特殊召唤，则中断效果，使后续的免疫效果与特殊召唤不在同一时点处理。
		if flag then Duel.BreakEffect() end
		flag=true
		-- 对应效果原文：“●3只以上：直到下次的自己回合的结束时为止的期间，自己的怪兽区域的「红莲魔龙」不受对方发动的效果影响。●5只以上：对方场上的怪兽全部变成里侧守备表示。”
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,1))  --"「霸者的鸣动」适用中"
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetTargetRange(LOCATION_MZONE,0)
		-- 设置免疫效果的作用目标：只保护自己场上卡号为70902743的「红莲魔龙」。
		e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,70902743))
		e1:SetValue(s.efilter)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
		-- 将“「红莲魔龙」不受对方发动的效果影响”的免疫效果注册给己方玩家。
		Duel.RegisterEffect(e1,tp)
		-- 给自己玩家注册标记（id+o），表示本回合已经适用过“3只以上”的免疫效果，防止重复适用。
		Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,1)
	end
	if ct>=5 then
		-- 如果前面已经处理过特殊召唤或免疫效果，则中断效果，使“5只以上”的处理与之前分开时点。
		if flag then Duel.BreakEffect() end
		-- 获取对方场上所有满足s.posfilter条件的表侧怪兽。
		local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
		if g:GetCount()>0 then
			-- 再次中断效果，使变更表示形式的处理与前面的处理错开时点。
			Duel.BreakEffect()
			-- 将对方场上的这些表侧怪兽全部变为里侧守备表示。
			Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
		end
	end
end
-- 定义免疫效果的判断函数：仅当效果来自对方玩家且该效果是被发动的效果（进入连锁）时，才对「红莲魔龙」无效。
function s.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActivated()
end
