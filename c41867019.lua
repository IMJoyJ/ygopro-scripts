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
	-- 效果原文内容：①：从额外卡组以外有不死族同调怪兽特殊召唤的场合才能发动（伤害步骤也能发动）。从以下效果选1个适用。这个回合，自己的「魔妖游行」的效果不能有相同效果适用。
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
-- 效果作用：过滤满足条件的同调怪兽（不死族、场上正面表示、非从额外卡组召唤）
function c41867019.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_ZOMBIE) and not c:IsSummonLocation(LOCATION_EXTRA)
end
-- 效果作用：过滤满足条件的魔妖魔法/陷阱卡（魔妖卡组、魔法陷阱类型、可以盖放、非魔妖游行）
function c41867019.setfilter(c)
	return c:IsSetCard(0x121) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable() and not c:IsCode(41867019)
end
-- 效果作用：过滤满足条件的场上怪兽（正面表示、可以送去墓地）
function c41867019.tgfilter(c)
	return c:IsFaceup() and c:IsAbleToGrave()
end
-- 效果作用：判断是否有满足条件的同调怪兽被特殊召唤（从额外卡组以外）
function c41867019.effcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c41867019.cfilter,1,nil)
end
-- 效果作用：判断是否可以发动魔妖游行的效果（抽卡、盖放魔陷、送去墓地、造成伤害）
function c41867019.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 效果作用：判断是否已注册魔妖游行的标识效果
		if Duel.GetFlagEffect(tp,41867019)==0 then
			-- 效果作用：注册魔妖游行的标识效果（在回合结束时重置）
			Duel.RegisterFlagEffect(tp,41867019,RESET_PHASE+PHASE_END,0,1)
		end
		-- 效果作用：获取魔妖游行标识效果的Label值
		local flag=Duel.GetFlagEffectLabel(tp,41867019)
		-- 效果作用：判断是否可以抽卡且未使用过抽卡效果
		local b1=Duel.IsPlayerCanDraw(tp,1) and bit.band(flag,0x1)==0
		-- 效果作用：判断是否可以盖放魔妖魔法/陷阱卡且未使用过盖放效果
		local b2=Duel.IsExistingMatchingCard(c41867019.setfilter,tp,LOCATION_DECK,0,1,nil) and bit.band(flag,0x2)==0
		-- 效果作用：判断是否可以送去墓地且未使用过送去墓地效果
		local b3=Duel.IsExistingMatchingCard(c41867019.tgfilter,tp,0,LOCATION_MZONE,1,nil) and bit.band(flag,0x4)==0
		local b4=bit.band(flag,0x8)==0
		return b1 or b2 or b3 or b4
	end
end
-- 效果原文内容：●自己从卡组抽1张。●从卡组选「魔妖游行」以外的1张「魔妖」魔法·陷阱卡在自己场上盖放。●对方场上1只攻击力最低的怪兽送去墓地。●给与对方800伤害。
function c41867019.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果作用：判断是否已注册魔妖游行的标识效果
	if Duel.GetFlagEffect(tp,41867019)==0 then
		-- 效果作用：注册魔妖游行的标识效果（在回合结束时重置）
		Duel.RegisterFlagEffect(tp,41867019,RESET_PHASE+PHASE_END,0,1)
	end
	-- 效果作用：获取魔妖游行标识效果的Label值
	local flag=Duel.GetFlagEffectLabel(tp,41867019)
	local off=1
	local ops={}
	local opval={}
	-- 效果作用：判断是否可以抽卡且未使用过抽卡效果
	local b1=Duel.IsPlayerCanDraw(tp,1) and bit.band(flag,0x1)==0
	-- 效果作用：判断是否可以盖放魔妖魔法/陷阱卡且未使用过盖放效果
	local b2=Duel.IsExistingMatchingCard(c41867019.setfilter,tp,LOCATION_DECK,0,1,nil) and bit.band(flag,0x2)==0
	-- 效果作用：判断是否可以送去墓地且未使用过送去墓地效果
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
	-- 效果作用：让玩家选择一个效果
	local op=Duel.SelectOption(tp,table.unpack(ops))
	local sel=opval[op]
	if sel==1 then
		-- 效果作用：让玩家抽一张卡
		Duel.Draw(tp,1,REASON_EFFECT)
		-- 效果作用：设置标识效果Label为已使用抽卡效果
		Duel.SetFlagEffectLabel(tp,41867019,flag|0x1)
	elseif sel==2 then
		-- 效果作用：提示玩家选择要盖放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 效果作用：选择满足条件的魔妖魔法/陷阱卡
		local g=Duel.SelectMatchingCard(tp,c41867019.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			-- 效果作用：将选中的卡在自己场上盖放
			Duel.SSet(tp,g)
		end
		-- 效果作用：设置标识效果Label为已使用盖放效果
		Duel.SetFlagEffectLabel(tp,41867019,flag|0x2)
	elseif sel==3 then
		-- 效果作用：获取对方场上的满足条件的怪兽
		local g=Duel.GetMatchingGroup(c41867019.tgfilter,tp,0,LOCATION_MZONE,nil)
		if #g>0 then
			local tg=g:GetMinGroup(Card.GetAttack)
			if #tg>1 then
				-- 效果作用：提示玩家选择要送去墓地的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
				local sg=tg:Select(tp,1,1,nil)
				-- 效果作用：显示被选中的卡
				Duel.HintSelection(sg)
				-- 效果作用：将选中的卡送去墓地
				Duel.SendtoGrave(sg,REASON_EFFECT)
			else
				-- 效果作用：将满足条件的怪兽送去墓地
				Duel.SendtoGrave(tg,REASON_EFFECT)
			end
		end
		-- 效果作用：设置标识效果Label为已使用送去墓地效果
		Duel.SetFlagEffectLabel(tp,41867019,flag|0x4)
	else
		-- 效果作用：给与对方800伤害
		Duel.Damage(1-tp,800,REASON_EFFECT)
		-- 效果作用：设置标识效果Label为已使用伤害效果
		Duel.SetFlagEffectLabel(tp,41867019,flag|0x8)
	end
end
