--呼応する伝説の都
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把有「龙都 亚特兰蒂斯」的卡名记述的1只怪兽加入手卡。自己场上有「龙都 亚特兰蒂斯」存在的场合，可以再把对方场上1只效果怪兽的效果直到回合结束时无效。
-- ②：自己场上有「海」存在的场合，把墓地的这张卡除外才能发动。自己场上的全部水属性怪兽的攻击力·守备力上升500。
local s,id,o=GetID()
-- 初始化函数：登记本卡记载的卡名，注册①的检索·无效魔法发动效果（1回合1次）和②的墓地起动攻守上升效果（1回合1次）
function s.initial_effect(c)
	-- 登记这张卡上记载着「龙都 亚特兰蒂斯」(38391684）和「海」(22702055）的卡名
	aux.AddCodeList(c,38391684,22702055)
	-- ①：从卡组把有「龙都 亚特兰蒂斯」的卡名记述的1只怪兽加入手卡。自己场上有「龙都 亚特兰蒂斯」存在的场合，可以再把对方场上1只效果怪兽的效果直到回合结束时无效。（1回合1次）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上有「海」存在的场合，把墓地的这张卡除外才能发动。自己场上的全部水属性怪兽的攻击力·守备力上升500。（1回合1次）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"攻守上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.atkcon)
	-- 设置发动代价：把墓地的这张卡除外才能发动
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- 检索用过滤函数：筛选卡组中效果文本记载着「龙都 亚特兰蒂斯」卡名的怪兽卡且可以加入手卡
function s.thfilter(c)
	-- 判定条件：卡的效果文本上记载着「龙都 亚特兰蒂斯」的卡名、是怪兽卡、并且可以加入手卡
	return aux.IsCodeListed(c,38391684) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的对象函数：确认卡组有可检索的怪兽，并设置卡组检索·加入手卡的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：检查自己卡组是否存在至少1只效果文本记载着「龙都 亚特兰蒂斯」卡名且可加入手卡的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：预告将从卡组把1张卡加入手卡，用于检索类效果的连锁检测
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤函数：筛选自己场上表侧表示的「龙都 亚特兰蒂斯」
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(38391684)
end
-- ①效果的处理：从卡组把1只有「龙都 亚特兰蒂斯」卡名记述的怪兽加入手卡；之后若自己场上有「龙都 亚特兰蒂斯」且对方场上有可无效的效果怪兽，可以再把其中1只的效果直到回合结束时无效
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示：请选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组选择1只效果文本记载着「龙都 亚特兰蒂斯」卡名且可加入手卡的怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 把选择的怪兽因效果加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND)
			-- 判定自己场上是否存在表侧表示的「龙都 亚特兰蒂斯」
			and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
			-- 判定对方场上是否存在可以被无效的表侧表示效果怪兽
			and Duel.IsExistingMatchingCard(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil)
			-- 询问玩家是否要把对方场上1只效果怪兽的效果无效，选择是才继续处理
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把怪兽无效？"
			local c=e:GetHandler()
			-- 中断当前效果处理，使后续无效化处理与加入手卡的处理视为不同时进行
			Duel.BreakEffect()
			-- 向玩家提示：请选择要无效的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
			-- 让玩家选择对方场上1只可以被无效的表侧表示效果怪兽
			local ng=Duel.SelectMatchingCard(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
			-- 为选中的怪兽显示被选为对象的动画并记录
			Duel.HintSelection(ng)
			local tc=ng:GetFirst()
			-- 使与那只怪兽相关的连锁效果无效化，其变成里侧表示时重置
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 把对方场上1只效果怪兽的效果直到回合结束时无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 把对方场上1只效果怪兽的效果直到回合结束时无效（使其发动的效果也无效，变成里侧表示时重置）
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
	end
end
-- 过滤函数：筛选自己场上表侧表示的「海」
function s.cfilter2(c)
	return c:IsFaceup() and c:IsCode(22702055)
end
-- ②效果的发动条件函数：自己场上有「海」存在的场合才能发动
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 发动条件判定：自己场上存在表侧表示的「海」，或当前生效的场地为「海」
	return Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_ONFIELD,0,1,nil) or Duel.IsEnvironment(22702055,tp)
end
-- 过滤函数：筛选自己场上表侧表示的水属性怪兽
function s.atkfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- ②效果的对象函数：确认自己场上存在至少1只表侧表示的水属性怪兽
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：检查自己场上是否存在至少1只表侧表示的水属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- ②效果的处理：取得自己场上全部表侧表示的水属性怪兽，逐一使其攻击力·守备力上升500
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得自己场上全部表侧表示的水属性怪兽组成的卡片组
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil)
	-- 遍历自己场上全部水属性怪兽，对每只怪兽分别进行处理
	for tc in aux.Next(g) do
		-- 自己场上的全部水属性怪兽的攻击力上升500
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
