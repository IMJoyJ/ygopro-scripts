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
	-- ②：1回合1次，自己场上的原本的种族·属性是机械族·暗属性的怪兽用战斗破坏场上的卡的场合才能发动。从手卡把1只机械族·暗属性怪兽特殊召唤。
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
-- e2的Target筛选函数：判定怪兽是否为机械族且暗属性，只有满足条件的己方怪兽才能获得“不会被战斗破坏”和攻击力上升效果。
function c3113667.indtg(e,c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK)
end
-- e2的Value函数：先判断破坏原因是否为战斗；若是，则通过交换攻击者与攻击目标确保被保护的是己方怪兽，然后若己方因此受到战斗伤害，就给该怪兽附加攻击力上升效果（上升数值为受到的伤害），并返回1使该次战斗破坏被无效；若破坏原因不是战斗或伤害为0则只处理不免疫。
function c3113667.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE)==0 then return 0 end
	local tp=e:GetHandlerPlayer()
	-- 获取当前战斗的攻击怪兽，用于判断战斗对象及计算伤害。
	local a=Duel.GetAttacker()
	local tc=a:GetBattleTarget()
	if tc and tc:IsControler(1-tp) then a,tc=tc,a end
	-- 获取效果控制者在本次战斗中受到的实际战斗伤害数值，用于攻击力上升的数值。
	local dam=Duel.GetBattleDamage(tp)
	if not tc or dam<=0 then return 1 end
	-- 那次战斗让自己受到战斗伤害的场合，攻击力上升那个数值。
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
-- e3的发动条件：检查被战斗破坏的怪兽是否来自对方场地，且其战斗对象是己方场上原本种族为机械、属性为暗的怪兽，以此确认是己方机械族暗属性怪兽通过战斗破坏了对方场上的卡。
function c3113667.spcon1(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local bc=tc:GetBattleTarget()
	return tc:IsPreviousControler(1-tp)
		and bc:IsControler(tp) and bc:GetOriginalAttribute()==ATTRIBUTE_DARK and bc:GetOriginalRace()==RACE_MACHINE
end
-- cfilter筛选函数：判断被破坏的卡是否因效果且从场上被送去墓地，对应“自身的效果破坏场上的卡”中的破坏来源与位置。
function c3113667.cfilter(c)
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- e4的发动条件：确认存在一个由己方在主要怪兽区发动的、原本种族为机械、属性为暗的怪兽效果，并且该效果导致场上的卡被破坏（破坏原因必须是效果），从而满足“自身的效果破坏场上的卡”的触发条件。
function c3113667.spcon2(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	-- 获取当前连锁中触发效果的玩家和触发位置，用于判定触发该次破坏的效果是否为己方怪兽在己方怪兽区发动。
	local tgp,loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION)
	local rc=re:GetHandler()
	return tgp==tp and loc==LOCATION_MZONE
		and rc:GetOriginalAttribute()==ATTRIBUTE_DARK and rc:GetOriginalRace()==RACE_MACHINE
		and eg:IsExists(c3113667.cfilter,1,nil)
end
-- 定义可特殊召唤的怪兽条件：机械族、暗属性，且当前可以被特殊召唤。
function c3113667.spfilter(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动合法性检查：己方主要怪兽区有空位，且手牌存在至少1只符合条件的机械族暗属性怪兽。
function c3113667.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动条件之一：己方主要怪兽区有空余区域，才能进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果发动条件之二：手牌中存在满足机械族、暗属性且可特殊召唤的怪兽卡。
		and Duel.IsExistingMatchingCard(c3113667.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本连锁的效果处理将进行特殊召唤，预定义从手牌特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：先确认己方主要怪兽区仍有空位；然后从手牌选择1只符合条件的机械族暗属性怪兽，以表侧表示特殊召唤到己方场上。
function c3113667.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次检查主要怪兽区是否还有空位，若无空位则效果处理终止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌中选出1张满足条件的机械族暗属性怪兽，选择结果存入g；没有符合条件的卡则g为空。
	local g=Duel.SelectMatchingCard(tp,c3113667.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选出的怪兽以表侧攻击表示特殊召唤到己方场上，由于已在spfilter中检查过召唤条件，这里nocheck/nolimit均填false。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
