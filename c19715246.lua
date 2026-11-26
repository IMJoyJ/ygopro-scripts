--サイバー・ヨルムンガンド
-- 效果：
-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：对方场上有怪兽存在的场合才能发动。这张卡从手卡特殊召唤。那之后，从卡组选1只「电子龙」特殊召唤或当作装备魔法卡使用给这张卡装备。这个回合，自己不是机械族怪兽不能特殊召唤。
-- ②：让自己场上1张「电子龙」回到手卡才能发动。从自己的卡组·墓地把1张「融合」加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果：登记卡名记载列表，注册特殊召唤限制、①手卡特召并从卡组调出「电子龙」效果，以及②弹回「电子龙」检索「融合」效果
function s.initial_effect(c)
	-- 记录此卡效果文本中记述有「电子龙」和「融合」的卡名
	aux.AddCodeList(c,70095154,24094653)
	-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	-- 这个卡名的①②的效果1回合各能使用1次。①：对方场上有怪兽存在的场合才能发动。这张卡从手卡特殊召唤。那之后，从卡组选1只「电子龙」特殊召唤或当作装备魔法卡使用给这张卡装备。这个回合，自己不是机械族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：让自己场上1张「电子龙」回到手卡才能发动。从自己的卡组·墓地把1张「融合」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 限制此卡只能通过诱发/起动等进入连锁的卡片效果特殊召唤（排除规则手续特召与通常召唤）
function s.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
-- 检查①效果发动条件：对方怪兽区存在至少1只怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方怪兽区的怪兽数量是否大于0
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 过滤卡组中可特殊召唤（按检测阶段区分1格或2格空位及2次特召限制）或可作为装备卡放置到魔陷区的「电子龙」
function s.eqfilter(c,e,tp,chk)
	return c:IsCode(70095154)
		and (c:IsCanBeSpecialSummoned(e,0,tp,false,false) and
			-- 在效果处理阶段（chk为false）检查己方怪兽区是否至少有1个空位
			(not chk and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 在发动检测阶段（chk为true）检查己方本回合还能进行2次特殊召唤且怪兽区空位大于1
			or chk and Duel.IsPlayerCanSpecialSummonCount(tp,2) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1)
		-- 或者检查己方魔陷区是否有空位且该「电子龙」可合法表侧置于场上装备
		or Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:CheckUniqueOnField(tp) and not c:IsForbidden())
end
-- 发动前确认己方怪兽区有空位、此卡可从手卡特召，且卡组存在满足特召或装备条件的「电子龙」
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动前确认己方怪兽区至少有1个可用空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查己方卡组是否存在至少1只满足后续特召或装备条件的「电子龙」
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK,0,1,nil,e,tp,true) end
	-- 登记将此卡自身特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：先特召此卡，再从卡组选1只「电子龙」由玩家决定特召或作为装备魔法卡装备给此卡，最后无论是否成功都施加本回合只能特召机械族怪兽的限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡仍在当前连锁中并将此卡表侧表示特殊召唤到己方场上
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 向己方发送从卡组选择要操作的「电子龙」的提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 让己方从卡组选择1只满足特殊召唤或装备条件的「电子龙」
		local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,false)
		local tc=g:GetFirst()
		if tc then
			-- 判定当前是否满足将选中的「电子龙」特殊召唤到怪兽区的条件
			local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 判定当前是否满足将选中的「电子龙」作为装备卡置入魔陷区的条件
			local b2=Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and tc:CheckUniqueOnField(tp) and not tc:IsForbidden()
			local op=0
			if b1 and not b2 then op=1 end
			if b2 and not b1 then op=2 end
			if b1 and b2 then
				-- 当特殊召唤与装备两个选项均可行时，让己方玩家从中选择一种处理方式
				op=aux.SelectFromOptions(tp,
					{b1,1152,1},
					{b2,1068,2})
			end
			-- 插入效果处理间断，使此卡的特召与后续「电子龙」的处理视为不同时处理
			Duel.BreakEffect()
			if op==1 then
				-- 将选中的「电子龙」以表侧表示特殊召唤到己方场上
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			elseif op==2 then
				-- 将选中的「电子龙」作为装备魔法卡装备给此卡
				Duel.Equip(tp,tc,c)
				-- 当作装备魔法卡使用给这张卡装备。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(s.eqlimit)
				tc:RegisterEffect(e1)
			end
		end
	end
	-- 这个回合，自己不是机械族怪兽不能特殊召唤。②：让自己场上1张「电子龙」回到手卡才能发动。从自己的卡组·墓地把1张「融合」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit2)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为己方玩家注册持续至回合结束的特殊召唤种族自肃效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件函数：禁止特殊召唤机械族以外的怪兽
function s.splimit2(e,c)
	return not c:IsRace(RACE_MACHINE)
end
-- 装备对象限制函数：限定该装备卡只能装备于效果创建者（即「电子世界蛇」）
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 过滤己方场上表侧表示、卡名为「电子龙」且可以作为代价返回手卡的卡
function s.costfilter(c)
	return c:IsFaceup() and c:IsCode(70095154) and c:IsAbleToHandAsCost()
end
-- 支付②效果的发动代价：选择己方场上1张表侧表示的「电子龙」返回手卡
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前确认己方场上是否存在至少1张可作为代价回到手卡的表侧「电子龙」
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 向己方发送选择要返回手卡的卡片的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让己方从己方场上选择1张表侧表示的「电子龙」
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 向双方展示被选为返回手卡代价的卡片动画
	Duel.HintSelection(g)
	-- 将选中的「电子龙」作为发动代价送回持有者手卡
	Duel.SendtoHand(g,nil,REASON_COST)
end
-- 过滤卡名为「融合」且可以加入手卡的卡片
function s.thfilter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- 发动前确认己方卡组或墓地存在「融合」并登记加入手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方卡组和墓地中是否存在至少1张可加入手卡的「融合」
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 登记将1张卡从己方卡组或墓地加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ②效果处理：从己方卡组或墓地选1张「融合」加入手卡并向对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向己方发送选择要加入手卡的卡片的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 受「王家长眠之谷」判定过滤后，从己方卡组或墓地选择1张「融合」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「融合」以效果加入持有者手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的「融合」进行确认
		Duel.ConfirmCards(1-tp,g)
	end
end
