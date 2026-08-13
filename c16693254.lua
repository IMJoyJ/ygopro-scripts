--リチュア・アバンス
-- 效果：
-- 1回合1次，可以从自己卡组选择1只名字带有「遗式」的怪兽在卡组最上面放置。
function c16693254.initial_effect(c)
	-- 对应效果原文：1回合1次，可以从自己卡组选择1只名字带有「遗式」的怪兽在卡组最上面放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16693254,0))  --"卡组最上方放置"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c16693254.target)
	e1:SetOperation(c16693254.operation)
	c:RegisterEffect(e1)
end
-- 筛选条件：卡片需为怪兽卡且卡名含有「遗式」字段，用于选出可放置到卡组顶部的对象。
function c16693254.filter(c)
	return c:IsSetCard(0x3a) and c:IsType(TYPE_MONSTER)
end
-- 目标函数：在效果发动时进行合法性检查，确认卡组中存在符合条件的目标，并作为发动条件。
function c16693254.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0为发动合法性判定分支，检查自己卡组是否存在至少1张满足条件的「遗式」怪兽，若不存在则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c16693254.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果处理函数：执行从卡组选1只「遗式」怪兽放置到卡组顶部的完整操作，包括选择、洗切、移动和确认。
function c16693254.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家显示选择提示，提示内容为“请选择要放置到卡组最上方的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(16693254,1))  --"请选择要放置到卡组最上方的卡"
	-- 让操作玩家从自己卡组中筛选并选择1张满足条件的「遗式」怪兽卡，作为要放置到卡组顶部的卡。
	local g=Duel.SelectMatchingCard(tp,c16693254.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 洗切操作玩家的卡组，将除选中的卡以外的卡牌顺序随机化，避免暴露卡组信息。
		Duel.ShuffleDeck(tp)
		-- 将选中的怪兽移动到卡组最顶端（SEQ_DECKTOP），实现放置在卡组最上面的规则动作。
		Duel.MoveSequence(tc,SEQ_DECKTOP)
		-- 向双方玩家确认卡组最上方1张卡，展示放置结果并验证效果处理完成。
		Duel.ConfirmDecktop(tp,1)
	end
end
