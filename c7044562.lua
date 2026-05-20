--魂のカード
-- 效果：
-- 「魂之卡」在1回合只能发动1张。
-- ①：把自己卡组确认。可以从那之中把1只攻击力·守备力的合计是和自己基本分相同数值的怪兽加入手卡。
function c7044562.initial_effect(c)
	-- 「魂之卡」在1回合只能发动1张。①：把自己卡组确认。可以从那之中把1只攻击力·守备力的合计是和自己基本分相同数值的怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,7044562+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c7044562.target)
	e1:SetOperation(c7044562.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的目标选择与合法性检查函数
function c7044562.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自身卡组中是否有卡片存在
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
end
-- 过滤函数：筛选出攻击力与守备力合计等于玩家当前基本分，且可以加入手卡的怪兽
function c7044562.filter(c,lp)
	return c:GetAttack()>=0 and c:GetDefense()>=0 and c:GetAttack()+c:GetDefense()==lp and c:IsAbleToHand()
end
-- 效果处理（发动）的核心逻辑函数
function c7044562.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家自己卡组中的所有卡片组
	local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	if g:GetCount()<1 then return end
	-- 让发动效果的玩家确认自己的卡组
	Duel.ConfirmCards(tp,g)
	-- 获取发动效果玩家的当前基本分（LP）
	local lp=Duel.GetLP(tp)
	-- 如果卡组中存在符合条件的怪兽，则由玩家选择是否将其中1只加入手卡
	if g:IsExists(c7044562.filter,1,nil,lp) and Duel.SelectYesNo(tp,aux.Stringid(7044562,0)) then  --"是否选择怪兽加入手卡？"
		-- 在系统界面提示玩家选择要加入手牌的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:FilterSelect(tp,c7044562.filter,1,1,nil,lp)
		-- 将选中的怪兽因效果加入玩家手卡
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的怪兽
		Duel.ConfirmCards(1-tp,sg)
		-- 洗切发动效果玩家的手卡
		Duel.ShuffleHand(tp)
	end
	-- 洗切发动效果玩家的卡组
	Duel.ShuffleDeck(tp)
end
