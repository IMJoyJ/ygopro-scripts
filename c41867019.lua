--魔妖遊行
-- 效果：
-- 这个卡名的①的效果在同一连锁上只能发动1次。
-- ①：从额外卡组以外有不死族同调怪兽特殊召唤的场合才能发动（伤害步骤也能发动）。从以下效果选1个适用。这个回合，自己的「魔妖游行」的效果不能有相同效果适用。
-- ●自己从卡组抽1张。
-- ●从卡组选「魔妖游行」以外的1张「魔妖」魔法·陷阱卡在自己场上盖放。
-- ●对方场上1只攻击力最低的怪兽送去墓地。
-- ●给与对方800伤害。
function c41867019.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果在同一连锁上只能发动1次。①：从额外卡组以外有不死族同调怪兽特殊召唤的场合才能发动（伤害步骤也能发动）。从以下效果选1个适用。这个回合，自己的「魔妖游行」的效果不能有相同效果适用。●自己从卡组抽1张。●从卡组选「魔妖游行」以外的1张「魔妖」魔法·陷阱卡在自己场上盖放。●对方场上1只攻击力最低的怪兽送去墓地。●给与对方800伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_TOGRAVE+CATEGORY_DAMAGE+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,41867019+EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(c41867019.effcon)
	e2:SetTarget(c41867019.efftg)
	e2:SetOperation(c41867019.effop)
	c:RegisterEffect(e2)
end
-- 过滤特殊召唤成功的怪兽，要求表侧表示、是不死族同调怪兽，且召唤位置不是额外卡组，即“从额外卡组以外”特殊召唤的不死族同调怪兽。
function c41867019.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_ZOMBIE) and not c:IsSummonLocation(LOCATION_EXTRA)
end
-- 过滤卡组中的卡片，要求卡名含有「魔妖」、是魔法·陷阱卡、可以被盖放，且不是「魔妖游行」自身。
function c41867019.setfilter(c)
	return c:IsSetCard(0x121) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable() and not c:IsCode(41867019)
end
-- 过滤怪兽，要求表侧表示且能被效果送去墓地，用于选取对方场上攻击力最低的怪兽作为送墓对象。
function c41867019.tgfilter(c)
	return c:IsFaceup() and c:IsAbleToGrave()
end
-- 效果发动条件：本次特殊召唤成功的怪兽中存在至少1只满足cfilter过滤条件（表侧不死族同调且非额外卡组）的怪兽。
function c41867019.effcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c41867019.cfilter,1,nil)
end
-- 效果发动时的合法性检测：若本回合尚未记录过本卡效果标志，则先注册一个回合结束重置的标志；随后读取标志值，分别判断抽卡、盖放、送墓、伤害四个选项是否当前可用（未被本回合已适用的选项占用且具备相应条件），返回至少一个可用选项。
function c41867019.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查玩家tp是否已存在卡号41867019对应的回合标志效果（即本回合是否已记录过「魔妖游行」已适用的效果种类）。
		if Duel.GetFlagEffect(tp,41867019)==0 then
			-- 为玩家tp注册一个卡号41867019的回合标志效果，持续到结束阶段重置，用其label的各位来记录本回合已适用的四个选项。
			Duel.RegisterFlagEffect(tp,41867019,RESET_PHASE+PHASE_END,0,1)
		end
		-- 读取该标志效果当前的label数值，该数值的四个二进制位分别代表抽卡、盖放、送墓、伤害效果是否已在本回合适用过。
		local flag=Duel.GetFlagEffectLabel(tp,41867019)
		-- 判定选项“抽1张”是否可用：玩家可以抽卡，且标志位第0位为0（本回合尚未适用过抽卡效果）。
		local b1=Duel.IsPlayerCanDraw(tp,1) and bit.band(flag,0x1)==0
		-- 判定选项“从卡组盖放魔陷”是否可用：卡组中存在符合条件的「魔妖」魔法·陷阱卡，且标志位第1位为0（尚未适用过盖放效果）。
		local b2=Duel.IsExistingMatchingCard(c41867019.setfilter,tp,LOCATION_DECK,0,1,nil) and bit.band(flag,0x2)==0
		-- 判定选项“对方攻击力最低怪兽送墓”是否可用：对方场上存在表侧表示且能被送去墓地的怪兽，且标志位第2位为0（尚未适用过送墓效果）。
		local b3=Duel.IsExistingMatchingCard(c41867019.tgfilter,tp,0,LOCATION_MZONE,1,nil) and bit.band(flag,0x4)==0
		local b4=bit.band(flag,0x8)==0
		return b1 or b2 or b3 or b4
	end
