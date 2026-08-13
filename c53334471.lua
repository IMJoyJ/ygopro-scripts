--御前試合
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，双方场上各自只能有1种类的属性的怪兽表侧表示存在。双方玩家在自身场上的表侧表示怪兽的属性是2种类以上的场合直到变成1种类为止必须送去墓地。
function c53334471.initial_effect(c)
	-- ①：只要这张卡在魔法与陷阱区域存在，双方场上各自只能有1种类的属性的怪兽表侧表示存在。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(c53334471.acttg)
	c:RegisterEffect(e1)
	-- 双方玩家在自身场上的表侧表示怪兽的属性是2种类以上的场合直到变成1种类为止必须送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c53334471.adjustop)
	c:RegisterEffect(e2)
	-- 双方场上各自只能有1种类的属性的怪兽表侧表示存在。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,1)
	e4:SetTarget(c53334471.sumlimit)
	c:RegisterEffect(e4)
	-- 双方场上各自只能有1种类的属性的怪兽表侧表示存在。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EFFECT_CANNOT_SUMMON)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTargetRange(1,1)
	e5:SetTarget(c53334471.sumlimit)
	c:RegisterEffect(e5)
	-- 双方场上各自只能有1种类的属性的怪兽表侧表示存在。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetTargetRange(1,1)
	e6:SetTarget(c53334471.sumlimit)
	c:RegisterEffect(e6)
end
c53334471[0]=0
c53334471[1]=0
-- 发动魔法卡时将双方的属性记录清零，并允许该卡发动入连锁；后续调整时以此为初始状态。
function c53334471.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	c53334471[0]=0
	c53334471[1]=0
end
-- 筛选场上表侧表示且效果处于有效状态的怪兽，用于确定需要参与属性限制检查的怪兽。
function c53334471.limfilter(c)
	return c:IsFaceup() and c:IsStatus(STATUS_EFFECT_ENABLED)
end
-- 判断是否允许进行召唤/特殊召唤/反转召唤：里侧表示不允许；若己方场上没有表侧有效怪兽则允许；否则仅允许召唤与己方场上属性相同的怪兽（若不同则禁止）。
function c53334471.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	if sumpos and bit.band(sumpos,POS_FACEDOWN)>0 then return false end
	-- 取得目标玩家场上所有表侧有效怪兽，并计算这些怪兽的属性组合掩码。
	local at=c53334471.getattribute(Duel.GetMatchingGroup(c53334471.limfilter,targetp or sump,LOCATION_MZONE,0,nil))
	if at==0 then return false end
	return c:GetAttribute()~=at
end
-- 遍历怪兽组，将所有怪兽的属性按位或运算合并为一个属性掩码；多属性怪兽会包含多个属性位。
function c53334471.getattribute(g)
	local aat=0
	local tc=g:GetFirst()
	while tc do
		aat=bit.bor(aat,tc:GetAttribute())
		tc=g:GetNext()
	end
	return aat
end
-- 判断怪兽属性是否等于指定属性at，用于从组中移除需要保留属性的怪兽，剩余怪兽将被送去墓地。
function c53334471.rmfilter(c,at)
	return c:GetAttribute()==at
end
-- 判断属性掩码是否只包含单一属性，即是否为2的幂（val&(val-1)==0）。
function c53334471.isonlyone(val)
	return val&(val-1)==0
end
-- 选卡完成条件：选择要送墓的卡后，剩余怪兽的属性只剩一种，且已选卡中没有与该剩余属性相同的卡。
function c53334471.tgselect(sg,g)
	local att=c53334471.getattribute(g-sg)
	return att>0 and c53334471.isonlyone(att) and not sg:IsExists(c53334471.rmfilter,1,nil,att)
end
-- 调整处理前半部分：在安全时点对当前玩家场上的表侧怪兽进行属性检查；若属性不唯一，让该玩家选择保留哪种属性（通过选择要送墓的卡），并更新该玩家的记录属性。
function c53334471.adjustop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段，用于判断是否适合执行调整处理。
	local phase=Duel.GetCurrentPhase()
	-- 伤害步骤尚未计算伤害前或伤害计算时跳过调整，避免在伤害计算过程中移动卡片造成混乱。
	if (phase==PHASE_DAMAGE and not Duel.IsDamageCalculated()) or phase==PHASE_DAMAGE_CAL then return end
	-- 获取当前玩家自己场上所有表侧表示怪兽的集合g1。
	local g1=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	-- 获取当前玩家对方场上所有表侧表示怪兽的集合g2。
	local g2=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local c=e:GetHandler()
	if g1:GetCount()==0 then c53334471[tp]=0
	else
		local att=c53334471.getattribute(g1)
		if not c53334471.isonlyone(att) then
			if c53334471[tp]==0 or bit.band(c53334471[tp],att)==0 then
				-- 向当前玩家显示“请选择要送去墓地的卡”的选择提示。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
				local sg=g1:SelectSubGroup(tp,c53334471.tgselect,false,1,#g1,g1)
				if not sg then
					att=0
				else
					att=c53334471.getattribute(g1-sg)
				end
			else att=c53334471[tp] end
		end
		g1:Remove(c53334471.rmfilter,nil,att)
		c53334471[tp]=att
	end
	if g2:GetCount()==0 then c53334471[1-tp]=0
	else
		local att=c53334471.getattribute(g2)
		if not c53334471.isonlyone(att) then
			if c53334471[1-tp]==0 or bit.band(c53334471[1-tp],att)==0 then
				-- 向对方玩家显示“请选择要送去墓地的卡”的选择提示。
				Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
				local sg=g2:SelectSubGroup(1-tp,c53334471.tgselect,false,1,#g2,g2)
				if not sg then
					att=0
				else
					att=c53334471.getattribute(g2-sg)
				end
			else att=c53334471[1-tp] end
		end
		g2:Remove(c53334471.rmfilter,nil,att)
		c53334471[1-tp]=att
	end
	g1:Merge(g2)
	if g1:GetCount()>0 then
		-- 将筛选出的多余属性怪兽以规则原因（REASON_RULE）送去墓地。
		Duel.SendtoGrave(g1,REASON_RULE)
		-- 刷新场上所有卡片的信息状态，以重新评估御前试合的永续限制是否满足。
		Duel.Readjust()
	end
end
