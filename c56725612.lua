--妖精伝姫の舞踏会
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以把自己的卡组·除外状态的1只「妖精传姬」怪兽或1张「妖精的传姬」加入手卡。
-- ②：自己的「妖精传姬」怪兽可以直接攻击。
-- ③：1回合1次，对方把怪兽特殊召唤的场合，若自己场上有「妖精传姬」怪兽存在，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果无效化，卡名当作「妖精王子」使用。
local s,id,o=GetID()
-- 初始化卡片效果，注册卡片的发动、直接攻击以及无效并改名效果。
function s.initial_effect(c)
	-- 注册卡片关联密码，记录本卡效果中提及的「妖精的传姬」与「妖精王子」的卡片密码。
	aux.AddCodeList(c,91957038,19144623)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以把自己的卡组·除外状态的1只「妖精传姬」怪兽或1张「妖精的传姬」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己的「妖精传姬」怪兽可以直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置直接攻击效果的适用对象为「妖精传姬」怪兽。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1db))
	c:RegisterEffect(e2)
	-- ③：1回合1次，对方把怪兽特殊召唤的场合，若自己场上有「妖精传姬」怪兽存在，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果无效化，卡名当作「妖精王子」使用。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"改变卡名"
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(s.discon)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
-- 过滤检索卡片的条件：卡组或除外状态的「妖精的传姬」或「妖精传姬」怪兽，且能加入手卡。
function s.thfilter(c)
	return c:IsFaceupEx() and (c:IsCode(91957038) or c:IsSetCard(0x1db) and c:IsType(TYPE_MONSTER)) and c:IsAbleToHand()
end
-- 卡片发动时的效果处理函数，处理检索并加入手卡的效果。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组及除外状态中所有满足检索条件的卡片。
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,nil)
	-- 若存在可检索的卡，则询问玩家是否发动该效果将卡加入手卡。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否把卡加入手卡？"
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡因效果加入玩家手卡。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 效果③的发动条件判定：对方把怪兽特殊召唤的场合。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
-- 过滤可作为无效及改名对象怪兽的条件：对方场上表侧表示的效果怪兽，且其效果未被无效或其卡名不为「妖精王子」。
function s.disfilter(c)
	-- 判定怪兽是否为表侧表示的效果怪兽，且满足“效果未被无效”或“卡名不是「妖精王子」”的条件。
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and (aux.NegateEffectMonsterFilter(c) or not c:IsCode(19144623))
end
-- 过滤自己场上「妖精传姬」怪兽的条件：自己场上表侧表示的「妖精传姬」怪兽。
function s.mfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1db)
end
-- 效果③的靶向与可行性检查函数：检查自己场上是否有「妖精传姬」怪兽，对方场上是否有符合条件的效果怪兽，并进行取对象操作。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.disfilter(chkc) end
	-- 检查自己场上是否存在至少1只表侧表示的「妖精传姬」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.mfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在至少1只符合条件的可选为对象的效果怪兽。
		and Duel.IsExistingTarget(s.disfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要无效化效果的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 玩家选择对方场上1只符合条件的效果怪兽作为效果对象。
	Duel.SelectTarget(tp,s.disfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果③的执行函数：使选中的对象怪兽效果无效，并将其卡名变更为「妖精王子」。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选为对象的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER)
		and (tc:IsCanBeDisabledByEffect(e) or not tc:IsCode(19144623)) then
		-- 使与目标怪兽相关的连锁中已发动的效果无效化。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那只怪兽的效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 卡名当作「妖精王子」使用。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(EFFECT_CHANGE_CODE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(19144623)
		tc:RegisterEffect(e3)
	end
end
