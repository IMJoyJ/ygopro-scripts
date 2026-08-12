--No.95 ギャラクシーアイズ・ダークマター・ドラゴン
-- 效果：
-- 9星怪兽×3
-- 这张卡也能在自己场上的「银河眼」超量怪兽上面重叠来超量召唤。这张卡不能作为超量召唤的素材。
-- ①：这张卡超量召唤成功时，从卡组把3只龙族怪兽送去墓地才能发动（同名卡最多1张）。对方从自身卡组把3只怪兽除外。
-- ②：把这张卡1个超量素材取除才能发动。这个回合，这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
function c58820923.initial_effect(c)
	aux.AddXyzProcedure(c,nil,9,3,c58820923.ovfilter,aux.Stringid(58820923,0))  --"是否在「银河眼」超量怪兽上面重叠超量召唤？"
	c:EnableReviveLimit()
	-- 这张卡不能作为超量召唤的素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：这张卡超量召唤成功时，从卡组把3只龙族怪兽送去墓地才能发动（同名卡最多1张）。对方从自身卡组把3只怪兽除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(58820923,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c58820923.rmcon)
	e2:SetCost(c58820923.rmcost)
	e2:SetTarget(c58820923.rmtg)
	e2:SetOperation(c58820923.rmop)
	c:RegisterEffect(e2)
	-- ②：把这张卡1个超量素材取除才能发动。这个回合，这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(58820923,2))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c58820923.atkcon)
	e3:SetCost(c58820923.atkcost)
	e3:SetTarget(c58820923.atktg)
	e3:SetOperation(c58820923.atkop)
	c:RegisterEffect(e3)
end
-- 设置该怪兽的「No.」数值为95
aux.xyz_number[58820923]=95
-- 过滤自身场上用于重叠超量召唤的「银河眼」超量怪兽
function c58820923.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x107b) and c:IsType(TYPE_XYZ)
end
-- 检查此卡是否通过超量召唤成功特殊召唤
function c58820923.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 过滤卡组中可以作为发动代价送去墓地的龙族怪兽
function c58820923.cfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToGraveAsCost()
end
-- 效果①的发动代价：从卡组选择3张卡名不同的龙族怪兽送去墓地
function c58820923.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己卡组中所有满足条件的龙族怪兽
	local g=Duel.GetMatchingGroup(c58820923.cfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)>2 end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从符合条件的卡中选择3张卡名不同的卡
	local tg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
	-- 将选中的卡作为发动代价送去墓地
	Duel.SendtoGrave(tg,REASON_COST)
end
-- 效果①的发动判定：检查对方卡组数量是否在3张以上，且对方是否能被除外卡片
function c58820923.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动判定时，检查对方卡组是否至少有3张卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>2
		-- 并且检查对方玩家是否可以进行除外操作
		and Duel.IsPlayerCanRemove(1-tp) end
end
-- 过滤对方卡组中可以被除外的怪兽卡
function c58820923.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 效果①的效果处理：对方从自身卡组选择3只怪兽除外
function c58820923.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 若对方玩家此时无法进行除外操作，则效果不适用
	if not Duel.IsPlayerCanRemove(1-tp) then return end
	-- 获取对方卡组中所有可以被除外的怪兽卡
	local g=Duel.GetMatchingGroup(c58820923.rmfilter,1-tp,LOCATION_DECK,0,nil)
	if g:GetCount()>2 then
		-- 提示对方玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg=g:Select(1-tp,3,3,nil)
		-- 将对方选中的3只怪兽表侧表示除外
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end
-- 效果②的发动条件：检查当前回合玩家是否能进入战斗阶段
function c58820923.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否能进入战斗阶段的判定结果
	return Duel.IsAbleToEnterBP()
end
-- 效果②的发动代价：取除此卡的1个超量素材
function c58820923.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果②的发动判定：检查此卡当前是否未适用追加攻击或追加向怪兽攻击的效果
function c58820923.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEffectCount(EFFECT_EXTRA_ATTACK)==0
		and e:GetHandler():GetEffectCount(EFFECT_EXTRA_ATTACK_MONSTER)==0 end
end
-- 效果②的效果处理：给此卡添加「在同1次的战斗阶段中最多2次可以向怪兽攻击」的效果
function c58820923.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 这个回合，这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
