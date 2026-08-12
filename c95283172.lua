--GP－ゴー・ワイルド
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把手卡1只「黄金荣耀」怪兽给对方观看才能发动。和给人观看的怪兽卡名不同的1只「黄金荣耀」怪兽从卡组加入手卡。那之后，以下效果可以适用。
-- ●从手卡把1只「黄金荣耀」怪兽特殊召唤，自己失去那个原本攻击力数值的基本分。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把手卡1只「黄金荣耀」怪兽给对方观看才能发动。和给人观看的怪兽卡名不同的1只「黄金荣耀」怪兽从卡组加入手卡。那之后，以下效果可以适用。●从手卡把1只「黄金荣耀」怪兽特殊召唤，自己失去那个原本攻击力数值的基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤卡组中与展示怪兽卡名不同、可加入手卡的「黄金荣耀」怪兽
function s.thfilter(c,code)
	return not c:IsCode(code) and c:IsSetCard(0x192) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 过滤手卡中未公开的、且卡组中存在同名卡以外的「黄金荣耀」怪兽的「黄金荣耀」怪兽
function s.cfilter(c,tp)
	return not c:IsPublic() and c:IsSetCard(0x192) and c:IsType(TYPE_MONSTER)
		-- 检查卡组中是否存在与该怪兽卡名不同的「黄金荣耀」怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
-- 效果发动时的目标选择与费用检测函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查手卡中是否存在满足展示条件的「黄金荣耀」怪兽
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 设置提示信息为选择要确认的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手卡选择1只满足条件的「黄金荣耀」怪兽用于展示
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	e:SetLabel(g:GetFirst():GetCode())
	-- 给对方确认选择的手卡怪兽
	Duel.ConfirmCards(1-tp,g)
	-- 洗切自身手卡
	Duel.ShuffleHand(tp)
	-- 设置效果处理信息为从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤手卡中可以特殊召唤的「黄金荣耀」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x192) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理（检索及后续的特殊召唤与失去基本分）的主函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabel()
	-- 设置提示信息为选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只与展示怪兽卡名不同的「黄金荣耀」怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,code)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入手卡
		Duel.SendtoHand(g,tp,REASON_EFFECT)
		-- 给对方确认加入手卡的怪兽
		Duel.ConfirmCards(1-tp,g)
		-- 检查手卡中是否存在可以特殊召唤的「黄金荣耀」怪兽
		if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
			-- 检查自身场上是否有空余的怪兽区域
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 询问玩家是否适用特殊召唤的追加效果
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否从手卡把怪兽特殊召唤？"
			-- 中断效果处理，使后续的特殊召唤和失去基本分与检索处理不视为同时进行
			Duel.BreakEffect()
			-- 设置提示信息为选择要特殊召唤的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从手卡选择1只「黄金荣耀」怪兽进行特殊召唤
			local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
			-- 洗切自身手卡
			Duel.ShuffleHand(tp)
			-- 将选择的怪兽特殊召唤到场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			local atk=sg:GetFirst():GetBaseAttack()
			-- 扣除自身等同于特殊召唤怪兽原本攻击力数值的基本分
			Duel.SetLP(tp,Duel.GetLP(tp)-atk)
		end
	end
end
