--サイキック・ビースト
-- 效果：
-- ①：这张卡召唤成功时才能发动。从卡组把1只念动力族怪兽除外。这张卡的等级变成和这个效果除外的怪兽的等级相同。
function c46291010.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从卡组把1只念动力族怪兽除外。这张卡的等级变成和这个效果除外的怪兽的等级相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46291010,0))  --"等级变化"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c46291010.rmtg)
	e1:SetOperation(c46291010.rmop)
	c:RegisterEffect(e1)
end
-- 定义筛选条件：卡组中等级1以上、可除外且种族为念动力族的怪兽。
function c46291010.filter(c)
	return c:IsRace(RACE_PSYCHO) and c:IsLevelAbove(1) and c:IsAbleToRemove()
end
-- 效果发动时的目标合法性与操作信息登记：检查卡组有无符合条件的念动力族怪兽，并设置将除外卡组1张卡。
function c46291010.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查阶段，确认卡组中至少存在1张满足条件的念动力族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c46291010.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记本次连锁的操作信息：将进行的处理是除外卡组中的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择并除外1只念动力族怪兽；若除外成功且本卡仍在场上表侧表示，则为本卡赋予等级变成所除外怪兽等级的效果。
function c46291010.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 弹出发动时的选卡提示，提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从卡组筛选并选择1只满足条件的念动力族怪兽。
	local g=Duel.SelectMatchingCard(tp,c46291010.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 判断选中的卡存在且已被效果成功除外，同时确认本卡仍与效果关联且处于表侧表示。
	if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0
		and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的等级变成和这个效果除外的怪兽的等级相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
