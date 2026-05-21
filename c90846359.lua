--群雄割拠
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，双方场上各自只能有1种类的种族的怪兽表侧表示存在。双方玩家在自身场上的表侧表示怪兽的种族是2种类以上的场合直到变成1种类为止必须送去墓地。
function c90846359.initial_effect(c)
	-- ①：只要这张卡在魔法与陷阱区域存在，双方场上各自只能有1种类的种族的怪兽表侧表示存在。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(c90846359.acttg)
	c:RegisterEffect(e1)
	-- 双方玩家在自身场上的表侧表示怪兽的种族是2种类以上的场合直到变成1种类为止必须送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c90846359.adjustop)
	c:RegisterEffect(e2)
	-- 双方场上各自只能有1种类的种族的怪兽表侧表示存在。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,1)
	e4:SetTarget(c90846359.sumlimit)
	c:RegisterEffect(e4)
	-- 双方场上各自只能有1种类的种族的怪兽表侧表示存在。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EFFECT_CANNOT_SUMMON)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTargetRange(1,1)
	e5:SetTarget(c90846359.sumlimit)
	c:RegisterEffect(e5)
	-- 双方场上各自只能有1种类的种族的怪兽表侧表示存在。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetTargetRange(1,1)
	e6:SetTarget(c90846359.sumlimit)
	c:RegisterEffect(e6)
end
c90846359[0]=0
c90846359[1]=0
-- 卡片发动时的效果处理，初始化双方玩家当前场上存在的怪兽种族记录。
function c90846359.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	c90846359[0]=0
	c90846359[1]=0
end
-- 过滤出场上表侧表示且已处于就绪状态（非移动或召唤中）的怪兽。
function c90846359.limfilter(c)
	return c:IsFaceup() and c:IsStatus(STATUS_EFFECT_ENABLED)
end
-- 限制怪兽的召唤、特殊召唤和反转召唤，若场上已有表侧怪兽，则不能召唤不同种族的怪兽。
function c90846359.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	if sumpos and bit.band(sumpos,POS_FACEDOWN)>0 then return false end
	-- 获取当前玩家场上已存在的、处于就绪状态的表侧表示怪兽的种族。
	local rc=c90846359.getrace(Duel.GetMatchingGroup(c90846359.limfilter,targetp or sump,LOCATION_MZONE,0,nil))
	if rc==0 then return false end
	return c:GetRace()~=rc
end
-- 计算并返回传入怪兽组中所有怪兽的种族按位或（OR）组合值。
function c90846359.getrace(g)
	local arc=0
	local tc=g:GetFirst()
	while tc do
		arc=bit.bor(arc,tc:GetRace())
		tc=g:GetNext()
	end
	return arc
end
-- 过滤出种族与指定种族相同的怪兽。
function c90846359.rmfilter(c,rc)
	return c:GetRace()==rc
end
-- 利用位运算判断传入的种族组合值中是否仅包含单一一种种族。
function c90846359.isonlyone(val)
	return val&(val-1)==0
end
-- 筛选出需要送去墓地的怪兽子集，使得剩余的怪兽种族为单一一种，且被送去墓地的怪兽中不包含该剩余种族的怪兽。
function c90846359.tgselect(sg,g)
	local rac=c90846359.getrace(g-sg)
	return rac>0 and c90846359.isonlyone(rac) and not sg:IsExists(c90846359.rmfilter,1,nil,rac)
end
-- 场上状态调整时的操作，检测双方场上怪兽种族，若存在2种以上种族，则强制玩家选择并送去墓地直到只剩1种。
function c90846359.adjustop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的游戏阶段。
	local phase=Duel.GetCurrentPhase()
	-- 若当前处于伤害步骤且未计算伤害，或者是伤害计算时，则不进行调整处理。
	if (phase==PHASE_DAMAGE and not Duel.IsDamageCalculated()) or phase==PHASE_DAMAGE_CAL then return end
	-- 获取自己场上所有表侧表示的怪兽。
	local g1=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	-- 获取对方场上所有表侧表示的怪兽。
	local g2=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local c=e:GetHandler()
	if g1:GetCount()==0 then c90846359[tp]=0
	else
		local rac=c90846359.getrace(g1)
		if bit.band(rac,rac-1)~=0 then
			if c90846359[tp]==0 or bit.band(c90846359[tp],rac)==0 then
				-- 向自己发送提示信息，要求选择要送去墓地的卡。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
				local sg=g1:SelectSubGroup(tp,c90846359.tgselect,false,1,#g1,g1)
				if not sg then
					rac=0
				else
					rac=c90846359.getrace(g1-sg)
				end
			else rac=c90846359[tp] end
		end
		g1:Remove(c90846359.rmfilter,nil,rac)
		c90846359[tp]=rac
	end
	if g2:GetCount()==0 then c90846359[1-tp]=0
	else
		local rac=c90846359.getrace(g2)
		if bit.band(rac,rac-1)~=0 then
			if c90846359[1-tp]==0 or bit.band(c90846359[1-tp],rac)==0 then
				-- 向对方发送提示信息，要求选择要送去墓地的卡。
				Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
				local sg=g2:SelectSubGroup(1-tp,c90846359.tgselect,false,1,#g2,g2)
				if not sg then
					rac=0
				else
					rac=c90846359.getrace(g2-sg)
				end
			else rac=c90846359[1-tp] end
		end
		g2:Remove(c90846359.rmfilter,nil,rac)
		c90846359[1-tp]=rac
	end
	g1:Merge(g2)
	if g1:GetCount()>0 then
		-- 因规则原因将不满足种族单一化条件的怪兽送去墓地。
		Duel.SendtoGrave(g1,REASON_RULE)
		-- 刷新场上的卡片信息，以确保规则调整立即生效。
		Duel.Readjust()
	end
end