end
-- 效果处理操作：根据之前选择并记录的可执行选项，让玩家从可用选项中选一个并执行对应处理（抽卡、盖放、送墓、伤害），并用标志位记录该选项本回合已适用，防止相同效果重复适用。
function c41867019.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 在效果处理开始时，再次检查玩家tp是否已有该回合标志效果，防止此前未注册（异常情况）导致后续读取失败。
	if Duel.GetFlagEffect(tp,41867019)==0 then
		-- 确保玩家tp拥有本回合的“魔妖游行”已适用效果记录标志，持续到结束阶段重置。
		Duel.RegisterFlagEffect(tp,41867019,RESET_PHASE+PHASE_END,0,1)
	end
	-- 读取当前标志label，用于在效果处理中判断各选项是否仍未被适用（因目标选择可能发生在同一连锁上，发动时已判断但处理时需再次确认）。
	local flag=Duel.GetFlagEffectLabel(tp,41867019)
	local off=1
	local ops={}
	local opval={}
	-- 处理时判断“抽1张”仍可作为选项：玩家可以抽卡且对应标志位未置位。
	local b1=Duel.IsPlayerCanDraw(tp,1) and bit.band(flag,0x1)==0
	-- 处理时判断“盖放魔陷”仍可作为选项：卡组仍有符合条件的卡且对应标志位未置位。
	local b2=Duel.IsExistingMatchingCard(c41867019.setfilter,tp,LOCATION_DECK,0,1,nil) and bit.band(flag,0x2)==0
	-- 处理时判断“送墓怪兽”仍可作为选项：对方场上仍有符合条件的怪兽且对应标志位未置位。
	local b3=Duel.IsExistingMatchingCard(c41867019.tgfilter,tp,0,LOCATION_MZONE,1,nil) and bit.band(flag,0x4)==0
	local b4=bit.band(flag,0x8)==0
	if b1 then
		ops[off]=aux.Stringid(41867019,0)  --"抽1张卡"
		opval[off-1]=1
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(41867019,1)  --"盖放魔陷"
		opval[off-1]=2
		off=off+1
	end
	if b3 then
		ops[off]=aux.Stringid(41867019,2)  --"送去墓地"
		opval[off-1]=3
		off=off+1
	end
	if b4 then
		ops[off]=aux.Stringid(41867019,3)  --"800伤害"
		opval[off-1]=4
		off=off+1
	end
	-- 让玩家从所有当前可用选项中选择一项（通过弹出选项菜单），返回所选项在所选列表中的序号。
	local op=Duel.SelectOption(tp,table.unpack(ops))
	local sel=opval[op]
	if sel==1 then
		-- 执行“抽1张”效果：玩家tp以效果原因抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
		-- 将本回合标志label的0x1位置1，记录“自己从卡组抽1张”效果已经适用过。
		Duel.SetFlagEffectLabel(tp,41867019,flag|0x1)
	elseif sel==2 then
		-- 提示玩家正在进行“选择要盖放的卡”的选择操作，设置选择对话框的消息为设置卡牌。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从玩家卡组中筛选并选择1张满足setfilter条件（「魔妖游行」以外的「魔妖」魔法·陷阱卡）的卡。
		local g=Duel.SelectMatchingCard(tp,c41867019.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			-- 将选择的卡片以里侧表示盖放到玩家tp的魔法·陷阱区。
			Duel.SSet(tp,g)
		end
		-- 将本回合标志label的0x2位置1，记录“从卡组盖放魔陷”效果已经适用过。
		Duel.SetFlagEffectLabel(tp,41867019,flag|0x2)
	elseif sel==3 then
		-- 获取对方场上所有满足tgfilter条件（表侧表示且可送墓）的怪兽组，用于挑出攻击力最低的怪兽。
		local g=Duel.GetMatchingGroup(c41867019.tgfilter,tp,0,LOCATION_MZONE,nil)
		if #g>0 then
			local tg=g:GetMinGroup(Card.GetAttack)
			if #tg>1 then
				-- 提示玩家正在进行“选择要送去墓地的卡”的选择操作，设置选择对话框的消息为送去墓地。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
				local sg=tg:Select(tp,1,1,nil)
				-- 为被选中的怪兽显示被选为对象的动画效果，并记录这些卡被选为对象（广义上）。
				Duel.HintSelection(sg)
				-- 将玩家选择的攻击力最低怪兽之一（因并列攻击力需要选择）以效果原因送去墓地。
				Duel.SendtoGrave(sg,REASON_EFFECT)
			else
				-- 当攻击力最低的怪兽只有一只时，直接将那只怪兽以效果原因送去墓地。
				Duel.SendtoGrave(tg,REASON_EFFECT)
			end
		end
		-- 将本回合标志label的0x4位置1，记录“对方攻击力最低怪兽送去墓地”效果已经适用过。
		Duel.SetFlagEffectLabel(tp,41867019,flag|0x4)
	else
		-- 给与对方玩家800点效果伤害。
		Duel.Damage(1-tp,800,REASON_EFFECT)
		-- 将本回合标志label的0x8位置1，记录“给与对方800伤害”效果已经适用过。
		Duel.SetFlagEffectLabel(tp,41867019,flag|0x8)
	end
end
