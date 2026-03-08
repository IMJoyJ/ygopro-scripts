--フリッグのリンゴ
-- 效果：
-- ①：自己场上没有怪兽存在，自己受到战斗伤害时才能发动。自己基本分回复受到的伤害的数值，在自己场上把1只「邪精衍生物」（恶魔族·暗·1星·攻/守?）特殊召唤。这衍生物的攻击力·守备力变成和这个效果让自己回复的数值相同。
function c42671151.initial_effect(c)
	-- 效果原文内容：①：自己场上没有怪兽存在，自己受到战斗伤害时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c42671151.condition)
	e1:SetTarget(c42671151.target)
	e1:SetOperation(c42671151.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：判断是否满足发动条件，即自己受到战斗伤害且自己场上没有怪兽
function c42671151.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断是否满足发动条件，即自己受到战斗伤害且自己场上没有怪兽
	return ep==tp and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 效果作用：判断是否可以发动此效果，即自己场上是否有空位且可以特殊召唤衍生物
function c42671151.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断自己场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：判断是否可以特殊召唤指定的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,42671152,0,TYPES_TOKEN_MONSTER,-2,-2,1,RACE_FIEND,ATTRIBUTE_DARK) end
	-- 效果作用：设置连锁操作信息，确定回复LP的数量
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ev)
	-- 效果作用：设置连锁操作信息，确定将要特殊召唤的衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 效果作用：设置连锁操作信息，确定将要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果原文内容：自己基本分回复受到的伤害的数值，在自己场上把1只「邪精衍生物」（恶魔族·暗·1星·攻/守?）特殊召唤。
function c42671151.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：使玩家回复受到的战斗伤害数值
	local rec=Duel.Recover(tp,ev,REASON_EFFECT)
	-- 效果作用：判断回复的数值是否与受到的伤害一致且场上是否有空位
	if rec~=ev or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 效果作用：判断是否可以特殊召唤衍生物
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,42671152,0,TYPES_TOKEN_MONSTER,-2,-2,1,RACE_FIEND,ATTRIBUTE_DARK) then return end
	-- 效果作用：创建指定编号的衍生物
	local token=Duel.CreateToken(tp,42671152)
	-- 效果作用：将衍生物特殊召唤到场上
	if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
		-- 效果原文内容：这衍生物的攻击力·守备力变成和这个效果让自己回复的数值相同。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(ev)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE)
		token:RegisterEffect(e2)
	end
	-- 效果作用：完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
