--サイキック・ビースト
-- 效果：
-- ①：这张卡召唤成功时才能发动。从卡组把1只念动力族怪兽除外。这张卡的等级变成和这个效果除外的怪兽的等级相同。
function c46291010.initial_effect(c)
	-- 效果原文内容：①：这张卡召唤成功时才能发动。从卡组把1只念动力族怪兽除外。这张卡的等级变成和这个效果除外的怪兽的等级相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46291010,0))  --"等级变化"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c46291010.rmtg)
	e1:SetOperation(c46291010.rmop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选满足条件的念动力族怪兽（等级大于等于1且可以被除外）
function c46291010.filter(c)
	return c:IsRace(RACE_PSYCHO) and c:IsLevelAbove(1) and c:IsAbleToRemove()
end
-- 效果处理时的判断与设置操作信息，检查是否能从卡组选择1只符合条件的怪兽并设置为除外效果
function c46291010.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在不进入连锁处理的情况下检查是否存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c46291010.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前效果的操作信息为除外（CATEGORY_REMOVE）
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行从卡组除外1只念动力族怪兽，并将自身等级设为该怪兽等级的操作
function c46291010.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从卡组中选择1只满足条件的怪兽作为除外目标
	local g=Duel.SelectMatchingCard(tp,c46291010.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 判断所选怪兽是否成功被除外且自身状态有效
	if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0
		and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 效果原文内容：①：这张卡召唤成功时才能发动。从卡组把1只念动力族怪兽除外。这张卡的等级变成和这个效果除外的怪兽的等级相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
