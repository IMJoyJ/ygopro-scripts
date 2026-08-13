--ヴァリアンツの弓引－西園
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。这张卡在正对面的自己的主要怪兽区域特殊召唤。这个效果的发动后，直到回合结束时自己不是「群豪」怪兽不能特殊召唤（除从额外卡组的特殊召唤外）。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：这张卡是已特殊召唤的场合，以场上1只效果怪兽为对象才能发动。进行1次投掷硬币。表的场合，那只怪兽的效果无效。里的场合，那个攻击力变成一半。
-- ②：怪兽区域的这张卡向其他的怪兽区域移动的场合，以场上1张卡为对象才能发动。进行1次投掷硬币。表的场合，那张卡破坏。里的场合，那张卡回到持有者手卡。
function c15130912.initial_effect(c)
	-- 为这张灵摆怪兽添加灵摆属性，使其可进行灵摆召唤和灵摆卡的发动（可在灵摆区作为魔法卡发动）。
	aux.EnablePendulumAttribute(c)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：自己主要阶段才能发动。这张卡在正对面的自己的主要怪兽区域特殊召唤。这个效果的发动后，直到回合结束时自己不是「群豪」怪兽不能特殊召唤（除从额外卡组的特殊召唤外）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,15130912)
	e1:SetTarget(c15130912.sptg)
	e1:SetOperation(c15130912.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的怪兽效果1回合各能使用1次。①：这张卡是已特殊召唤的场合，以场上1只效果怪兽为对象才能发动。进行1次投掷硬币。表的场合，那只怪兽的效果无效。里的场合，那个攻击力变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COIN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,15130913)
	e2:SetCondition(c15130912.coincon1)
	e2:SetTarget(c15130912.cointg1)
	e2:SetOperation(c15130912.coinop1)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的怪兽效果1回合各能使用1次。②：怪兽区域的这张卡向其他的怪兽区域移动的场合，以场上1张卡为对象才能发动。进行1次投掷硬币。表的场合，那张卡破坏。里的场合，那张卡回到持有者手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_COIN)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_MOVE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,15130914)
	e3:SetCondition(c15130912.coincon2)
	e3:SetTarget(c15130912.cointg2)
	e3:SetOperation(c15130912.coinop2)
	c:RegisterEffect(e3)
end
-- 灵摆效果的发动条件：判定这张灵摆卡能否以表侧表示特殊召唤到自己灵摆区正对面的主要怪兽区域（zone由灵摆区位置算出），可以才允许发动。
function c15130912.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local zone=1<<c:GetSequence()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone) end
	-- 登记本次连锁的特殊召唤操作信息（特殊召唤这张卡，数量1），供后续时点与相关卡的效果判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 灵摆效果处理：先将这张卡特殊召唤到正对面的主要怪兽区，然后对自己适用一个直到回合结束的自我限制：不能特殊召唤非「群豪」怪兽（从额外卡组的特殊召唤除外）。
function c15130912.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=1<<c:GetSequence()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到指定zone（正对自己的主要怪兽区），特殊召唤成功。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,zone)
	end
	-- 这个效果的发动后，直到回合结束时自己不是「群豪」怪兽不能特殊召唤（除从额外卡组的特殊召唤外）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c15130912.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述“不能特殊召唤”的永续效果注册到当前玩家（自己），使其在场上持续生效直到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 判断某个怪兽是否受本次特殊召唤限制：若该怪兽不是「群豪」系列且不是从额外卡组进行特殊召唤，则禁止特殊召唤。
function c15130912.splimit(e,c)
	return not c:IsSetCard(0x17d) and not c:IsLocation(LOCATION_EXTRA)
end
-- 怪兽效果①的发动条件：这张卡在成功特殊召唤过的场合（召唤类型为特殊召唤）才能发动。
function c15130912.coincon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 选择对象的过滤条件：必须是表侧表示且为效果怪兽。
function c15130912.coinfilter1(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 怪兽效果①发动时的目标选择：从双方场上选择1只表侧效果怪兽作为对象；同时登记投入硬币的操作信息。
function c15130912.cointg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c15130912.coinfilter1(chkc) end
	-- 效果发动合法性检查：双方场上是否存在至少1只表侧表示的效果怪兽，存在才能发动。
	if chk==0 then return Duel.IsExistingTarget(c15130912.coinfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 弹出选择对象的提示信息，提示文字为‘请选择效果的对象’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从双方场上选择1只表侧效果怪兽，并将其设为当前连锁的对象。
	Duel.SelectTarget(tp,c15130912.coinfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次处理将进行1次硬币投掷，供连锁判定/相关效果参考。
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 怪兽效果①处理：取对象，若对象仍表侧且与效果关联则掷硬币。正面：对象效果无效；反面：对象攻击力变为当前一半。
function c15130912.coinop1(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这张卡发动效果时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not (tc:IsFaceup() and tc:IsRelateToEffect(e)) then return end
	-- 让玩家投掷1次硬币，coin=1为正面，0为反面。
	local coin=Duel.TossCoin(tp,1)
	if coin==1 then
		if tc:IsCanBeDisabledByEffect(e) then
			-- 将与对象怪兽相关的连锁效果无效化，并在该怪兽变里侧时重置这个无效状态。
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 表的场合，那只怪兽的效果无效。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			tc:RegisterEffect(e2)
		end
	else
		-- 里的场合，那个攻击力变成一半。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 怪兽效果②的发动条件：这张卡从怪兽区域向其他怪兽区域移动（移动前后都在怪兽区域，且区域位置或控制者发生了改变）的场合。
function c15130912.coincon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_MZONE)
		and (c:GetPreviousSequence()~=c:GetSequence() or c:GetPreviousControler()~=tp)
end
-- 怪兽效果②发动时的目标选择：从场上选择1张卡作为对象；同时登记投入硬币的操作信息。
function c15130912.cointg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 效果发动合法性检查：场上是否存在至少1张可以作为对象（不限制条件）的卡，存在才能发动。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 弹出选择对象的提示信息，提示文字为‘请选择效果的对象’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从双方场上选择1张卡，并将其设为当前连锁的对象。
	Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：本次处理将进行1次硬币投掷。
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 怪兽效果②处理：取对象，若仍与效果关联则掷硬币。正面：破坏对象卡；反面：将对象卡返回持有者手卡。
function c15130912.coinop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这张卡发动效果时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 让玩家投掷1次硬币，coin=1为正面，0为反面。
	local coin=Duel.TossCoin(tp,1)
	if coin==1 then
		-- 以效果破坏对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	else
		-- 以效果将对象卡返回持有者手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
