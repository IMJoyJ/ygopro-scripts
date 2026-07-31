--落魂
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要自己场上有调整以外的怪兽存在，对方不能选择这张卡作为攻击对象。
-- ②：怪兽从场上送去对方墓地的场合发动。给这张卡放置1个落魂指示物。那之后，把最多有这张卡的落魂指示物数量的「落魂衍生物」（兽族·地·1星·攻/守?）在自己场上特殊召唤。这衍生物的等级上升这张卡的落魂指示物数量的数值，攻击力·守备力变成那等级×500。
function c14957440.initial_effect(c)
	c:EnableCounterPermit(0x59,LOCATION_MZONE)
	-- 效果①：只要自己场上有调整以外的怪兽存在，对方不能选择这张卡作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c14957440.atklm)
	-- 设置效果①的值域为辅助函数 aux.imval1，用于判定对方能否将这张卡选为目标进行攻击（即是否免疫该效果的连锁）
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	-- 效果②：怪兽从场上送去对方墓地的场合发动。给这张卡放置 1 个落魂指示物。那之后，把最多有这张卡的落魂指示物数量的「落魂衍生物」（兽族·地·1星·攻/守？）在自己场上特殊召唤。
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
-- 效果①的发动条件判定函数，检查场上是否存在调整以外的怪兽（包括表侧/里侧表示）
function c14957440.atkfilter(c)
	return c:IsFacedown() or c:IsFaceup() and not c:IsType(TYPE_TUNER)
end
-- 效果①的发动条件函数，检查场上是否存在至少 1 张满足 atkfilter 条件的怪兽
function c14957440.atklm(e)
	-- 检查场上是否存在至少 1 张满足 atkfilter 条件的怪兽，用于判断效果①是否生效
	return Duel.IsExistingMatchingCard(c14957440.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 效果②的发动条件判定函数，检查是否有怪兽从场上送去对方墓地
function c14957440.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsType(TYPE_MONSTER)
end
-- 效果②的发动条件函数，检查是否有怪兽从场上送去对方墓地
function c14957440.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c14957440.cfilter,1,nil,1-tp)
end
-- 效果②的目标函数，检查能否给这张卡放置 1 个落魂指示物
function c14957440.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x59,1) end
	-- 设置效果处理的操作信息，指示后续将给这张卡放置 1 个落魂指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0)
end
-- 效果②的效果处理函数，给这张卡放置 1 个落魂指示物后，根据指示物数量特殊召唤相应数量的「落魂衍生物」
function c14957440.tkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查玩家场上可用的怪兽区空格数，用于限制特殊召唤的数量上限
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if e:GetHandler():AddCounter(0x59,1)~=0 and ft>0
		-- 检查玩家是否可以特殊召唤给定的「落魂衍生物」怪兽卡（兽族·地）
		and Duel.IsPlayerCanSpecialSummonMonster(tp,14957441,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH) then
		-- 中断当前效果处理，使后续的衍生物特殊召唤视为不同时处理的连锁
		Duel.BreakEffect()
		local ct=c:GetCounter(0x59)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		if ct>ft then ct=ft end
		while ct>0 do
			-- 创建一张「落魂衍生物」的怪兽卡对象，准备进行特殊召唤
			local token=Duel.CreateToken(tp,14957441)
			-- 这衍生物的等级上升这张卡的落魂指示物数量的数值
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
			e1:SetValue(c:GetCounter(0x59))
			token:RegisterEffect(e1)
			-- ...攻击力·守备力变成那等级×500（攻击部分）
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_SET_ATTACK)
			e2:SetValue(c:GetCounter(0x59)*500)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
			token:RegisterEffect(e2)
			-- ...攻击力·守备力变成那等级×500（防御部分）
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_SET_DEFENSE)
			e3:SetValue(c:GetCounter(0x59)*500)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
			token:RegisterEffect(e3)
			-- 对当前创建的「落魂衍生物」进行特殊召唤步骤处理
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			ct=ct-1
			-- 检查场上剩余空格及玩家意愿，决定是否继续特殊召唤剩余的「落魂衍生物」
			if ct>0 and not Duel.SelectYesNo(tp,aux.Stringid(14957440,1)) then ct=0 end  --"是否继续特殊召唤？"
		end
		-- 完成特殊召唤步骤，结算所有已创建的特殊召唤效果
		Duel.SpecialSummonComplete()
	end
end
