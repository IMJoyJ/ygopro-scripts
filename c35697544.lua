--闘気炎斬剣
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●除「斗气炎斩剑」外的1张有「炎之剑士」的卡名记述的卡从卡组加入手卡。
-- ●自己的战士族·炎属性怪兽进行战斗的攻击宣言时，以场上1张卡为对象才能发动。那张卡破坏。
-- ●以自己场上的「炎之剑士」或者有那个卡名记述的怪兽为对象的效果由对方发动时才能发动。那个效果无效。
local s,id,o=GetID()
-- 创建卡牌的初始效果，注册三个连锁效果
function s.initial_effect(c)
	-- 记录该卡具有「炎之剑士」的卡名记述
	aux.AddCodeList(c,45231177)
	-- ①：可以从以下效果选择1个发动。●除「斗气炎斩剑」外的1张有「炎之剑士」的卡名记述的卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索有「炎之剑士」的卡名记述的卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.activate1)
	c:RegisterEffect(e1)
	-- ①：可以从以下效果选择1个发动。●自己的战士族·炎属性怪兽进行战斗的攻击宣言时，以场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏场上的卡"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.condition2)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.activate2)
	c:RegisterEffect(e2)
	-- ①：可以从以下效果选择1个发动。●以自己场上的「炎之剑士」或者有那个卡名记述的怪兽为对象的效果由对方发动时才能发动。那个效果无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"无效对方的效果"
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e3:SetCondition(s.condition3)
	e3:SetTarget(s.target3)
	e3:SetOperation(s.activate3)
	c:RegisterEffect(e3)
end
-- 检索过滤函数，用于筛选满足条件的卡
function s.thfilter(c)
	-- 筛选条件：不是斗气炎斩剑且具有炎之剑士记述且能加入手牌
	return not c:IsCode(id) and aux.IsCodeListed(c,45231177) and c:IsAbleToHand()
end
-- 效果1的目标设定函数，检查是否有满足条件的卡
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示对方玩家选择了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息为检索卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果1的发动函数，选择并加入手牌
function s.activate1(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果2的发动条件函数，判断是否为战士族·炎属性怪兽攻击
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗中的怪兽
	local a=Duel.GetBattleMonster(tp)
	return a and a:IsFaceup() and a:IsRace(RACE_WARRIOR) and a:IsAttribute(ATTRIBUTE_FIRE)
end
-- 效果2的目标设定函数，选择场上一张卡
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc~=c end
	-- 检查场上是否存在满足条件的目标
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 提示对方玩家选择了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上一张卡作为目标
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	-- 设置操作信息为破坏目标卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果2的发动函数，破坏目标卡
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 若目标卡有效则破坏
	if tc:IsRelateToEffect(e) then Duel.Destroy(tc,REASON_EFFECT) end
end
-- 效果3的过滤函数，用于判断是否为炎之剑士相关怪兽
function s.dfilter(c,tp)
	-- 筛选条件：在场且为炎之剑士相关怪兽
	return c:IsOnField() and c:IsFaceup() and c:IsControler(tp) and (c:IsCode(45231177) or aux.IsCodeListed(c,45231177)) and c:IsType(TYPE_MONSTER)
end
-- 效果3的发动条件函数，判断是否为对方发动且目标为炎之剑士相关怪兽
function s.condition3(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取连锁的目标卡组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 判断目标卡组中是否存在炎之剑士相关怪兽且该连锁可被无效
	return g and g:IsExists(s.dfilter,1,nil,tp) and Duel.IsChainDisablable(ev)
end
-- 效果3的目标设定函数，设置无效效果
function s.target3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示对方玩家选择了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息为无效效果
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 效果3的发动函数，使连锁效果无效
function s.activate3(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前连锁效果无效
	Duel.NegateEffect(ev)
end
