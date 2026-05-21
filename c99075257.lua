--D－タイム
-- 效果：
-- 自己场上存在的名字带有「元素英雄」的怪兽从场上离开时才能发动。把和那只怪兽的等级相同的等级以下的1只名字带有「命运英雄」的怪兽从卡组加入手卡。
function c99075257.initial_effect(c)
	-- 自己场上存在的名字带有「元素英雄」的怪兽从场上离开时才能发动。把和那只怪兽的等级相同的等级以下的1只名字带有「命运英雄」的怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetCondition(c99075257.condition)
	e1:SetTarget(c99075257.target)
	e1:SetOperation(c99075257.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：原本由自己控制、在场上表侧表示存在的「元素英雄」怪兽
function c99075257.cfilter(c,tp)
	return c:IsSetCard(0x3008) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
end
-- 发动条件：检查离场的怪兽中是否存在满足条件的自己场上的「元素英雄」怪兽
function c99075257.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c99075257.cfilter,1,nil,tp)
end
-- 过滤条件：卡组中等级在指定数值以下、名字带有「命运英雄」且可以加入手牌的怪兽
function c99075257.filter(c,lv)
	return c:IsLevelBelow(lv) and c:IsSetCard(0xc008) and c:IsAbleToHand()
end
-- 效果的目标处理：获取离场的「元素英雄」怪兽中的最高等级并记录，设置将卡组怪兽加入手牌的操作信息
function c99075257.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(c99075257.cfilter,nil,tp)
	local _,lv=g:GetMaxGroup(Card.GetLevel)
	-- 在发动检测时，检查卡组中是否存在等级在离场「元素英雄」最高等级以下、且可加入手牌的「命运英雄」怪兽
	if chk==0 then return lv>0 and Duel.IsExistingMatchingCard(c99075257.filter,tp,LOCATION_DECK,0,1,nil,lv) end
	e:SetLabel(lv)
	-- 设置当前连锁的操作信息为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只符合等级条件的「命运英雄」怪兽加入手牌，并给对方确认
function c99075257.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，要求选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张等级在记录等级以下、且名字带有「命运英雄」的怪兽
	local g=Duel.SelectMatchingCard(tp,c99075257.filter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	if g:GetCount()~=0 then
		-- 将选择的卡片加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
