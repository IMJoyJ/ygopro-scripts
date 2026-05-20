--暗黒界の文殿
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从手卡选1只「暗黑界」怪兽丢弃，自己场上的全部「暗黑界」怪兽的攻击力直到回合结束时上升这个效果丢弃的怪兽的等级×100。
-- ②：原本种族是恶魔族的怪兽被「暗黑界」卡的效果或者对方的效果从自己手卡丢弃的场合才能发动（伤害步骤也能发动）。选自己1张手卡丢弃。那之后，自己从卡组抽2张。
local s,id,o=GetID()
-- 初始化卡片效果：注册魔法卡的发动、主要阶段丢弃手牌「暗黑界」怪兽使场上「暗黑界」怪兽攻击力上升的效果（①），以及恶魔族怪兽被特定效果丢弃时丢弃手牌并抽卡的效果（②）。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：自己主要阶段才能发动。从手卡选1只「暗黑界」怪兽丢弃，自己场上的全部「暗黑界」怪兽的攻击力直到回合结束时上升这个效果丢弃的怪兽的等级×100。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：原本种族是恶魔族的怪兽被「暗黑界」卡的效果或者对方的效果从自己手卡丢弃的场合才能发动（伤害步骤也能发动）。选自己1张手卡丢弃。那之后，自己从卡组抽2张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DISCARD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选手牌中等级1以上、可以被效果丢弃的「暗黑界」怪兽。
function s.disfilter(c)
	return c:IsSetCard(0x6) and c:IsType(TYPE_MONSTER) and c:IsLevelAbove(1)
		and c:IsDiscardable(REASON_EFFECT)
end
-- 过滤函数：筛选自己场上表侧表示的「暗黑界」怪兽。
function s.atkfilter(c)
	return c:IsSetCard(0x6) and c:IsFaceup()
end
-- 效果①的发动准备：检查手牌中是否存在可丢弃的「暗黑界」怪兽，且场上是否存在表侧表示的「暗黑界」怪兽，并设置丢弃手牌的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手牌中是否存在至少1只满足条件的「暗黑界」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_HAND,0,1,nil)
		-- 检查自己场上是否存在至少1只表侧表示的「暗黑界」怪兽。
		and Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置操作信息：将1张手牌送去墓地（丢弃）。
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 效果①的效果处理：让玩家选择手牌中的1只「暗黑界」怪兽丢弃，若成功丢弃，则使场上所有「暗黑界」怪兽的攻击力直到回合结束时上升该怪兽等级×100的数值。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要丢弃的手牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 让玩家从手牌中选择1只满足条件的「暗黑界」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.disfilter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 获取自己场上所有表侧表示的「暗黑界」怪兽。
		local mg=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil)
		-- 将选中的怪兽因效果丢弃送去墓地，并判断是否成功丢弃。
		if Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)~=0
			and mg:GetCount()>0 then
			local level=g:GetFirst():GetLevel()
			local tc=mg:GetFirst()
			while tc do
				-- 自己场上的全部「暗黑界」怪兽的攻击力直到回合结束时上升这个效果丢弃的怪兽的等级×100。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(level*100)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
				tc=mg:GetNext()
			end
		end
	end
end
-- 过滤函数：筛选原本种族是恶魔族、因「暗黑界」卡的效果或对方的效果从自己手牌丢弃的怪兽。
function s.cfilter(c,tp,re)
	local rc=re:GetHandler()
	return c:GetOriginalRace()&RACE_FIEND~=0
		and c:IsReason(REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_HAND)
		and c:IsPreviousControler(tp)
		and (rc:IsSetCard(0x6) or c:GetReasonPlayer()==1-tp)
end
-- 效果②的发动条件：检查是否有满足条件的恶魔族怪兽被丢弃。
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return re and eg:IsExists(s.cfilter,1,nil,tp,re)
end
-- 效果②的发动准备：检查玩家是否能抽2张卡，且手牌中是否存在可丢弃的卡，并设置丢弃手牌和抽卡的操作信息。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否可以从卡组抽2张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		-- 检查自己手牌中是否存在至少1张可以被效果丢弃的卡。
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil,REASON_EFFECT) end
	-- 设置操作信息：将1张手牌送去墓地（丢弃）。
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	-- 设置操作信息：从卡组抽2张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果②的效果处理：让玩家选择自己1张手卡丢弃，那之后，自己从卡组抽2张。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家选择自己1张手卡丢弃，并判断是否成功丢弃。
	if Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_EFFECT+REASON_DISCARD)~=0 then
		-- 中断当前效果处理，使后续的抽卡处理与丢弃手牌不视为同时进行（对应“那之后”）。
		Duel.BreakEffect()
		-- 让玩家从卡组抽2张卡。
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
