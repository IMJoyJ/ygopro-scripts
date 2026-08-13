--ジャイアント・メサイア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方怪兽的攻击宣言时才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从自己的手卡·墓地选1只昆虫族怪兽当作攻击力·守备力上升500的装备卡使用给这张卡装备。
-- ③：1回合1次，昆虫族怪兽进行战斗的伤害步骤开始时，以自己以及对方场上的卡各1张为对象才能发动。那些卡破坏。
function c39078434.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39078434,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,39078434)
	e1:SetCondition(c39078434.spcon)
	e1:SetTarget(c39078434.sptg)
	e1:SetOperation(c39078434.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从自己的手卡·墓地选1只昆虫族怪兽当作攻击力·守备力上升500的装备卡使用给这张卡装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39078434,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCountLimit(1,39078435)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(c39078434.eqtg)
	e2:SetOperation(c39078434.eqop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：1回合1次，昆虫族怪兽进行战斗的伤害步骤开始时，以自己以及对方场上的卡各1张为对象才能发动。那些卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(39078434,2))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_START)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1)
	e4:SetCondition(c39078434.descon)
	e4:SetTarget(c39078434.destg)
	e4:SetOperation(c39078434.desop)
	c:RegisterEffect(e4)
end
-- ①效果的发动条件：检测当前攻击宣言的怪兽是否为对方控制，若是则条件成立。
function c39078434.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取正在攻击宣言的怪兽，并判定其控制者是否为对方玩家（1-tp）。
	return Duel.GetAttacker():IsControler(1-tp)
end
-- ①效果的发动合法性检查：我方主要怪兽区有空位，且手牌中的这张卡可以特殊召唤。
function c39078434.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查阶段，确认我方主要怪兽区存在可用区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	-- 登记特殊召唤的操作信息，将这张卡作为要特殊召唤的卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联，则将其特殊召唤。
function c39078434.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡不检查召唤条件、不检查苏生限制地以表侧攻击表示特殊召唤到我方场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的装备卡筛选：选择昆虫族怪兽，且该卡满足同名卡限制、不属于禁止卡。
function c39078434.eqfilter(c,tp)
	return c:IsRace(RACE_INSECT) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
-- ②效果发动合法性检查：我方魔陷区有空位，且手牌·墓地中存在符合条件的昆虫族怪兽。
function c39078434.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在合法性检查阶段，确认我方魔陷区存在可用区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并确认手牌·墓地中至少有1只符合条件的昆虫族怪兽存在。
		and Duel.IsExistingMatchingCard(c39078434.eqfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,tp) end
end
-- ②效果处理：确认可用魔陷区且本卡仍可处理时，从手牌·墓地选择昆虫族怪兽，将其作为装备卡装备给本卡，并赋予其攻守上升500的效果及装备对象限制。
function c39078434.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理前再次确认魔陷区仍有空位，否则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 给玩家显示'请选择要装备的卡'的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从手牌·墓地中选取符合条件的昆虫族怪兽（排除受王家长眠之谷影响的卡），由玩家选择1张。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c39078434.eqfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		-- 尝试将选中的怪兽作为装备卡装备给本卡；若失败则终止处理。
		if not Duel.Equip(tp,tc,c) then return end
		-- 当作攻击力·守备力上升500的装备卡使用给这张卡装备
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c39078434.eqlimit)
		tc:RegisterEffect(e1)
		-- 攻击力·守备力上升500
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(500)
		tc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e3)
	end
end
-- 装备限制条件：该装备卡只能装备给效果的所有者（即此卡本身）。
function c39078434.eqlimit(e,c)
	return e:GetOwner()==c
end
-- ③效果的发动条件：我方或对方场上存在表侧表示的昆虫族怪兽正在进行战斗。
function c39078434.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 取得我方和对方各自正在战斗的怪兽（可能为nil）。
	local a,d=Duel.GetBattleMonster(tp)
	return a and a:IsFaceup() and a:IsRace(RACE_INSECT) or d and d:IsFaceup() and d:IsRace(RACE_INSECT)
end
-- ③效果发动合法性检查：我方场上和对方场上各自至少存在1张可选为对象的卡。
function c39078434.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 在合法性检查阶段，确认我方场上有至少1张卡可以选择为对象。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,0,1,nil)
		-- 并确认对方场上有至少1张卡可以选择为对象。
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 给玩家显示'请选择要破坏的卡'的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择我方场上的1张卡作为破坏对象。
	local g1=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 给玩家显示'请选择要破坏的卡'的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡作为破坏对象。
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 登记破坏效果的操作信息，对象为已选择的2张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- ③效果处理：取出连锁对象并过滤出仍与效果关联的卡，将它们破坏。
function c39078434.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将过滤后的对象卡以效果原因破坏。
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
