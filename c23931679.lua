--海竜神－リバイアサン
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要场上有「海」存在，水属性以外的表侧表示怪兽在双方场上各自只能有1只存在（双方玩家在自身场上有水属性以外的表侧表示怪兽2只以上存在的场合，直到变成1只为止必须送去墓地）。
-- ②：自己主要阶段才能发动。从卡组把以下的卡之内任意1张加入手卡。
-- ●「海」
-- ●「海龙神」魔法·陷阱卡
-- ●「潜海」魔法·陷阱卡
function c23931679.initial_effect(c)
	-- 将该卡视为记载了「海」的卡名（卡号22702055），用于配合字段相关效果的识别与检索。
	aux.AddCodeList(c,22702055)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己主要阶段才能发动。从卡组把以下的卡之内任意1张加入手卡。●「海」●「利维坦」魔法·陷阱卡●「潜海」魔法·陷阱卡
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,23931679)
	e1:SetTarget(c23931679.thtg)
	e1:SetOperation(c23931679.thop)
	c:RegisterEffect(e1)
	-- ①：只要场上有「海」存在，水属性以外的表侧表示怪兽在双方场上各自只能有1只存在
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(23931679)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetCondition(c23931679.condition)
	c:RegisterEffect(e2)
	-- 水属性以外的表侧表示怪兽在双方场上各自只能有1只存在
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCondition(c23931679.condition)
	e3:SetTargetRange(1,1)
	e3:SetTarget(c23931679.sumlimit)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e5)
	if not c23931679.global_check then
		c23931679.global_check=true
		-- （双方玩家在自身场上有水属性以外的表侧表示怪兽2只以上存在的场合，直到变成1只为止必须送去墓地）
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetOperation(c23931679.adjustop)
		-- 将全局调整效果ge1注册进游戏（不限定玩家），使每次状态调整时自动检查并处理场上非水属性表侧表示怪兽数量超标的问题。
		Duel.RegisterEffect(ge1,0)
	end
end
c23931679[0]=0
c23931679[1]=0
-- 检索过滤：选择卡名为「海」（22702055）的卡，或卡名包含「利维坦」（0x177）或「潜海」（0x178）的魔法·陷阱卡，且这张卡能够加入手卡。
function c23931679.thfilter(c)
	return (c:IsCode(22702055) or c:IsSetCard(0x177,0x178) and c:IsType(TYPE_SPELL+TYPE_TRAP)) and c:IsAbleToHand()
end
-- ②效果的发动条件检测及操作信息登记：若卡组中存在满足检索条件的卡，则登记“从卡组将卡加入手卡”的处理信息。
function c23931679.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查时确认卡组中是否存在至少1张满足条件的卡，若不存在则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c23931679.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向连锁系统登记本次处理会将1张卡从卡组加入手卡（操作对象为当前玩家、区域为卡组），便于其他卡片进行对应判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的实际处理：从卡组选择1张符合条件的卡加入手卡，并展示给对手确认。
function c23931679.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给当前玩家显示选择提示，要求其选择一张要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让当前玩家从卡组中筛选并选择1张满足thfilter条件的卡，结果存入g。
	local g=Duel.SelectMatchingCard(tp,c23931679.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对手玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果适用条件的检测函数：仅当场上存在「海」时，该限制效果才适用。
function c23931679.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前环境是否存在场地魔法「海」（卡号22702055），返回真则环境有效。
	return Duel.IsEnvironment(22702055)
end
-- 召唤限制函数：当sumpos为里侧表示时允许；若被召唤怪兽是非水属性且该玩家已有1只非水属性表侧表示怪兽，则禁止该怪兽以表侧表示出场。
function c23931679.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	if sumpos and bit.band(sumpos,POS_FACEDOWN)>0 then return false end
	return c:IsNonAttribute(ATTRIBUTE_WATER) and c23931679[targetp or sump]==1
end
-- 过滤出表侧表示且属性不是水属性的怪兽，用于统计场上非水属性表侧表示怪兽的数量。
function c23931679.wtfilter(c)
	return c:IsNonAttribute(ATTRIBUTE_WATER) and c:IsFaceup()
end
-- 判断怪兽属性是否等于指定属性at，用于在子组选择中识别水属性怪兽。
function c23931679.rmfilter(c,at)
	return c:GetAttribute()==at
end
-- 子组选择规则：从当前组g中选出#g-1张卡，使剩余1张不是水属性，从而保证只保留1只非水属性怪兽（若原本就超过1只则通过玩家选择留下哪只）。
function c23931679.tgselect(sg,g)
	return #(g-sg)==1 and not sg:IsExists(c23931679.rmfilter,1,nil,ATTRIBUTE_WATER)
end
-- 状态调整处理函数：当①效果适用时，检查双方场上非水属性表侧表示怪兽数量，若某方超过1只，则让该玩家选择保留1只，其余规则送去墓地。
function c23931679.adjustop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果没有任何玩家受到23931679效果（即海龙神①效果不在适用中），则重置双方非水属性计数标记并结束。
	if not Duel.IsPlayerAffectedByEffect(0,23931679) then
		c23931679[0]=0
		c23931679[1]=0
		return
	end
	-- 获取当前游戏阶段，用于在伤害阶段中避免不必要的调整处理。
	local phase=Duel.GetCurrentPhase()
	-- 伤害步骤尚未计算伤害、或正处于伤害计算阶段时跳过调整，防止干扰战斗伤害结算。
	if (phase==PHASE_DAMAGE and not Duel.IsDamageCalculated()) or phase==PHASE_DAMAGE_CAL then return end
	-- 取得当前玩家tp场上所有非水属性表侧表示怪兽，作为需要检查的数量来源。
	local g1=Duel.GetMatchingGroup(c23931679.wtfilter,tp,LOCATION_MZONE,0,nil)
	-- 取得对方玩家（1-tp）场上所有非水属性表侧表示怪兽，作为需要检查的数量来源。
	local g2=Duel.GetMatchingGroup(c23931679.wtfilter,tp,0,LOCATION_MZONE,nil)
	local c=e:GetHandler()
	if g1:GetCount()==0 then c23931679[tp]=0
	else
		-- 给当前玩家显示“请选择要送去墓地的卡”的提示，用于选择要保留以外的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g1:SelectSubGroup(tp,c23931679.tgselect,false,#g1-1,#g1-1,g1)
		if sg then
			g1:Sub(g1-sg)
		else
			g1:Sub(g1)
		end
		c23931679[tp]=1
	end
	if g2:GetCount()==0 then c23931679[1-tp]=0
	else
		-- 给对方玩家显示“请选择要送去墓地的卡”的提示，用于选择要保留以外的怪兽。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g2:SelectSubGroup(1-tp,c23931679.tgselect,false,#g2-1,#g2-1,g2)
		if sg then
			g2:Sub(g2-sg)
		else
			g2:Sub(g2)
		end
		c23931679[1-tp]=1
	end
	g1:Merge(g2)
	if g1:GetCount()>0 then
		-- 将双方场上被选为多余的非水属性表侧表示怪兽以规则效果送去墓地，以实现“直到变成1只为止必须送去墓地”。
		Duel.SendtoGrave(g1,REASON_RULE)
		-- 刷新场上卡片状态，让后续效果判定和游戏状态重新整合，避免因本次送墓造成状态不一致。
		Duel.Readjust()
	end
end
