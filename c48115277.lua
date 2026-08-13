--ブロックマン
-- 效果：
-- ①：把这张卡解放才能发动。和这张卡在自己场上表侧表示存在的自己回合数相同数量的「积木衍生物」（岩石族·地·4星·攻1000/守1500）在自己场上守备表示特殊召唤。这衍生物不能攻击宣言。
function c48115277.initial_effect(c)
	-- ①：和这张卡在自己场上表侧表示存在的自己回合数相同数量。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	e1:SetCondition(c48115277.regcon)
	e1:SetOperation(c48115277.regop)
	c:RegisterEffect(e1)
	-- ①：把这张卡解放才能发动。和这张卡在自己场上表侧表示存在的自己回合数相同数量的「积木衍生物」（岩石族·地·4星·攻1000/守1500）在自己场上守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48115277,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c48115277.spcost)
	e2:SetTarget(c48115277.sptg)
	e2:SetOperation(c48115277.spop)
	c:RegisterEffect(e2)
end
-- 判定当前回合玩家是否为这张卡的控制者，仅在自己回合的抽卡阶段开始时触发计数更新。
function c48115277.regcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否为自己（效果持有者的控制者），用于限定只有自己的回合才执行计数。
	return Duel.GetTurnPlayer()==tp
end
-- 更新这张卡表侧表示存在期间经历的自己回合数：若尚无计数则初始化旗标为0，否则将已有计数加1。
function c48115277.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetFlagEffectLabel(48115277)
	if not ct then
		c:RegisterFlagEffect(48115277,RESET_EVENT+RESETS_STANDARD,0,1,0)
	else
		c:SetFlagEffectLabel(48115277,ct+1)
	end
end
-- 发动代价处理：确认这张卡可以解放后，读取已累计的表侧表示存在的自己回合数并存入效果的Label，然后将这张卡解放作为代价。
function c48115277.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	local ct=e:GetHandler():GetFlagEffectLabel(48115277)
	if not ct then ct=0 end
	e:SetLabel(ct)
	-- 将这张卡解放，作为效果的发动代价（REASON_COST）。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 效果发动条件检测：读取累计回合数ct；若ct>0且青眼精灵龙的效果适用则不能发动；同时需有足够怪兽区域空格且可以特殊召唤「积木衍生物」。发动时设置操作信息，表明将特殊召唤ct+1只衍生物。
function c48115277.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=e:GetHandler():GetFlagEffectLabel(48115277)
		if not ct then ct=0 end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return (ct==0 or not Duel.IsPlayerAffectedByEffect(tp,59822133))
			-- 检查自己场上主要怪兽区域的可用空格数是否至少为ct+1个（空格数>ct-1等价于足够容纳要特殊召唤的衍生物数量）。
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>ct-1
			-- 检查自己是否可以将「积木衍生物」（岩石族·地·4星·攻1000/守1500）以表侧守备表示特殊召唤到场上。
			and Duel.IsPlayerCanSpecialSummonMonster(tp,48115278,0,TYPES_TOKEN_MONSTER,1000,1500,4,RACE_ROCK,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE)
	end
	local ct=e:GetLabel()
	-- 设置操作信息：声明本次效果将生成ct+1个衍生物（CATEGORY_TOKEN），供连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ct+1,0,0)
	-- 设置操作信息：声明本次效果将特殊召唤ct+1只怪兽（CATEGORY_SPECIAL_SUMMON），供连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct+1,0,0)
end
-- 效果处理：读取累计回合数ct；若青眼精灵龙限制效果适用且ct>0则无法进行特殊召唤。否则在确认空格足够且能特殊召唤后，循环将ct+1只「积木衍生物」以表侧守备表示特殊召唤，并给每只衍生物附加不能攻击宣言的效果，最后完成特殊召唤。
function c48115277.spop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ct>0 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查自己场上主要怪兽区域的空格数是否大于ct，即至少能容纳ct+1个衍生物。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>ct
		-- 再次确认自己可以特殊召唤「积木衍生物」（岩石族·地·4星·攻1000/守1500）到场上。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,48115278,0,TYPES_TOKEN_MONSTER,1000,1500,4,RACE_ROCK,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE) then
		for i=1,ct+1 do
			-- 在自己场上生成一只「积木衍生物」（卡号48115278）的衍生物。
			local token=Duel.CreateToken(tp,48115278)
			-- 将这只衍生物以表侧守备表示特殊召唤到自己场上，作为连续特殊召唤的一个步骤。
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			-- 这衍生物不能攻击宣言。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1,true)
		end
		-- 结束连续特殊召唤处理，确认上述所有衍生物均已特殊召唤成功。
		Duel.SpecialSummonComplete()
	end
end
