--鋼鉄の襲撃者
-- 效果：
-- ①：只要这张卡在场地区域存在，自己的机械族·暗属性怪兽在1回合各有1次不会被战斗破坏，那次战斗让自己受到战斗伤害的场合，攻击力上升那个数值。
-- ②：1回合1次，自己场上的原本的种族·属性是机械族·暗属性的怪兽用战斗或者自身的效果破坏场上的卡的场合才能发动。从手卡把1只机械族·暗属性怪兽特殊召唤。
function c3113667.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在场地区域存在，自己的机械族·暗属性怪兽在1回合各有1次不会被战斗破坏，那次战斗让自己受到战斗伤害的场合，攻击力上升那个数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c3113667.indtg)
	e2:SetValue(c3113667.indct)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己场上的原本的种族·属性是机械族·暗属性的怪兽用战斗或者自身的效果破坏场上的卡的场合才能发动。从手卡把1只机械族·暗属性怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(3113667,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e3:SetCondition(c3113667.spcon1)
	e3:SetTarget(c3113667.sptg)
	e3:SetOperation(c3113667.spop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(c3113667.spcon2)
	c:RegisterEffect(e4)
end
-- 过滤函数，判断目标怪兽是否为机械族且暗属性
function c3113667.indtg(e,c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 处理战斗破坏时的攻击力变化效果，若满足条件则为被战斗破坏的怪兽增加相当于其受到伤害值的攻击力
function c3113667.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE)==0 then return 0 end
	local tp=e:GetHandlerPlayer()
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	local tc=a:GetBattleTarget()
	if tc and tc:IsControler(1-tp) then a,tc=tc,a end
	-- 获取本次战斗中玩家受到的伤害值
	local dam=Duel.GetBattleDamage(tp)
	if not tc or dam<=0 then return 1 end
	-- 为被战斗破坏的怪兽增加攻击力，增加数值等于其受到的战斗伤害
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(dam)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	return 1
end
-- 判断是否满足效果发动条件：被战斗破坏的怪兽为己方控制且种族为机械族、属性为暗属性
function c3113667.spcon1(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local bc=tc:GetBattleTarget()
	return tc:IsPreviousControler(1-tp)
		and bc:IsControler(tp) and bc:GetOriginalAttribute()==ATTRIBUTE_DARK and bc:GetOriginalRace()==RACE_MACHINE
end
-- 过滤函数，判断目标卡是否因效果破坏且来自场上
function c3113667.cfilter(c)
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 判断是否满足效果发动条件：被破坏的怪兽为己方控制且种族为机械族、属性为暗属性，且有因效果破坏的卡
function c3113667.spcon2(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	-- 获取当前连锁的触发玩家和触发位置
	local tgp,loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION)
	local rc=re:GetHandler()
	return tgp==tp and loc==LOCATION_MZONE
		and rc:GetOriginalAttribute()==ATTRIBUTE_DARK and rc:GetOriginalRace()==RACE_MACHINE
		and eg:IsExists(c3113667.cfilter,1,nil)
end
-- 过滤函数，判断手卡中是否存在可特殊召唤的机械族暗属性怪兽
function c3113667.spfilter(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的发动条件，检查是否有足够的召唤位置和满足条件的怪兽
function c3113667.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c3113667.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 执行特殊召唤操作，选择并特殊召唤符合条件的怪兽
function c3113667.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c3113667.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
