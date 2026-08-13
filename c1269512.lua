--FA－ホープ・レイ・ランサー
-- 效果：
-- 4星怪兽×3
-- 「重铠装-希望鳍条枪兵」1回合1次也能把手卡1张魔法·陷阱卡丢弃，在自己场上的4阶以下的超量怪兽上面重叠来超量召唤。
-- ①：对方场上的怪兽的攻击力下降500。
-- ②：自己·对方的战斗阶段开始时才能发动。对方场上的全部攻击表示怪兽的效果无效化。
-- ③：这张卡的攻击破坏对方怪兽时，把这张卡1个超量素材取除才能发动。这张卡只再1次可以继续攻击。
function c1269512.initial_effect(c)
	aux.AddXyzProcedure(c,nil,4,3,c1269512.ovfilter,aux.Stringid(1269512,0),3,c1269512.xyzop)  --"是否在4阶以下的超量怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：对方场上的怪兽的攻击力下降500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-500)
	c:RegisterEffect(e1)
	-- ②：自己·对方的战斗阶段开始时才能发动。对方场上的全部攻击表示怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1269512,2))  --"对方场上攻击表示的怪兽效果无效化"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c1269512.distg)
	e2:SetOperation(c1269512.disop)
	c:RegisterEffect(e2)
	-- ③：这张卡的攻击破坏对方怪兽时，把这张卡1个超量素材取除才能发动。这张卡只再1次可以继续攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1269512,3))  --"取除超量素材再次攻击"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCountLimit(1)
	e3:SetCondition(c1269512.atcon)
	e3:SetCost(c1269512.atcost)
	e3:SetOperation(c1269512.atop)
	c:RegisterEffect(e3)
end
-- 筛选手卡中可以作为超量召唤手续代价丢弃的魔法·陷阱卡。
function c1269512.cfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsDiscardable()
end
-- 筛选可以作为此次超量召唤叠放对象的表侧表示且阶级在4阶以下的超量怪兽。
function c1269512.ovfilter(c)
	return c:IsFaceup() and c:IsRankBelow(4)
end
-- 自定义超量召唤手续的操作：若本回合尚未使用过该召唤方式且手卡有可丢弃的魔法·陷阱卡，则丢弃1张魔法·陷阱卡并注册誓约标志，以限制1回合1次。
function c1269512.xyzop(e,tp,chk)
	-- 检查当前玩家尚未使用过该召唤方式（flag为0）且手卡存在可丢弃的魔法·陷阱卡。
	if chk==0 then return Duel.GetFlagEffect(tp,1269512)==0 and Duel.IsExistingMatchingCard(c1269512.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃1张手卡的魔法·陷阱卡作为超量召唤手续的代价。
	Duel.DiscardHand(tp,c1269512.cfilter,1,1,REASON_COST+REASON_DISCARD)
	-- 为玩家注册一个直到结束阶段有效的誓约标志，使本回合不能再使用该特殊召唤方式。
	Duel.RegisterFlagEffect(tp,1269512,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 筛选对方场上攻击表示且可被无效化的效果怪兽。
function c1269512.filter(c)
	-- 判断怪兽为表侧表示、攻击表示、效果未被无效且为效果怪兽，满足可被无效化条件。
	return aux.NegateMonsterFilter(c) and c:IsAttackPos()
end
-- 效果②的发动条件与对象设定：战斗阶段开始时，若对方场上有符合条件的攻击表示怪兽，则将其全部设为无效化对象，并设置操作信息。
function c1269512.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检测对方怪兽区是否存在至少1只满足无效化条件的攻击表示怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c1269512.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有满足条件的攻击表示怪兽。
	local g=Duel.GetMatchingGroup(c1269512.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置本次处理为无效这些怪兽，数量为符合条件的怪兽总数，供连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- 效果处理时，对对方场上所有攻击表示且可无效的怪兽分别赋予效果无效和效果效果无效状态。
function c1269512.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时重新获取对方场上满足条件的攻击表示怪兽，避免因时点变化导致遗漏。
	local g=Duel.GetMatchingGroup(c1269512.filter,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 对方场上的全部攻击表示怪兽的效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 对方场上的全部攻击表示怪兽的效果无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
-- 效果③的发动条件：本卡为攻击怪兽、与对方怪兽战斗并破坏了对方怪兽，且本卡可以进行连续攻击。
function c1269512.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 满足“攻击者是本卡、本卡参与了与对方怪兽的战斗并破坏、且本卡可以继续攻击”三个条件。
	return Duel.GetAttacker()==c and aux.bdocon(e,tp,eg,ep,ev,re,r,rp) and c:IsChainAttackable()
end
-- 效果③的发动代价：取除本卡1个超量素材；chk==0时检查是否有素材可取。
function c1269512.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果③的处理：使本卡获得再次攻击的机会。
function c1269512.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 让当前攻击怪兽（本卡）可以再发动一次攻击。
	Duel.ChainAttack()
end
