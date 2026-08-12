--妖精の伝姫
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把同名怪兽不在自己场上存在的手卡1只攻击力1850的魔法师族怪兽给对方观看才能发动。进行那只怪兽的通常召唤。
-- ②：自己场上有原本攻击力是1850的魔法师族怪兽存在，自己因战斗·效果受到伤害的场合，1回合只有1次让那次伤害变成0。
function c91957038.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：把同名怪兽不在自己场上存在的手卡1只攻击力1850的魔法师族怪兽给对方观看才能发动。进行那只怪兽的通常召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,91957038)
	e2:SetCost(c91957038.nscost)
	e2:SetTarget(c91957038.nstg)
	e2:SetOperation(c91957038.nsop)
	c:RegisterEffect(e2)
	-- ②：自己场上有原本攻击力是1850的魔法师族怪兽存在，自己因战斗·效果受到伤害的场合，1回合只有1次让那次伤害变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CHANGE_DAMAGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(1,0)
	e3:SetValue(c91957038.damval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e4:SetCondition(c91957038.damcon)
	c:RegisterEffect(e4)
end
-- 过滤函数：检查场上是否存在表侧表示的同名怪兽
function c91957038.cfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 过滤函数：筛选手卡中满足同名怪兽不在自己场上存在、攻击力1850的魔法师族、可通常召唤的怪兽
function c91957038.nsfilter(c,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttack(1850) and not c:IsPublic() and c:IsSummonable(true,nil)
		-- 检查自己场上是否存在该怪兽的同名怪兽
		and not Duel.IsExistingMatchingCard(c91957038.cfilter,tp,LOCATION_MZONE,0,1,nil,c:GetCode())
end
-- 效果①的Cost：将手卡中1只满足条件的怪兽给对方确认，并将其暂存
function c91957038.nscost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	-- 在发动检查阶段，确认手卡中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c91957038.nsfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家从手卡选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c91957038.nsfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	-- 将选中的怪兽给对方玩家确认
	Duel.ConfirmCards(1-tp,g)
	-- 确认后洗切手卡
	Duel.ShuffleHand(tp)
	e:SetLabelObject(g:GetFirst())
end
-- 效果①的Target：将Cost中展示的怪兽设为效果处理对象，并设置通常召唤的操作信息
function c91957038.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return true
	end
	-- 将Cost中展示并暂存的怪兽设置为本效果的处理对象
	Duel.SetTargetCard(e:GetLabelObject())
	-- 设置操作信息为通常召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果①的Operation：将作为对象的怪兽进行通常召唤或盖放
function c91957038.nsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本效果处理的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if tc:IsSummonable(true,nil) and (not tc:IsMSetable(true,nil)
			-- 若该怪兽无法盖放，或玩家选择以表侧攻击表示召唤
			or Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)==POS_FACEUP_ATTACK) then
			-- 将该怪兽进行表侧表示通常召唤（忽略每回合通常召唤次数限制）
			Duel.Summon(tp,tc,true,nil)
		-- 否则，将该怪兽进行里侧守备表示盖放（忽略每回合通常召唤次数限制）
		else Duel.MSet(tp,tc,true,nil) end
	end
end
-- 过滤函数：筛选自己场上表侧表示的原本攻击力为1850的魔法师族怪兽
function c91957038.damfilter(c)
	return c:GetBaseAttack()==1850 and c:IsRace(RACE_SPELLCASTER) and c:IsFaceup()
end
-- 效果②的条件检查：本回合尚未适用过该免伤效果，且自己场上存在原本攻击力为1850的魔法师族怪兽
function c91957038.damcon(e)
	return e:GetHandler():GetFlagEffect(91957038)==0
		-- 检查自己场上是否存在原本攻击力为1850的魔法师族怪兽
		and Duel.IsExistingMatchingCard(c91957038.damfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 效果②的伤害计算：若受到战斗或效果伤害且满足条件，则将伤害变为0，并注册已适用Flag
function c91957038.damval(e,re,val,r,rp,rc)
	local c=e:GetHandler()
	if bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0 and c91957038.damcon(e) then
		c:RegisterFlagEffect(91957038,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		return 0
	end
	return val
end
