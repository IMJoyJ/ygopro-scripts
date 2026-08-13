--闘気炎斬剣
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●除「斗气炎斩剑」外的1张有「炎之剑士」的卡名记述的卡从卡组加入手卡。
-- ●自己的战士族·炎属性怪兽进行战斗的攻击宣言时，以场上1张卡为对象才能发动。那张卡破坏。
-- ●以自己场上的「炎之剑士」或者有那个卡名记述的怪兽为对象的效果由对方发动时才能发动。那个效果无效。
local s,id,o=GetID()
-- 初始化效果：将「炎之剑士」的卡名记录到本卡；创建并注册①的3个可选效果（检索、破坏、无效），它们通过相同的CountLimit共享同名卡1回合1次发动限制。
function s.initial_effect(c)
	-- 将卡号45231177（「炎之剑士」）添加为本卡的记述卡名，用于“有「炎之剑士」的卡名记述”的检索与无效判定。
	aux.AddCodeList(c,45231177)
	-- ●除「斗气炎斩剑」外的1张有「炎之剑士」的卡名记述的卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索有「炎之剑士」的卡名记述的卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.activate1)
	c:RegisterEffect(e1)
	-- ●自己的战士族·炎属性怪兽进行战斗的攻击宣言时，以场上1张卡为对象才能发动。那张卡破坏。
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
	-- ●以自己场上的「炎之剑士」或者有那个卡名记述的怪兽为对象的效果由对方发动时才能发动。那个效果无效。
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
-- 检索筛选函数：判断一张卡是否为除本卡外、卡名记述有「炎之剑士」且能够加入手卡的卡。
function s.thfilter(c)
	-- 条件：不是本卡、卡名记述「炎之剑士」、能被加入手卡。
	return not c:IsCode(id) and aux.IsCodeListed(c,45231177) and c:IsAbleToHand()
end
-- 第一个效果的发动判定与操作设置：若卡组存在可检索的卡则允许发动；向对方展示所选效果；设置本次效果为从卡组将1张卡加入手卡。
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件：卡组中存在至少1张满足检索条件的卡（除本卡外、记述「炎之剑士」、可加入手卡）。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示本次发动的效果是检索“有「炎之剑士」的卡名记述的卡加入手卡”。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 登记操作信息：本次处理为从卡组检索1张卡加入手卡（对象在处理时确定，故目标为nil）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果处理：从卡组选择1张符合条件的卡，加入手卡，并让对方确认。
function s.activate1(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：请选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组选择1张符合条件的卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手卡（加入持有者手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方确认加入手卡的那张卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 第二个效果的发动条件：己方进行攻击宣言的战斗怪兽是表侧表示的战士族·炎属性怪兽。
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得己方正在战斗的怪兽。
	local a=Duel.GetBattleMonster(tp)
	return a and a:IsFaceup() and a:IsRace(RACE_WARRIOR) and a:IsAttribute(ATTRIBUTE_FIRE)
end
-- 第二个效果的发动判定与目标选择：选择场上除本卡外的1张卡为对象，并设置破坏操作信息。
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc~=c end
	-- 发动条件：场上存在除本卡外能成为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 向对方提示本次发动了破坏场上卡的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 显示选择提示：请选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 取场上1张除本卡外的卡为对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	-- 登记操作信息：破坏对象卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果处理：若对象仍与效果关联则将其破坏。
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果对象卡。
	local tc=Duel.GetFirstTarget()
	-- 若该卡仍与本次效果关联（没有离场/重置），则将其破坏。
	if tc:IsRelateToEffect(e) then Duel.Destroy(tc,REASON_EFFECT) end
end
-- 无效对象判定过滤器：判断一张卡是否为我方场上的表侧表示怪兽，且卡名为「炎之剑士」或卡名记述「炎之剑士」。
function s.dfilter(c,tp)
	-- 条件：在我方场上、表侧表示、是我方怪兽、是「炎之剑士」或记述其卡名。
	return c:IsOnField() and c:IsFaceup() and c:IsControler(tp) and (c:IsCode(45231177) or aux.IsCodeListed(c,45231177)) and c:IsType(TYPE_MONSTER)
end
-- 第三个效果的发动条件：对方发动取对象效果，且对象为我方场上的「炎之剑士」或记述其卡名的怪兽，并且该效果能够被无效。
function s.condition3(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取对方发动的连锁的效果对象卡组。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 对象中存在符合条件的我方怪兽，且连锁效果可被无效。
	return g and g:IsExists(s.dfilter,1,nil,tp) and Duel.IsChainDisablable(ev)
end
-- 第三个效果的发动判定：无需额外选择目标，仅设置无效对方效果的操作信息。
function s.target3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方提示本次发动了无效效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 登记操作信息：使对方发动的那个效果无效。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 无效效果处理：直接无效对方发动的那个连锁效果。
function s.activate3(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁ev的效果无效。
	Duel.NegateEffect(ev)
end
