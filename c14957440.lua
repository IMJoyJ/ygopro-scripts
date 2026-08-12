--落魂
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要自己场上有调整以外的怪兽存在，对方不能选择这张卡作为攻击对象。
-- ②：怪兽从场上送去对方墓地的场合发动。给这张卡放置1个落魂指示物。那之后，把最多有这张卡的落魂指示物数量的「落魂衍生物」（兽族·地·1星·攻/守?）在自己场上特殊召唤。这衍生物的等级上升这张卡的落魂指示物数量的数值，攻击力·守备力变成那等级×500。
function c14957440.initial_effect(c)
	c:EnableCounterPermit(0x59,LOCATION_MZONE)
	-- 只要自己场上有调整以外的怪兽存在，对方不能选择这张卡作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c14957440.atklm)
	-- 设定效果的取值函数：免疫此效果的卡不受「不能成为攻击对象」的限制。
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：怪兽从场上送去对方墓地的场合发动。给这张卡放置1个落魂指示物。那之后，把最多有这张卡的落魂指示物数量的「落魂衍生物」（兽族·地·1星·攻/守?）在自己场上特殊召唤。这衍生物的等级上升这张卡的落魂指示物数量的数值，攻击力·守备力变成那等级×500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14957440,0))
	e2:SetCategory(CATEGORY_COUNTER+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,14957440)
	e2:SetCondition(c14957440.tkcon)
	e2:SetTarget(c14957440.tktg)
	e2:SetOperation(c14957440.tkop)
	c:RegisterEffect(e2)
end
c14957440.mentioned_counter={
	[0x59]=true,
}
-- 过滤函数：判定里侧表示的怪兽或表侧表示的调整以外的怪兽。
function c14957440.atkfilter(c)
	return c:IsFacedown() or c:IsFaceup() and not c:IsType(TYPE_TUNER)
end
-- ①效果的适用条件：检查自己场上是否存在调整以外的怪兽。
function c14957440.atklm(e)
	-- 检查自己主要怪兽区是否至少存在1张里侧表示的或表侧表示的非调整怪兽。
	return Duel.IsExistingMatchingCard(c14957440.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：判定原本在怪兽区、原控制者为对方、且被送去墓地的怪兽卡。
function c14957440.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsType(TYPE_MONSTER)
end
-- ②效果的发动条件：本次送去墓地的卡中存在从对方场上送去对方墓地的怪兽。
function c14957440.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c14957440.cfilter,1,nil,1-tp)
end
-- ②效果的目标检查：确认这张卡可以放置1个落魂指示物，并设置指示物操作信息。
function c14957440.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x59,1) end
	-- 设置本次连锁的操作信息：确定要放置1个指示物，供王家长眠之谷等卡检测。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0)
end
-- ②效果的处理：给这张卡放置1个落魂指示物，然后按指示物数量在自己场上特殊召唤「落魂衍生物」，并为其赋予等级上升和攻守变化的永续效果。
function c14957440.tkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己主要怪兽区当前可使用的空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if e:GetHandler():AddCounter(0x59,1)~=0 and ft>0
		-- 检查自己是否可以特殊召唤「落魂衍生物」（兽族·地·1星）到自己场上。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,14957441,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH) then
		-- 中断当前效果处理，使放置指示物与之后的衍生物特殊召唤视为不同时处理（对应「那之后」）。
		Duel.BreakEffect()
		local ct=c:GetCounter(0x59)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		if ct>ft then ct=ft end
		while ct>0 do
			-- 生成1张「落魂衍生物」（卡号14957441）到自己的场上。
			local token=Duel.CreateToken(tp,14957441)
			-- 这衍生物的等级上升这张卡的落魂指示物数量的数值
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
			e1:SetValue(c:GetCounter(0x59))
			token:RegisterEffect(e1)
			-- 攻击力·守备力变成那等级×500（攻击力部分）
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_SET_ATTACK)
			e2:SetValue(c:GetCounter(0x59)*500)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
			token:RegisterEffect(e2)
			-- 攻击力·守备力变成那等级×500（守备力部分）
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_SET_DEFENSE)
			e3:SetValue(c:GetCounter(0x59)*500)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
			token:RegisterEffect(e3)
			-- 以正面表示将这只衍生物特殊召唤到自己场上（分步特殊召唤中的单步处理）。
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			ct=ct-1
			-- 若还可以继续特殊召唤，则询问玩家「是否继续特殊召唤？」，选择否则停止继续特招（即最多特殊召唤指示物数量只）。
			if ct>0 and not Duel.SelectYesNo(tp,aux.Stringid(14957440,1)) then ct=0 end  --"是否继续特殊召唤？"
		end
		-- 结束本次分步特殊召唤，完成衍生物的特殊召唤处理（与SpecialSummonStep配套使用）。
		Duel.SpecialSummonComplete()
	end
end
