--黒い旋風
-- 效果：
-- ①：自己场上有「黑羽」怪兽召唤时才能发动。把持有比那只怪兽低的攻击力的1只「黑羽」怪兽从卡组加入手卡。
function c91351370.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上有「黑羽」怪兽召唤时才能发动。把持有比那只怪兽低的攻击力的1只「黑羽」怪兽从卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(91351370,0))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c91351370.target)
	e2:SetOperation(c91351370.operation)
	c:RegisterEffect(e2)
end
-- 过滤卡组中攻击力小于指定值、且可以加入手卡的「黑羽」怪兽
function c91351370.filter(c,val)
	local atk=c:GetTextAttack()
	return atk>=0 and atk<val and c:IsSetCard(0x33) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动的可行性检测：检查召唤的怪兽是否为自己场上的「黑羽」怪兽，且卡组中是否存在攻击力更低的「黑羽」怪兽
function c91351370.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return tc:IsSetCard(0x33) and tc:IsControler(tp)
		-- 检查卡组中是否存在至少1张攻击力低于该召唤怪兽攻击力的、可检索的「黑羽」怪兽
		and Duel.IsExistingMatchingCard(c91351370.filter,tp,LOCATION_DECK,0,1,nil,tc:GetAttack()) end
	tc:CreateEffectRelation(e)
	-- 设置连锁的操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：验证卡片关系后，从卡组选择1只符合条件的「黑羽」怪兽加入手卡并给对方确认
function c91351370.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if not e:GetHandler():IsRelateToEffect(e) or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- 向玩家提示选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张攻击力低于召唤怪兽攻击力的「黑羽」怪兽
	local g=Duel.SelectMatchingCard(tp,c91351370.filter,tp,LOCATION_DECK,0,1,1,nil,tc:GetAttack())
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
