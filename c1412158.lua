--レアメタル・ナイト
-- 效果：
-- 「稀有金属女郎」＋「稀有金属战士」
-- 这张卡在对怪兽的战斗伤害计算时，攻击力上升1000，在场上的这张卡可以和融合区的「稀有金属女武神」互换（这张卡特殊召唤的回合不可以互换。）
function c1412158.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续（对应“「稀有金属女郎」＋「稀有金属战士」”）：以卡号92421852的「稀有金属女郎」与卡号38916461的「稀有金属战士」为融合素材；true,true 为常规的素材代用/手续兼容设置。
	aux.AddFusionProcCode2(c,92421852,38916461,true,true)
	-- 对应效果原文：“这张卡在对怪兽的战斗伤害计算时，攻击力上升1000。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1412158,0))  --"攻击上升"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c1412158.atkcon)
	e1:SetValue(1000)
	c:RegisterEffect(e1)
	-- 对应效果原文：“在场上的这张卡可以和融合区的「稀有金属女武神」互换（这张卡特殊召唤的回合不可以互换。）”
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1412158,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c1412158.spcon)
	e2:SetTarget(c1412158.sptg)
	e2:SetOperation(c1412158.spop)
	c:RegisterEffect(e2)
end
-- 攻击力上升效果的适用条件：当前处于伤害步骤或伤害计算时，且这张卡是攻击怪兽并与对方的怪兽进行战斗（存在攻击对象）。
function c1412158.atkcon(e)
	-- 取得当前战斗阶段，用于判断是否处于伤害步骤（PHASE_DAMAGE）或伤害计算时（PHASE_DAMAGE_CAL）。
	local ph=Duel.GetCurrentPhase()
	if not (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) then return false end
	-- 取得正在攻击的怪兽，用于判断是否为这张卡在攻击。
	local a=Duel.GetAttacker()
	-- 取得攻击对象怪兽，用于判断本卡是在对怪兽进行战斗（而非直接攻击）。
	local d=Duel.GetAttackTarget()
	return a==e:GetHandler() and d~=nil
end
-- 互换效果的发动条件：这张卡转到当前区域的回合不是本回合，即这张卡不是在本回合被特殊召唤（特殊召唤的回合不能互换）。
function c1412158.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 比较这张卡转到当前区域的回合编号与当前回合编号是否不同，从而排除特殊召唤当回合发动互换。
	return e:GetHandler():GetTurnID()~=Duel.GetTurnCount()
end
-- 筛选互换对象：候选卡必须是「稀有金属女武神」（75923050），能通过当前效果特殊召唤，且这张卡离场后额外怪兽仍有可用的特殊召唤区域。
function c1412158.spfilter(c,e,tp,mc)
	-- 该行判断目标卡为「稀有金属女武神」、满足特殊召唤条件，且当前有可供其特殊召唤的空位（考虑到本卡移出额外卡组/场上后的空位）。
	return c:IsCode(75923050) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 互换效果的发动合法性：本卡可以回到额外卡组（融合区），且额外卡组存在符合条件的「稀有金属女武神」。
function c1412158.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToExtra()
		-- 额外卡组中是否存在至少1只满足互换条件的「稀有金属女武神」。
		and Duel.IsExistingMatchingCard(c1412158.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	-- 登记操作信息：本次处理将把这张卡返回额外卡组（CATEGORY_TODECK），数量1。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
	-- 登记操作信息：本次处理将从额外卡组特殊召唤1只怪兽（CATEGORY_SPECIAL_SUMMON）；目标怪兽在处理时确定，此处不指定对象。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行互换：在效果处理时确认本卡仍与效果相关且为表侧表示，则从额外卡组选择符合条件的「稀有金属女武神」，先把本卡返回卡组并洗牌，再将该怪兽特殊召唤。
function c1412158.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 从额外卡组取得第一张符合条件的「稀有金属女武神」作为互换的特殊召唤目标。
		local tc=Duel.GetFirstMatchingCard(c1412158.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,c)
		-- 如果存在目标，且成功将本卡返回卡组并洗牌（返回数量不为0），才继续执行互换的特殊召唤。
		if tc and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
			-- 将「稀有金属女武神」以表侧表示特殊召唤到发动玩家（tp）的场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
